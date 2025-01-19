#!/bin/bash
# This script will set up a SQL database for the pinochle app

CONFIG_FILE="config.json"

# Check if config.json exists; if not, create from template
if [ ! -e "$CONFIG_FILE" ]; then
    echo "Could not find $CONFIG_FILE, please create one from config.json.template"
   exit 1
fi

# Read configuration from config.json
APP_NAME=$(jq -r '.siteTitle' "$CONFIG_FILE")
DB_NAME=$(jq -r '.postgresDBName' "$CONFIG_FILE")
DB_PORT=$(jq -r '.postgresPort' "$CONFIG_FILE")
DB_USER=$(jq -r '.postgresUsername' "$CONFIG_FILE")
DB_LOCALE=$(jq -r '.postgresLocale' "$CONFIG_FILE" || echo "C.UTF-8")
DB_ENCODING=$(jq -r '.postgresEncoding' "$CONFIG_FILE" || echo "UTF8")
DB_LOCATION="$(pwd)/$(jq -r '.postgresDBLocation' "$CONFIG_FILE")"
PGHOST="/run/user/$(id -u)/pinochle-postgresql"

function check_install {
    if command -v postgres &> /dev/null; then
        echo "Found postgres installation"
        return 0
    fi

    echo "Could not find postgresql installation. This script includes a limited install wizard."
    read -p "Press Enter to continue or Ctrl+C to exit."

    if grep -E "Arch Linux|Manjaro" /etc/os-release &> /dev/null; then
        echo "Detected Arch Linux style distro"
        read -p "Running \`sudo pacman -S postgresql\`. Press enter or use Ctrl+C and run this manually if you prefer."
        sudo pacman -S postgresql || return 1
    elif grep -E "Debian|Ubuntu" /etc/os-release &> /dev/null; then
        echo "Detected Debian style distro"
        read -p "Running \`sudo apt install postgresql postgresql-contrib libpq-dev\`. Press enter or use Ctrl+C and run this manually if you prefer."
        sudo apt install postgresql postgresql-contrib libpq-dev || return 1
    else
        echo "Could not determine install method. Please install PostgreSQL manually."
        return 1
    fi

    return 0
}

function delete_db {
    read -p "Are you sure you would like to delete the existing database (if there is one) [y/n]?" WANTSTODELETE
    if [ "$WANTSTODELETE" = 'y' ] ; then
        rm -r $DB_LOCATION
        systemctl --user stop pinochle-postgresql-user.service 
        return 0
    else
        return 1
    fi
}

# Function to check if the PostgreSQL database cluster is initialized, or initializes it automatically
function check_db_initialized {
    if [ -d "$DB_LOCATION" ]; then
        echo "PostgreSQL data directory exists. Assuming cluster is initialized."
        echo "If the database is not valid and needs to be regenerated, you can run \`systemctl --user stop pinochle-postgresql-user.service && rm -r $DB_LOCATION\` and then run this script again."
        return 0
    else
        echo "Database cluster appears not initialized, trying to initialize now."
        initdb -D "$DB_LOCATION" --locale="$DB_LOCALE" --encoding="$DB_ENCODING" || return 1


        echo "Creating and starting postgres user service."
        mkdir -p $HOME/.config/systemd/
        mkdir -p $HOME/.config/systemd/user
        mkdir -p "$PGHOST"
        cat > $HOME/.config/systemd/user/pinochle-postgresql-user.service << EOF
[Unit]
Description=PostgreSQL database in user space for the pinochle app
After=network.target

[Service]
Type=simple
ExecStart=$(which postgres) -D $DB_LOCATION -p $DB_PORT -k $PGHOST
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF
        systemctl --user daemon-reload || return 1
        sleep 6
        systemctl --user enable --now pinochle-postgresql-user.service || return 1
        sleep 6
        systemctl --user restart pinochle-postgresql-user.service || return 1
        until pg_isready -h "$PGHOST" -p "$DB_PORT"; do
            sleep 1
        done

        #read -p "Creating a db user for your system database. Running \`sudo createuser -U postgres -d -e -E -l -P -r -s $(whoami)\`."
        #sudo createuser -U postgres -d -e -E -l -P -r -s $(whoami) || return 1
        echo "Creating db user '$DB_USER' in your database. Password will be overwritten in upcoming step, so you can enter anything."
        #psql -d postgres -h "$PGHOST" -p $DB_PORT -U postgres # Need to create this role manually for some reason?
        createuser -h "$PGHOST" -p $DB_PORT -U $USER -d -e -E -l -P -r -s $DB_USER || return 1

        read -p "Edit pg_hba.conf for the new user if needed. Then press enter."
        
        echo "Creating a random password for the app to use with the project's local database. It can be accessed in python with keyring.get_password('$APP_NAME','$DB_USER')"
        read -p "In the next step, you may get a prompt to generate a keyring. This is not the password for the user, but for the keyring. Press enter to acknowledge."
        random_password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20)
        # Set the generated password in Python keyring
        python -c "import keyring; keyring.set_password('$APP_NAME', '$DB_USER', '$random_password')" || return 1

        read -p "Trying to create database $DB_NAME within cluster $DB_LOCATION with a user $DB_USER with the password just generated. Existing database items with the same name will be DROPPED. Press return to acknowledge."
        
