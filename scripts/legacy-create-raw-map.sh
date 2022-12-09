#!/bin/bash
# This script helps the user update the map for Wynntils, using journeymap.
# Please install journeymap 5.7, found in the bin directory.
#
# Made by magicus (https://github.com/magicus)
#

base_dir="$(cd $(dirname "$0")/.. 2>/dev/null && pwd)"
WYNNCRAFT_WORLD_NAME=${WYNNCRAFT_WORLD_NAME:-Wynncraft}
WYNNDATA_DIR=${WYNNDATA_DIR:-$base_dir/worldmap}
COMMAND=$1

mkdir -p $WYNNDATA_DIR/rawmap
TMPDIR=$(mktemp -d -t wynntils-map.XXXXX)
if [[ ! -e $TMPDIR ]]; then
  echo "Failed to create temporary directory"
  exit 1
fi
mkdir -p $TMPDIR/DIM0/day
cp -a $WYNNDATA_DIR/journeymap-data/DIM0/day/[0-5],-[1-9].png $WYNNDATA_DIR/journeymap-data/DIM0/day/-[1-5],-[1-9].png $WYNNDATA_DIR/journeymap-data/DIM0/day/[0-5],-1[0-3].png $WYNNDATA_DIR/journeymap-data/DIM0/day/-[1-5],-1[0-3].png $WYNNDATA_DIR/journeymap-data/DIM0/day/0,0.png $TMPDIR/DIM0/day/
echo "Using java:"
java -version
# for syntax regarding journeymaptools-0.3.jar, see https://journeymap.info/JourneyMapTools
java -jar $WYNNDATA_DIR/bin/journeymaptools-0.3.jar MapSaver $TMPDIR $WYNNDATA_DIR/rawmap/map-raw.png 512 512 -1 0 false day
rm -rf $TMPDIR
echo "Rawmap updated. Please go to $WYNNDATA_DIR and commit and push your changes"
