#!/bin/bash
# This script helps the user update the map for Wynntils, using journeymap.
# Please install journeymap 5.7, found in the bin directory.
#
# Made by magicus (https://github.com/magicus)
#

base_dir="$(cd $(dirname "$0")/.. 2>/dev/null && pwd)"
WYNNDATA_DIR=${WYNNDATA_DIR:-$base_dir/worldmap}

mkdir -p $WYNNDATA_DIR/rawmap
TMPDIR=$(mktemp -dt wynntils-map.XXXXX)
if [[ ! -e $TMPDIR ]]; then
  echo "Failed to create temporary directory"
  exit 1
fi
echo "Using java:"
java -version

function do_map() {
  NAME="$1"
  FILE="$2"
  X1=$3
  X2=$4
  Z1=$5
  Z2=$6

echo we got X1: $X1 X2: $X2 Z1: $Z1 Z2: $Z2
  OUTPUT_MAP=raw-map-$FILE.png
  SOURCE_TILES=""
  for ((x = $X1; x <= $X2; x++)); do
    for ((z = $Z1; z <= $Z2; z++)); do
      region="$x,$z"
      echo INCLUDING REGION: $region
      region_file="$WYNNDATA_DIR/journeymap-data/DIM0/day/$region.png"
      if [[ -e $region_file ]]; then
        SOURCE_TILES="$SOURCE_TILES $region_file"
      fi
    done
  done

  rm -rf $TMPDIR/DIM0/day
  mkdir -p $TMPDIR/DIM0/day
  cp -a $SOURCE_TILES $TMPDIR/DIM0/day/
  # for syntax regarding journeymaptools-0.3.jar, see https://journeymap.info/JourneyMapTools
  java -Djava.awt.headless=true -jar $WYNNDATA_DIR/bin/journeymaptools-0.3.jar MapSaver $TMPDIR $WYNNDATA_DIR/rawmap/$OUTPUT_MAP 512 512 -1 0 false day
}

#### Create all maps
# syntax: do_map "Nice name" "short-name" x1 x2 z1 z2, where x1 <= x2 and z1 <= z2

do_map "Main" "main" -5 3 -12 -1

do_map "Sunset Valley" "sunset-valley" -4 -3 19 19

do_map "Realm of Light" "light" -3 -2 -13 -12
