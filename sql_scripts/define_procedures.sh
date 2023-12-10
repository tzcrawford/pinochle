#!/bin/sh

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
STARTING_SKILL=$(jq -r '.starting_skill' "$CONFIG_FILE")

heredoc_content=$(cat << SQL
CREATE OR REPLACE FUNCTION pass_auth(username_attempt VARCHAR(25),pass_attempt TEXT)
RETURNS TABLE (
    userid INTEGER,
    username VARCHAR(25)
)
AS \$\$
    SELECT userid,username
    FROM users
    WHERE 
        password = crypt(pass_attempt,password)
        AND username = username_attempt
\$\$ LANGUAGE SQL

CREATE OR REPLACE FUNCTION set_password(userid_entry INTEGER, old_password VARCHAR(25), new_password VARCHAR(25))
RETURNS VOID AS \$\$
    UPDATE users
    SET password = crypt(new_password, gen_salt('bf'))
    WHERE 
        userid = userid_entry
        AND (password = crypt(pass_attempt,password) OR password IS NULL);
\$\$ LANGUAGE SQL
SQL
)


