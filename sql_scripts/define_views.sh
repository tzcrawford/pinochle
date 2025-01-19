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

source ./${DB_USER}_password && psql -d postgres -h "$PGHOST" -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "
DROP VIEW IF EXISTS users_vw;
"
source ./${DB_USER}_password && psql -d postgres -h "$PGHOST" -p $DB_PORT -U "$DB_USER" -d "$DB_NAME" -c "
CREATE VIEW users_vw AS
SELECT 
    a.userid,a.username,a.language_code,a.location,a.country_code,a.current_skill
    ,e.name AS country_name
    ,e.continent
    ,f.language
    ,COALESCE(SUM(c.gameid)      ,0) AS games_played
    ,COALESCE(SUM(b.won::INTEGER),0) AS games_won
    ,MIN(c.time_created) AS first_game
    ,MAX(c.time_created) AS recent_game
    ,LEAST(    MIN(b.rank_at_start),MIN(b.rank_at_end)) AS  lowest_all_time_skill
    ,GREATEST( MAX(b.rank_at_start),MAX(b.rank_at_end)) AS highest_all_time_skill
    ,AVG(winning_bid) AS average_winning_bid
FROM users AS a
LEFT JOIN game_players AS b ON b.player = a.userid
LEFT JOIN games AS c ON c.gameid = b.gameid
LEFT JOIN hands AS d ON d.game = c.gameid
LEFT JOIN countries AS e ON e.code= a.country_code
LEFT JOIN languages AS f ON f.\"ISO-639-1\" = a.language_code
GROUP BY 
    a.userid,a.username,a.language_code,a.location,a.country_code,a.current_skill
    ,e.name
    ,e.continent
    ,f.language
"

