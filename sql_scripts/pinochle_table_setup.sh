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

DB_PASS=python << EOF
import keyring
print(keyring.get_password('$APP_NAME','$DB_USER'))
EOF


PGPASSWORD="$DB_PASS" psql -h localhost -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "
DROP TABLE IF EXISTS users CASCADE;
"
PGPASSWORD="$DB_PASS" psql -h localhost -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "
CREATE TABLE users (
    userid SERIAL PRIMARY KEY,
    username VARCHAR(25) NULL,
    email VARCHAR(40) NULL,
    language VARCHAR(15) NULL,
    location VARCHAR(25) NULL,
    country_code CHAR(2) NULL,
    current_skill INTEGER NULL
);
"

PGPASSWORD="$DB_PASS" psql -h localhost -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "
DROP TABLE IF EXISTS games CASCADE;
"
PGPASSWORD="$DB_PASS" psql -h localhost -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "
CREATE TABLE games (
    gameid SERIAL PRIMARY KEY,
    lobby_title VARCHAR(50) NULL,
    host INTEGER REFERENCES users (userid),
    time_created TIMESTAMP NULL DEFAULT NOW(),
    time_started TIMESTAMP NULL,
    playercount INTEGER NULL,
    ranked BOOLEAN NULL,
    skill_minimum INTEGER NULL,
    skill_maximum INTEGER NULL,
    rules JSON NULL,
    alternate_rules BOOLEAN NULL
);
"

PGPASSWORD="$DB_PASS" psql -h localhost -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "
DROP TABLE IF EXISTS game_players CASCADE;
"
PGPASSWORD="$DB_PASS" psql -h localhost -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "
CREATE TABLE game_players (
    gameid INTEGER NOT NULL,
    player INTEGER NOT NULL REFERENCES users (userid),
    won BOOLEAN NULL,
    rank_at_start INTEGER NULL,
    rank_at_end INTEGER NULL
);
CREATE INDEX gameid ON game_players (gameid);
CREATE INDEX player ON game_players (player);
"

PGPASSWORD="$DB_PASS" psql -h localhost -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "
DROP TABLE IF EXISTS hands CASCADE;
"
PGPASSWORD="$DB_PASS" psql -h localhost -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "
CREATE TABLE hands (
    handid SERIAL PRIMARY KEY,
    game INTEGER NOT NULL REFERENCES games(gameid),
    hand_order INTEGER NULL,
    winning_bid INTEGER NULL,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    trumpsuit CHAR(1)
);
CREATE INDEX game ON hands (game);
"


# Create some test users
PGPASSWORD="$DB_PASS" psql -h localhost -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "
INSERT INTO users
    (username,email,language,location,country_code,current_skill)
VALUES
 ('admin','fake@email.com','English','New York','US',$STARTING_SKILL)
,('test_user_1','test1@email.com','English','Los Angeles','US',$STARTING_SKILL)
,('test_user_2','test2@email.com','English','Chicago','US',$STARTING_SKILL)
,('test_user_3','test2@email.com','German','Hamburg','DE',$STARTING_SKILL);
"


