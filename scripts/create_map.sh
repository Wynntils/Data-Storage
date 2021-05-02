#/bin/sh
# This script will create a suitable map.png file from a raw minimap dump.
# It requires ImageMagick to work.
#
# Made by magicus (https://github.com/magicus)
#

MYDIR=$(cd $(dirname "$0") > /dev/null && pwd)

RAW_FILE_NAME="$MYDIR/../map-raw.png"
# Offset of mask into the raw map file
RAW_FILE_OFFSET_X=177
RAW_FILE_OFFSET_Y=83

MASK_FILE_NAME="$MYDIR/../reference/map-mask.png"
MASK_FILE_SIZE=4034x6414

OUTPUT_FILE_NAME="$MYDIR/../main-map.png"

# First crop the input map to match the mask dimensions, using offset 167+48
# Then make all black areas on the mask 100% alpha
# Then do "vibrance", turning up the saturation of unsaturated colors
# (Inspired by http://www.fmwconcepts.com/imagemagick/vibrance3/index.php)
# Finally store as max commpressed png, using -quality 94 == max zlib compression
# with the Paeth filter.

magick $RAW_FILE_NAME -crop $MASK_FILE_SIZE+$RAW_FILE_OFFSET_X+$RAW_FILE_OFFSET_Y +repage $MASK_FILE_NAME -alpha off -compose CopyOpacity -composite -colorspace HCL -channel g -sigmoidal-contrast 2,0% +channel -colorspace sRGB +repage -quality 94 $OUTPUT_FILE_NAME
