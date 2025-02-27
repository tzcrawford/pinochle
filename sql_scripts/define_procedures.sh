#!/bin/bash

CONFIG_FILE="config.json"
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
PGHOST="/run/user/$(id -u)/pinochle-postgresql"

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
        password = sha256(pass_attempt::BYTEA)
        AND username = username_attempt
\$\$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION set_password(userid_entry INTEGER, old_password TEXT, new_password TEXT)
RETURNS VOID AS \$\$
    UPDATE users
    SET password = sha256(new_password::BYTEA)
    WHERE 
        userid = userid_entry
        AND (
            password = sha256(old_password::BYTEA)
            OR old_password IS NULL
        )
\$\$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION create_user(
    username VARCHAR(25)
    , email VARCHAR(40)
    , language_code CHAR(2)
    , location VARCHAR(25)
    , country_code CHAR(2)
    , default_skill INTEGER
)
RETURNS VOID AS \$\$
    INSERT INTO users
        (username, email, language_code, location, country_code, current_skill)
    VALUES (username, email, language_code, location, country_code, default_skill)
\$\$ LANGUAGE SQL;

SQL
)

source ./${DB_USER}_password && psql -d postgres -h "$PGHOST" -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "$heredoc_content"

