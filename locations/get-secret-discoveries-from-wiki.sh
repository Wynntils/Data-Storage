#!/bin/bash
CATEGORY=Secret_Discoveries
LIST_ALL_URL="https://wynncraft.fandom.com/api.php?action=query&format=json&list=categorymembers&meta=&rawcontinue=1&cmtitle=Category%3A${CATEGORY}&cmprop=ids%7Ctitle&cmlimit=183&cmdir=newer"
curl -s "$LIST_ALL_URL" | jq '.query.categorymembers[] | .title,.pageid'  > ${CATEGORY}-pages.txt

function get_infobox_json() {
  local pageid=$1
  local output_dir=$2
  local base_name=$3

  local raw_file=${output_dir}/tmp/${base_name}.raw.json
  local wikitext_file=${output_dir}/tmp/${base_name}.wikitext.json
  local infobox_file=${output_dir}/tmp/${base_name}.infobox.json
  local output_file=${output_dir}/${base_name}.json

  # Download json description of the wiki page
  curl -s "https://wynncraft.fandom.com/api.php?action=query&format=json&prop=revisions&pageids=${pageid}&rvprop=content&rvslots=main" > ${raw_file}

  # Extract the wiki text from the json
  jq '.query.pages[] | .revisions[] | .slots.main["*"]' ${raw_file} > ${wikitext_file}

  # Extract the infobox from the wiki text, and convert it to a properties file
  # The complex first expression will allow matching for one level of nested "{{ .. }}"
  sed -E -e 's/^.*{\{Infobox\/Town((([^{}][^{}]*)(\{\{[^}][^}]*\}\})?)*)\}\}.*$/\1/' -e 's/\\n$//g' -e 's/ *\\n\| */\n/g' -e 's/^\n//g' -e 's/ *$//g'  -e '/^$/d'  -e 's/ *= */=/g' < ${wikitext_file} > ${infobox_file}

  # Convert the properties file to json
  jq -R -s 'split("\n") | map(select(length > 0)) | map(select(startswith("#") | not)) | map(split("=")) | map({(.[0]): .[1:] | join("=")}) | add' < ${infobox_file} > ${output_file}
}

mkdir -p $CATEGORY/tmp
cat ${CATEGORY}-pages.txt | while read -r title; do
    read pageid
    filename=$(tr ' ' '_' <<< $title | tr -d '"')
    echo Creating $filename.json from pageid $pageid
    get_infobox_json $pageid ${CATEGORY} $filename
done
rm ${CATEGORY}-pages.txt
