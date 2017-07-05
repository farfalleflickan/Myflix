#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -eq 0 ]; then
    echo "$0": usage: parseTVfilename.cgi /path/to/file
    exit 1
fi

dbNameTV="../dbTV.json"
fetchTVmetadata=false
regexTV1="(.*)[ .][sS]([0-9]{1})[eE]([0-9]{2})[ .](.*)"
regexTV2="(.*)[ .][sS]([0-9]{2})[eE]([0-9]{2})[ .](.*)"
regexTV3="(.*)[.]([0-9]{2})[x]([0-9]{2})[.](.*)"
regexTV4="(.*)[.]([0-9]{1})[x]([0-9]{2})[.](.*)"
TMDBapi=""

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
		if grep -q "\"Show\": \"${myShow}\"" $dbNameTV; then
			if ! grep -q ${file} $dbNameTV; then
                                myTitle=""
                                if $fetchTVmetadata; then
                                    if [[ ! -z "$TMDBapi" ]]; then
                                        myID=$(jq -r "map((select(.Show == \"${myShow}\") | .ID)) | .[]" $dbNameTV)
                                        myUrl="https://api.themoviedb.org/3/tv/"${myID}"/season/"${mySeason}"/episode/"${myEpisode}"?language=en&api_key="${TMDBapi}
                                        myTitle=$(curl -s --request GET --url $myUrl --data '{}' | jq -r '.name')
                                        myTitle=$(echo ${myTitle} | sed "s/'//g")
                                        myTitle=$(echo ${myTitle} | sed "s/\"//g")
                                    fi
                                fi
                                jq -r "map((select(.Show == \"${myShow}\") | .Episodes) |= . + [{\"Season\":\"${mySeason}\",\"Episode\":\"${myEpisode}\",\"Title\":\"${myTitle}\",\"File\":\"${file}\"}])" $dbNameTV | sponge $dbNameTV;
			fi
		else
			myPoster="";
			myID="";
                        myTitle="";
	        if $fetchTVmetadata; then
				myID=$(./getTVid.cgi "${myShow}");
				if [[ $myID =~ ^-?[0-9]+$ ]]; then #checks if ID is a number
                                        if [[ ! -z "$TMDBapi" ]]; then
                                        myUrl="https://api.themoviedb.org/3/tv/"${myID}"/season/"${mySeason}"/episode/"${myEpisode}"?language=en&api_key="${TMDBapi}
                                        myTitle=$(curl -s --request GET --url $myUrl --data '{}' | jq -r '.name')
                                        myTitle=$(echo ${myTitle} | sed "s/'//g")
                                        myTitle=$(echo ${myTitle} | sed "s/\"//g")
                                        fi
					myPoster=$(./getTVposter.cgi "${myID}");
				else
					myID=""
					myPoster=""
				fi
			fi
			tempPath=$(dirname $1);
            tempPath=${tempPath%/*};
            numSeasons=$(find $tempPath -mindepth 1 -type d | wc -l);
			jq -r ". |= . + [{\"Show\": \"${myShow}\",\"ID\":\"${myID}\",\"Poster\":\"${myPoster}\",\"Seasons\":\"${numSeasons}\",\"Episodes\":[{\"Season\":\"${mySeason}\",\"Episode\":\"${myEpisode}\",\"Title\":\"${myTitle}\",\"File\":\"${file}\"}]}]" $dbNameTV | sponge $dbNameTV;
		fi
	else
		myPoster="";
		myID="";
                myTitle=""
		if $fetchTVmetadata; then
            myID=$(./getTVid.cgi "${myShow}");
			if [[ $myID =~ ^-?[0-9]+$ ]]; then #checks if ID is a number
                        if [[ ! -z "$TMDBapi" ]]; then
                                        myUrl="https://api.themoviedb.org/3/tv/"${myID}"/season/"${mySeason}"/episode/"${myEpisode}"?language=en&api_key="${TMDBapi}
                                        myTitle=$(curl -s --request GET --url $myUrl --data '{}' | jq -r '.name')
                                        myTitle=$(echo ${myTitle} | sed "s/'//g")
                                        myTitle=$(echo ${myTitle} | sed "s/\"//g")
                                    fi
        		myPoster=$(./getTVposter.cgi "${myID}");
        	else
            	myID=""
        		myPoster=""
        	fi
		fi
		tempPath=$(dirname $1);
        tempPath=${tempPath%/*};
        numSeasons=$(find $tempPath -mindepth 1 -type d | wc -l);
                

		printf '[\n{\n"Show": "%s",\n"ID":"%s",\n "Poster":"%s", "Seasons":"%s", "Episodes":[{"Season":"%s","Episode":"%s","Title":"%s","File":"%s"}]}]\n' "${myShow}" "${myID}" "${myPoster}" "${numSeasons}" "${mySeason}" "${myEpisode}" "${myTitle}" "${file}" >> $dbNameTV;
	fi
else
	echo -n "Unparsable "
	echo $filename
fi
