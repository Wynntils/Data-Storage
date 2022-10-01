#!/bin/bash
# This script helps the user update the map for Wynntils, using journeymap.
# Please install journeymap 5.7, found in the bin directory.
#
# Made by magicus (https://github.com/magicus)
#

base_dir="$(cd $(dirname "$0")/.. 2>/dev/null && pwd)"
WYNNDATA_DIR=${WYNNDATA_DIR:-$base_dir/worldmap}
BASE_URL="https://raw.githubusercontent.com/Wynntils/WynntilsWebsite-API/master/maps"
JSON_METADATA_FILE="$WYNNDATA_DIR/out/maps.json"

if [ "$(uname -s)" == "Linux" ]; then
    HEAD=head
else # Use GNU sed, macOS BSD sed is too stupid
    HEAD=ghead
fi

mkdir -p $WYNNDATA_DIR/rawmap
TMPDIR=$(mktemp -dt wynntils-map.XXXXX)
if [[ ! -e $TMPDIR ]]; then
  echo "Failed to create temporary directory"
  exit 1
fi

function do_map() {
  NAME="$1"
  FILE="$2"
  X1=$3
  X2=$4
  Z1=$5
  Z2=$6

  echo "Processing $NAME..."
  OUTPUT_MAP=raw-map-$FILE.png
  SOURCE_TILES=""
  for ((x = $X1; x <= $X2; x++)); do
    for ((z = $Z1; z <= $Z2; z++)); do
      region="$x,$z"
      echo "Including region: $region"
      region_file="$WYNNDATA_DIR/journeymap-data/DIM0/day/$region.png"
      if [[ -e $region_file ]]; then
        SOURCE_TILES="$SOURCE_TILES $region_file"
      fi
    done
  done

  rm -rf $TMPDIR/DIM0/day
  mkdir -p $TMPDIR/DIM0/day
  # journeymaptools need to have exactly the regions we want to process, no
  # more, no less
  cp -a $SOURCE_TILES $TMPDIR/DIM0/day/

  RAW_FILE_NAME="$WYNNDATA_DIR/rawmap/$OUTPUT_MAP"

  # for syntax regarding journeymaptools-0.3.jar, see https://journeymap.info/JourneyMapTools
  java -Djava.awt.headless=true -jar $WYNNDATA_DIR/bin/journeymaptools-0.3.jar MapSaver $TMPDIR $RAW_FILE_NAME 512 512 -1 0 false day


  # mask and map is 1024 x 512
  # Offset of mask into the raw map file

  MASK_FILE_NAME="$WYNNDATA_DIR/masks/map-mask-$FILE.png"

  OUTPUT_FILE_NAME="$WYNNDATA_DIR/out/map-$FILE.png"

  # First crop the input map to match the mask dimensions, using offset 167+48
  # Then make all black areas on the mask 100% alpha
  # Then do "vibrance", turning up the saturation of unsaturated colors
  # (Inspired by http://www.fmwconcepts.com/imagemagick/vibrance3/index.php)
  # Finally store as max commpressed png, using -quality 94 == max zlib compression
  # with the Paeth filter.

  magick $RAW_FILE_NAME +repage $MASK_FILE_NAME -alpha off -compose CopyOpacity -composite -colorspace HCL -channel g -sigmoidal-contrast 2,0% +channel -colorspace sRGB +repage -quality 94 $OUTPUT_FILE_NAME

  x_min=$(expr $X1 '*' 512)
  x_max=$(expr $X2 '*' 512 + 511)
  z_min=$(expr $Z1 '*' 512)
  z_max=$(expr $Z2 '*' 512 + 511)
  MD5=$(md5sum $OUTPUT_FILE_NAME | cut -d' ' -f1)
  cat <<EOT >> $JSON_METADATA_FILE
  {
    "name": "$NAME",
    "url": "$BASE_URL/map-$FILE.png",
    "x1": $x_min,
    "z1": $z_min,
    "x2": $x_max,
    "z2": $z_max,
    "md5": "$MD5"
  },
EOT
}

mkdir -p $WYNNDATA_DIR/out
echo "[" > $JSON_METADATA_FILE

#### Create all maps
# syntax: do_map "Nice name" "short-name" x1 x2 z1 z2, where x1 <= x2 and z1 <= z2

#do_map "Main" "main" -5 3 -12 -1

do_map "Sunset Valley" "sunset-valley" -4 -3 19 19

#do_map "Realm of Light" "light" -3 -2 -13 -12

# Remove the trailing comma
$HEAD -n -1 $JSON_METADATA_FILE > $JSON_METADATA_FILE.tmp
mv $JSON_METADATA_FILE.tmp $JSON_METADATA_FILE
echo "  }" >> $JSON_METADATA_FILE
echo "]" >> $JSON_METADATA_FILE
