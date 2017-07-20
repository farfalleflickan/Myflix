#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -ne 1 ]; then
	echo "$0": usage: parseTVfilename.sh /path/to/file
	exit 1
fi

#default values, see config.cfg
dbNameTV="../dbTV.json"
fetchTVmetadata=false
regexTV1="(.*)[ .][sS]([0-9]{1})[eE]([0-9]{2})[ .](.*)"
regexTV2="(.*)[ .][sS]([0-9]{2})[eE]([0-9]{2})[ .](.*)"
regexTV3="(.*)[.]([0-9]{2})[x]([0-9]{2})[.](.*)"
regexTV4="(.*)[.]([0-9]{1})[x]([0-9]{2})[.](.*)"
TMDBapi=""
getEpisodeName=false
createTVsubs=false
. config.cfg #loads config

if [ ! -f $dbNameTV ]; then #creates the dbfile if missing
	touch $dbNameTV;
fi

file=${1#../} #removes ../ from the file path
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
				sub=""
				if $fetchTVmetadata; then
					if [[ ! -z "$TMDBapi" ]] && $getEpisodeName; then
						myID=$(jq -r "map((select(.Show == \"${myShow}\") | .ID)) | .[]" $dbNameTV)
						myUrl="https://api.themoviedb.org/3/tv/"${myID}"/season/"${mySeason}"/episode/"${myEpisode}"?language=en&api_key="${TMDBapi}
						myTitle=$(curl -s --request GET --url $myUrl --data '{}' | jq -r '.name')
						myTitle=$(echo ${myTitle} | sed "s/'//g")
						myTitle=$(echo ${myTitle} | sed "s/\"//g")
						if [[ "${myTitle}" == "null" ]]; then
							myTitle=""
						fi
					fi
					if $createTVsubs; then
						show=${1%%.mp4}
						subName=${show#../}
						if [[ -f $show".vtt" ]]; then
							sub=$subName".vtt"
						elif [[ -f $show".srt" ]]; then
							$(ffmpeg -i $show".srt" $show".vtt" 2> /dev/null )
							sub=$subName".vtt"
						fi
					fi
				fi
				jq -r "map((select(.Show == \"${myShow}\") | .Episodes) |= . + [{\"Season\":\"${mySeason}\",\"Episode\":\"${myEpisode}\",\"Title\":\"${myTitle}\",\"File\":\"${file}\",\"Subs\":[{\"subFile\":\"${sub}\", \"lang\":\"en\", \"label\":\"English\"}]}])" $dbNameTV | sponge $dbNameTV;
			fi
		else
			myPoster="";
			myID="";
			myTitle="";
			sub=""
			if $fetchTVmetadata; then
				myID=$(./getTVid.sh "${myShow}");
				if [[ $myID =~ ^-?[0-9]+$ ]]; then #checks if ID is a number
					if [[ ! -z "$TMDBapi" ]] && $getEpisodeName; then
						myUrl="https://api.themoviedb.org/3/tv/"${myID}"/season/"${mySeason}"/episode/"${myEpisode}"?language=en&api_key="${TMDBapi}
						myTitle=$(curl -s --request GET --url $myUrl --data '{}' | jq -r '.name')
						myTitle=$(echo ${myTitle} | sed "s/'//g")
						myTitle=$(echo ${myTitle} | sed "s/\"//g")
						if [[ "${myTitle}" == "null" ]]; then
							myTitle=""
						fi
					fi
					myPoster=$(./getTVposter.sh "${myID}");
				else
					myID=""
					myPoster=""
				fi
				if $createTVsubs; then
					show=${1%%.mp4}
					subName=${show#../}
					if [[ -f $show".vtt" ]]; then
						sub=$subName".vtt"
					elif [[ -f $show".srt" ]]; then
						$(ffmpeg -i $show".srt" $show".vtt" 2> /dev/null )
						sub=$subName".vtt"
					fi
				fi
			fi
			tempPath=$(dirname $1);
			tempPath=${tempPath%/*};
			numSeasons=$(find $tempPath -mindepth 1 -type d | wc -l);
			jq -r ". |= . + [{\"Show\": \"${myShow}\",\"ID\":\"${myID}\",\"Poster\":\"${myPoster}\",\"Seasons\":\"${numSeasons}\",\"Episodes\":[{\"Season\":\"${mySeason}\",\"Episode\":\"${myEpisode}\",\"Title\":\"${myTitle}\",\"File\":\"${file}\",\"Subs\":[{\"subFile\":\"${sub}\", \"lang\":\"en\", \"label\":\"English\"}]}]}]" $dbNameTV | sponge $dbNameTV;
		fi
	else
		myPoster="";
		myID="";
		myTitle=""
		sub=""
		if $fetchTVmetadata; then
			myID=$(./getTVid.sh "${myShow}");
			if [[ $myID =~ ^-?[0-9]+$ ]]; then #checks if ID is a number
				if [[ ! -z "$TMDBapi" ]] && $getEpisodeName; then
					myUrl="https://api.themoviedb.org/3/tv/"${myID}"/season/"${mySeason}"/episode/"${myEpisode}"?language=en&api_key="${TMDBapi}
					myTitle=$(curl -s --request GET --url $myUrl --data '{}' | jq -r '.name')
					myTitle=$(echo ${myTitle} | sed "s/'//g")
					myTitle=$(echo ${myTitle} | sed "s/\"//g")
					if [[ "${myTitle}" == "null" ]]; then
						myTitle=""
					fi
				fi
				myPoster=$(./getTVposter.sh "${myID}");
			else
				myID=""
				myPoster=""
			fi
			if $createTVsubs; then
				show=${1%%.mp4} #removes .mp4
				subName=${show#../} #removes ../
				if [[ -f $show".vtt" ]]; then #if vtt with same name as file already present
					sub=$subName".vtt"
				elif [[ -f $show".srt" ]]; then # else if srt with same name as file already present
					$(ffmpeg -i $show".srt" $show".vtt" 2> /dev/null ) #converts srt to vtt
					sub=$subName".vtt"
				fi
			fi
		fi
		tempPath=$(dirname $1);
		tempPath=${tempPath%/*};
		numSeasons=$(find $tempPath -mindepth 1 -type d | wc -l); #counts the number of seasons of episode by counting the first subfolders to the show folder
		printf '[\n{\n"Show": "%s",\n"ID":"%s",\n "Poster":"%s", "Seasons":"%s", "Episodes":[{"Season":"%s","Episode":"%s","Title":"%s","File":"%s","Subs":[{"subFile":"%s", "lang":"en","label":"English"}]}]}]\n' "${myShow}" "${myID}" "${myPoster}" "${numSeasons}" "${mySeason}" "${myEpisode}" "${myTitle}" "${file}" "${sub}" >> $dbNameTV;
	fi
else
	echo -n "Unparsable "
	echo $filename
fi
