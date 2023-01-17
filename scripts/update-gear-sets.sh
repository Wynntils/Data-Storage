#!/bin/sh
# This script will retrieve the information on Gear Sets available from Wynnbuilder.
#
# Made by magicus (https://github.com/magicus)
#

base_dir="$(cd $(dirname "$0")/.. 2>/dev/null && pwd)"

TMPDIR=$(mktemp -dt wynntils-map.XXXXX)
if [[ ! -e $TMPDIR ]]; then
  echo "Failed to create temporary directory"
  exit 1
fi
cd $TMPDIR

curl https://raw.githubusercontent.com/hppeng-wynn/hppeng-wynn.github.io/master/clean.json > wynndata-raw.json
jq '.sets' wynndata-raw.json > wynndata-sets.json

# Get the conversion table of Wynncraft API field names to Wynnbuilder field names
curl https://raw.githubusercontent.com/hppeng-wynn/hppeng-wynn.github.io/master/py_script/items_common.py > translations-raw.py
grep '    "' translations-raw.py > translations.txt
sed -E -e 's/"(.*)": "(.*)",.*/translate_key("\2";"\1") |/' < translations.txt > translations.jq

# see https://github.com/stedolan/jq/issues/670#issuecomment-70562058 for this snippet
cat > translation-header.jq << 'EOF'
def translate_key(from;to):
  if type == "object" then . as $in
     | reduce keys[] as $key
         ( {};
       . + { (if $key == from then to else $key end)
             : $in[$key] | translate_key(from;to) } )
  elif type == "array" then map( translate_key(from;to) )
  else .
  end;
EOF

cat translation-header.jq translations.jq > translate.jq
echo "." >> translate.jq
jq -f translate.jq wynndata-sets.json > item-sets.json
cp item-sets.json $base_dir/item-sets.json
cd $base_dir
rm -rf $TMPDIR
