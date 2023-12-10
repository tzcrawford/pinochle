#!/bin/sh
# This script will set up a SQL database for the pinochle app

CONFIG_FILE="../config.json"

# Check if config.json exists; if not, create from template
if [ ! -e "$CONFIG_FILE" ]; then
    echo "Could not find $CONFIG_FILE, creating from template"
    cp config.json.template "$CONFIG_FILE" || exit 1
fi

# Read configuration from config.json
APP_NAME=$(jq -r '.siteTitle' "$CONFIG_FILE")
DB_NAME=$(jq -r '.postgresDBName' "$CONFIG_FILE")
DB_PORT=$(jq -r '.postgresPort' "$CONFIG_FILE")
DB_USER=$(jq -r '.postgresUsername' "$CONFIG_FILE")
DB_LOCALE=$(jq -r '.postgresLocale' "$CONFIG_FILE" || echo "C.UTF-8")
DB_ENCODING=$(jq -r '.postgresEncoding' "$CONFIG_FILE" || echo "UTF8")
DB_LOCATION=$(jq -r '.postgresDBLocation' "$CONFIG_FILE")

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
        read -p "Running \`sudo apt install postgresql\`. Press enter or use Ctrl+C and run this manually if you prefer."
        sudo apt install postgresql || return 1
    else
        echo "Could not determine install method. Please install PostgreSQL manually."
        return 1
    fi

    read -p "Make any changes you want to pg_hba.conf. Then press enter."

    read -p "Initializing database. Running \`sudo su - postgres -c \"initdb -D '$DB_LOCATION' --locale=$DB_LOCALE --encoding=$DB_ENCODING\"\`."
    sudo su - postgres -c "initdb -D '$DB_LOCATION' --locale=$DB_LOCALE --encoding=$DB_ENCODING" || return 1

    echo "Restarting postgres. Running \`sudo systemctl restart postgresql\`."
    sudo systemctl restart postgresql

    read -p "Creating a db user for your system database. Running \`sudo createuser -U postgres -d -e -E -l -P -r -s $(whoami)\`."
    sudo createuser -U postgres -d -e -E -l -P -r -s $(whoami) || return 1

    read -p "Edit pg_hba.conf for the new user if needed. Then press enter."
    return 0
}

# Function to check if the PostgreSQL database cluster is initialized, or initializes it automatically
function check_db_initialized {
    if [ -d "$DB_LOCATION" ]; then
        echo "PostgreSQL data directory exists. Assuming cluster is initialized."
        echo "If the database is not valid and needs to be regenerated, you can run \`rm -r $DB_LOCATION\` and then run this script again."
        return 0
    else
        echo "Database cluster appears not initialized, trying to initialize now."
        initdb --locale="$DB_LOCALE" --encoding="$DB_ENCODING" -D "$DB_LOCATION" || {
            echo "Could not initialize database cluster." >&2
            return 1
        }
        #read -p "Creating db user '$DB_USER' in your system database. Running \`sudo createuser -U postgres -d -e -E -l -P -r -s \'$DB_USER\'\`."
        
        echo "Creating a random password for the app to use with the project's local database. It can be accessed in python with keyring.get_password('$APP_NAME','$DB_USER')"
        read -p "In the next step, you may get a prompt to generate a keyring. This is not the password for the user, but for the keyring. Press enter to acknowledge."
        random_password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20)
        # Set the generated password in Python keyring
        python -c "import keyring; keyring.set_password('$APP_NAME', '$DB_USER', '$random_password')" || return 1

        read -p "Trying to create database $DB_NAME within cluster $DB_LOCATION with a user $DB_USER with the password just generated. Existing database items with the same name will be DROPPED. Press return to acknowledge."
        
        # We first drop existing databases or roles with the same names so we can create new ones.
        psql -h localhost -p 5432 -U postgres << SQL
DROP DATABASE IF EXISTS "$DB_NAME" ;
SQL
        psql -h localhost -p 5432 -U postgres << SQL
DROP USER IF EXISTS "$DB_USER" ;
SQL
        psql -h localhost -p 5432 -U postgres << SQL
CREATE USER "$DB_USER" WITH PASSWORD '$random_password';
CREATE DATABASE "$DB_NAME" OWNER "$DB_USER";
SQL
        # Save the newly generated password to a file that can be sourced.
        echo "export PGPASSWORD=$random_password" > ./${DB_USER}_password && chmod 600 ./${DB_USER}_password
        psql -h localhost -p 5432 -U postgres << SQL
GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" TO "$DB_USER";
SQL

        echo "Verifying database was created successfully"
        psql -h localhost -p 5432 -U postgres -l | grep "$DB_NAME" > /dev/null || return 1

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
    if ! source ./${DB_USER}_password && psql -h localhost -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -c "SELECT 1;" > /dev/null ; then
        echo "Query failed" >&2 
        return 1
    else
        echo "Setup successful!"
        return 0
    fi
}


check_install || exit 1
check_db_initialized || exit 1
check_db_valid || exit 1
./sql_scripts/countries_table_setup.sh || exit 1
./sql_scripts/languages_table_setup.sh || exit 1
./sql_scripts/pinochle_table_setup.sh || exit 1
./sql_scripts/define_views.sh || exit 1

