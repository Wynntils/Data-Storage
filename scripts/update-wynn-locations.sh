#!/bin/bash
# Initial attempt at getting a script to process the Wynncraft locations file
# by magicus

curl "https://api.wynncraft.com/public_api.php?action=mapLocations" > wynn-locations.json

# Make file easer to read for humans (not really needed for processing)
jq '.' < wynn-locations.json > wynn-locations-nice.json

# Extract all current types of keys, to verify that Wynn has not added something new
# we need to care about.
jq -r '.locations[].icon' < wynn-locations-nice.json | sort -u > all-keys.txt

# These can't be detected by Wynntils label detector
jq --arg ids "Content_UltimateDiscovery.png Content_Cave.png Content_GrindSpot.png Special_FastTravel.png Special_LightRealm.png Special_RootsOfCorruption.png" '($ids / " ") as $ids | .locations[] | select (.icon | IN($ids[])) | del(.icon)' wynn-locations-nice.json | jq -s '.' > needed.json

# These needs to be corroborated against the Wynntils label detector
jq --arg ids "Content_Dungeon.png Content_Raid.png Content_Miniquest.png Content_BossAltar.png" '($ids / " ") as $ids | .locations[] | select (.icon | IN($ids[])) | del(.icon)' wynn-locations-nice.json | jq -s '.' > check.json

# These probably point to Quest starter NPC characters. Needs to be checked.
jq '.locations[] | select (.icon | contains( "Content_Quest.png")) | del(.icon)' wynn-locations-nice.json | jq -s '.' > quests.json

json_to_csv() {
    jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' $1 | tail -n +2 | sort -u > $2
}

json_to_csv needed.json needed.csv
json_to_csv check.json check.csv
json_to_csv quests.json quests.csv