#        # We first drop existing databases or roles with the same names so we can create new ones.
#        psql -d postgres -h "$PGHOST" -p $DB_PORT -U $DB_USER << SQL
#DROP DATABASE IF EXISTS "$DB_NAME" ;
#SQL
        
        echo "Enabling pgcrypt for password encryption."
        psql -d postgres -h "$PGHOST" -p $DB_PORT -U $DB_USER << SQL
CREATE EXTENSION pgcrypto;
SQL
        #echo "Setting password encryption algorithm to scram-sha-256 ./database/pg_hba.conf"
        #sed -i 's/ trust/ scram-sha-256/g' ./database/pg_hba.conf || return 1
        echo "Reloading database"
        psql -d postgres -h "$PGHOST" -p $DB_PORT -U $DB_USER << SQL
SELECT pg_reload_conf()
SQL

        echo "Creating new user and database for app."
        psql -d postgres -h "$PGHOST" -p $DB_PORT -U $DB_USER << SQL
ALTER  USER "$DB_USER" WITH PASSWORD '$random_password';
CREATE DATABASE "$DB_NAME" OWNER "$DB_USER";
SQL

        echo "Enabling pgcrypt for password encryption in the app database."
        psql -d postgres -h "$PGHOST" -p $DB_PORT -d "$DB_NAME" -U $DB_USER << SQL
CREATE EXTENSION pgcrypto;
SQL

        echo "Reloading app database"
        psql -d postgres -h "$PGHOST" -p $DB_PORT -d "$DB_NAME" -U $DB_USER << SQL
SELECT pg_reload_conf()
SQL

        # Save the newly generated password to a file that can be sourced.
        echo "export PGPASSWORD=$random_password" > ./${DB_USER}_password && chmod 600 ./${DB_USER}_password
        psql -d postgres -h "$PGHOST" -p $DB_PORT -U $DB_USER << SQL
GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" TO "$DB_USER";
SQL

        echo "Verifying database was created successfully"
        psql -d postgres -h "$PGHOST" -p $DB_PORT -U $DB_USER -l | grep "$DB_NAME" > /dev/null || return 1

        return 0
    fi
}

# Function to check if the PostgreSQL database is valid
function check_db_valid {
    # We use a simple query to check if the database is valid 
    echo -e "running \`SELECT 1\` on database using user $DB_USER. Here we use:\npython -c \"import keyring;print(keyring.get_password('$APP_NAME','$DB_USER'))\""
    pass=`python << EOF
import keyring
print(keyring.get_password('$APP_NAME','$DB_USER'))
EOF`
    
    echo "Testing simple query SELECT 1..."
    if ! source ./${DB_USER}_password && psql -d postgres -h "$PGHOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -c "SELECT 1;" > /dev/null ; then
        echo "Query failed" >&2 
        return 1
    else
        echo "Setup successful!"
        return 0
    fi
}


delete_db || exit 1
check_install || exit 1
check_db_initialized || exit 1
check_db_valid || exit 1
read -p "Creating tables and views to support app. Note these scripts include drop commands before creation, if it warns it is skipping a step because the object does not exist, that is expected behavior. Press enter to continue."
./sql_scripts/countries_table_setup.sh || exit 1
./sql_scripts/languages_table_setup.sh || exit 1
./sql_scripts/pinochle_table_setup.sh || exit 1
./sql_scripts/define_views.sh || exit 1
./sql_scripts/define_procedures.sh || exit 1
echo "Database configuration completed successfully!"

