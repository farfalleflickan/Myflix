#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "${0}: usage: sortByName.sh (1 for movies | 2 for tv shows | 3 for both )"
    exit 1
fi

cd "$(dirname "$0")"
dbNameMovie="../dbM.json" # identifies path and name of the movie database
dbNameTV="../dbTV.json" # identifies path and name of the tv show database
. config.cfg

case "${1}" in #switch case for the program's argument
    "1")
		cat $dbNameMovie | jq 'sort_by(.Movie)' -r | sponge $dbNameMovie;
        ;;
    "2")
		cat $dbNameTV | jq 'sort_by(.Show)' -r | sponge $dbNameTV;
        ;;
    "3")
		cat $dbNameMovie | jq 'sort_by(.Movie)' -r | sponge $dbNameMovie;
		cat $dbNameTV | jq 'sort_by(.Show)' -r | sponge $dbNameTV;
        ;;
    *)
        echo "Invalid input, use: #1 for only movies, #2 for only tv shows and #3 for both";;
esac
echo "Sorted DBs"

