#!/bin/bash

base_dir="$(cd $(dirname "$0")/.. 2>/dev/null && pwd)"

mkdir -p $base_dir/content/out
touch $base_dir/content/out/cave.json
rm $base_dir/content/out/cave.json
cat $base_dir/content/content_book_dump.json | jq '.cave' | jq '.[].requirements=.[].requirements.level' > $base_dir/content/out/cave.json