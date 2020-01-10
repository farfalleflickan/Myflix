#! /bin/bash

cd "$(dirname "$0")"
dbNameMovie="../dbM.json" # identifies path and name of the movie database
. config.cfg

cat $dbNameMovie | jq 'sort_by(.ID)' -r | jq 'reverse' -r | sponge $dbNameMovie;

echo "Sorted home movies"
