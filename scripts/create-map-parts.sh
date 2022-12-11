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
else # Use GNU head, macOS BSD head is too stupid
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

  echo "===================="
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

  echo

  MASK_FILE_NAME="$WYNNDATA_DIR/masks/map-mask-$FILE.png"

  OUTPUT_FILE_NAME="$WYNNDATA_DIR/out/map-$FILE.png"

  # If we have a mask: First start by procecting all areas covered by the mask,
  # and make all other areas black.

  # Always:
  # Then do "vibrance", turning up the saturation of unsaturated colors
  # (Inspired by http://www.fmwconcepts.com/imagemagick/vibrance3/index.php)
  # Finally store as max commpressed png, using -quality 94 == max zlib compression
  # with the Paeth filter.

  if [ -e $MASK_FILE_NAME ]; then
    echo Using mask $MASK_FILE_NAME
    magick $RAW_FILE_NAME -alpha off -write-mask $MASK_FILE_NAME -fill black -colorize 100% -colorspace HCL -channel g -sigmoidal-contrast 2,0% +channel -colorspace sRGB +repage -quality 94 $OUTPUT_FILE_NAME
  else
    echo No mask file found
    magick $RAW_FILE_NAME -colorspace HCL -channel g -sigmoidal-contrast 2,0% +channel -colorspace sRGB +repage -quality 94 $OUTPUT_FILE_NAME
  fi
  echo

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

do_map "Main" "main" -5 3 -12 -1
do_map "Ceralus Farm 1" "ceralus-1" -10 -7 -3 -3
do_map "Ceralus Farm 2" "ceralus-2" -17 -16 -3 -3
do_map "Deja Vu" "deja-vu" -9 -8 2 2
do_map "King's Recruit" "kings-recruit" -21 -21 -5 -4
do_map "Misadventure on the Sea" "misadventure-on-the-sea" -7 -5 30 32
do_map "Realm of Light" "realm-of-light" -3 -2 -13 -12
do_map "Seaskipper" "seaskipper" 31 32 30 30
do_map "Sunset Valley" "sunset-valley" -4 -3 19 19
do_map "The Void" "void" 26 27 -10 -7
do_map "Wynnter Fair" "wynnter-fair" -3 -2 31 32
do_map "Wynnter Fair Parkour" "wynnter-fair-parkour" -4 -4 35 36

# Remove the trailing comma
$HEAD -n -1 $JSON_METADATA_FILE > $JSON_METADATA_FILE.tmp
mv $JSON_METADATA_FILE.tmp $JSON_METADATA_FILE
echo "  }" >> $JSON_METADATA_FILE
echo "]" >> $JSON_METADATA_FILE
