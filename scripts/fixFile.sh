#! /bin/bash

if  [[ "$#" -gt 3 ]] || [[ "$#" -lt 2 ]]; then
	echo "${0}: usage: fixFile.sh path/to/file newID (and, optionally) pathToImg"
	exit 1
fi

cd "$(dirname "$0")"
TVpath=../TV/;
MoviesPath=../Movies/;
dbNameMovie="../dbM.json"
dbNameTV="../dbTV.json"
. config.cfg

filename=$1
newID=$2
newImg=$3


if  [[ -s $dbNameMovie ]] || [[ -s $dbNameTV ]]; then #checks if database is NOT empty
	if grep -q ${filename} $dbNameMovie; then
		tmpfile=$(mktemp)
		myNum=$(jq -r "index(map(select(.File==\"${filename}\")))" $dbNameMovie);
		if [ -z "$newID" ]; then
			newID=$(jq -r ".[$myNum].ID" $dbNameMovie);
		fi
		if [ -z "$newImg" ]; then
			newImg=$(jq -r ".[$myNum].Poster" $dbNameMovie);
		fi
		toAdd=$(jq -r ".[$myNum].ID = \"${newID}\" | .[$myNum].Poster = \"${newImg}\"" $dbNameMovie)
		echo -en $toAdd"\n" >> $tmpfile;
		jq . $tmpfile | sponge $dbNameMovie;
		rm $tmpfile
	elif grep -q ${filename} $dbNameTV; then # if the movie is already in the database
		tmpfile=$(mktemp);
		myNum=$(jq -r ".[].Episodes | map(select(.File == \"${filename}\"))" $dbNameTV | jq -r 'index(select(. != null))' | grep -n '0' | cut -d : -f 1);
		myNum=$(($myNum-1));
		if [ -z "$newID" ]; then
			newID=$(jq -r ".[$myNum].ID" $dbNameTV);
		fi
		if [ -z "$newImg" ]; then
			newImg=$(jq -r ".[$myNum].Poster" $dbNameTV);
		fi
		toAdd=$(jq -r ".[$myNum].ID = \"${newID}\" | .[$myNum].Poster = \"${newImg}\"" $dbNameTV)
		echo -en $toAdd"\n" >> $tmpfile;
		jq . $tmpfile | sponge $dbNameTV;
		rm $tmpfile
	else
		echo "\"""$1""\" not present in any DB"
	fi
else
	echo "DBs are empty/non existent";
fi;
exit;

