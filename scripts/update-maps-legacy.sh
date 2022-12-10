#!/bin/bash
# This script will create an up to date "main-map.png" as used by Legacy. This file should
# be pushed to https://github.com/Wynntils/WynntilsWebsite-API in the maps
# directory.
# It requires updated journeymap data in worldmap for this to work. Make sure
# you have followed the instructions in the README.md file on this prior to running
# this script.
# This script requires ImageMagick to work, as well as journeymap.
# Please install journeymap 5.7, found in the bin directory.
#
# Made by magicus (https://github.com/magicus)
#

BASEDIR="$(cd $(dirname "$0")/.. 2>/dev/null && pwd)"
WYNNCRAFT_WORLD_NAME=${WYNNCRAFT_WORLD_NAME:-Wynncraft}
WYNNDATA_DIR=${WYNNDATA_DIR:-$BASEDIR/worldmap}

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
echo "Rawmap updated."

# Now create proper map file from the raw map

# mask is 4034x6414
RAW_FILE_NAME="$BASEDIR/worldmap/rawmap/map-raw.png"
# Offset of mask into the raw map file
RAW_FILE_OFFSET_X=177
RAW_FILE_OFFSET_Y=83

MASK_FILE_NAME="$BASEDIR/reference/map-mask.png"
MASK_FILE_SIZE=4034x6414

OUTPUT_FILE_NAME="$BASEDIR/main-map.png"

# First crop the input map to match the mask dimensions, using offset 167+48
# Then make all black areas on the mask 100% alpha
# Then do "vibrance", turning up the saturation of unsaturated colors
# (Inspired by http://www.fmwconcepts.com/imagemagick/vibrance3/index.php)
# Finally store as max commpressed png, using -quality 94 == max zlib compression
# with the Paeth filter.

magick $RAW_FILE_NAME -crop $MASK_FILE_SIZE+$RAW_FILE_OFFSET_X+$RAW_FILE_OFFSET_Y +repage $MASK_FILE_NAME -alpha off -compose CopyOpacity -composite -colorspace HCL -channel g -sigmoidal-contrast 2,0% +channel -colorspace sRGB +repage -quality 94 $OUTPUT_FILE_NAME

echo Processed map done, see $OUTPUT_FILE_NAME
rm -f $RAW_FILE_NAME
rmdir $BASEDIR/worldmap/rawmap
