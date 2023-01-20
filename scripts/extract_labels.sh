#!/bin/sh
# This script will retrieve the labels.js file from map.wynncraft.com, parse
# the locations and coordinates that are present in it, and convert it to a
# json file.
#
# Made by magicus (https://github.com/magicus)
#
MYDIR=$(cd $(dirname "$0") >/dev/null 2>&1 && pwd)
TARGET="$MYDIR/../map-labels.json"

# This file contain additional labels that are not provided by upstread.
MISSING="$MYDIR/../map-labels-missing.json"

command -v curl > /dev/null 2>&1
if test $? -ne 0; then
  echo curl is required
  exit 1
fi

command -v gawk > /dev/null 2>&1
if test $? -ne 0; then
  echo gawk is required
  exit 1
fi

command -v jq > /dev/null 2>&1
if test $? -ne 0; then
  echo jq is required
  exit 1
fi

curl -s https://map.wynncraft.com/js/labels.js | gawk '
function jsonval(v)
{
  return "\""v"\": " SYMTAB[v]
}

function jsonvalquote(v)
{
  return "\""v"\": \"" SYMTAB[v] "\""
}

match($0, /fromWorldToLatLng\( *([0-9-]*), *[0-9-]*, *([0-9-]*), *ovconf/, a) {
  x = a[1];
  z = a[2];
}
match($0, /[^/] *html: labelHtml\('"'"'(.*) *<div class="level">\[Lv. ([0-9+ -]*)\]<\/div>'"'"', '"'"'([0-9]*)'"'"'/, b) {
  name = b[1];
  gsub(/[ \t]+$/, "", name);
  gsub("\\\\", "", name);

  level = b[2]
  gsub(" ", "", level);

  switch (b[3]) {
case 25:
    layer=1; break
case 16:
    layer=2; break
case 14:
    layer=3; break
  }
  if (substr(name,1,1) != "<") {
    print "{ " jsonval("x") ", " jsonval("z") ", " jsonvalquote("name") ", " jsonval("layer") ", " jsonvalquote("level") " }"
  }
}

match($0, /[^/] *html: labelHtml\('"'"'([^[]*)'"'"', '"'"'([0-9]*)'"'"'/, b) {
  name = b[1];
  gsub(/[ \t]+$/, "", name);
  gsub("\\\\", "", name);

  switch (b[2]) {
case 25:
    layer=1; break
case 16:
    layer=2; break
case 14:
    layer=3; break
  }
  if (substr(name,1,1) != "<") {
    print "{ " jsonval("x") ", " jsonval("z") ", " jsonvalquote("name") ", " jsonval("layer") " }"
  }
}
' > "$TARGET.tmp"

cat "$TARGET.tmp" "$MISSING" | jq -s '{labels: .}' > "$TARGET"
rm "$TARGET.tmp"

echo Finished updating "$TARGET"
