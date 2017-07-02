#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -eq 0 ]; then
    echo "$0": usage: parseTVfilename.cgi /path/to/file
    exit 1
fi

dbNameTV="../dbTV.json"
regexTV1="(.*)[ .][sS]([0-9]{1})[eE]([0-9]{2})[ .](.*)"
regexTV2="(.*)[ .][sS]([0-9]{2})[eE]([0-9]{2})[ .](.*)"
regexTV3="(.*)[.]([0-9]{2})[x]([0-9]{2})[.](.*)"
regexTV4="(.*)[.]([0-9]{1})[x]([0-9]{2})[.](.*)"

. config.cfg
if [ ! -f $dbNameTV ]; then
    touch $dbNameTV;
fi

file=${1#../}
filename=$(basename "$file")
if [[ "${filename}" =~ ${regexTV1} ]] || [[ "${filename}" =~ ${regexTV2} ]] || [[ "${filename}" =~ ${regexTV3} ]] || [[ "${filename}" =~ ${regexTV4} ]]; then
	myShow=${BASH_REMATCH[1]};
	myShow=${myShow//./ }
	mySeason=${BASH_REMATCH[2]};
	myEpisode=${BASH_REMATCH[3]};
	if [ -s $dbNameTV ]; then
		if [[ $(jq "map(select(.Show == \"${myShow}\"))" $dbNameTV) != "[]" ]]; then
			if ! grep -q ${file} $dbNameTV; then
				jq -r "map((select(.Show == \"${myShow}\") | .Episodes) |= . + [{\"Season\":\"${mySeason}\",\"Episode\":\"${myEpisode}\",\"File\":\"${file}\"}])" $dbNameTV | sponge $dbNameTV;
			fi
		else
			myPoster="";
			myID=$(./getTVid.cgi "${myShow}");
			tempPath=$(dirname $1);
			tempPath=${tempPath%/*};
			numSeasons=$(find $tempPath -mindepth 1 -type d | wc -l);

			if [[ $myID =~ ^-?[0-9]+$ ]]; then #checks if ID is a number
				myPoster=$(./getTVposter.cgi "${myID}");
			else
				myID=""
				myPoster=""
			fi
			jq -r ". |= . + [{\"Show\":\"${myShow}\",\"ID\":\"${myID}\",\"Poster\":\"${myPoster}\",\"Seasons\":\"${numSeasons}\",\"Episodes\":[{\"Season\":\"${mySeason}\",\"Episode\":\"${myEpisode}\",\"File\":\"${file}\"}]}]" $dbNameTV | sponge $dbNameTV;
		fi
	else
		myPoster="";
		myID=$(./getTVid.cgi "${myShow}");
		if [[ $myID =~ ^-?[0-9]+$ ]]; then #checks if ID is a number
        	myPoster=$(./getTVposter.cgi "${myID}");
        else
            myID=""
        	myPoster=""
        fi
		tempPath=$(dirname $1);
        tempPath=${tempPath%/*};
        numSeasons=$(find $tempPath -mindepth 1 -type d | wc -l);

		printf '[{"Show":"%s", "ID":"%s", "Poster":"%s", "Seasons":"%s", "Episodes":[{"Season":"%s","Episode":"%s","Filepath":"%s"}]}]\n' "${myShow}" "${myID}" "${myPoster}" "${numSeasons}" "${mySeason}" "${myEpisode}" "${file}" >> $dbNameTV;
	fi
else
	echo -n "Unparsable "
	echo $filename
fi
