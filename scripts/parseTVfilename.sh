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

file=${1#../} #removes ../ from the file path
filename=$(basename "$file")
if [[ "${filename}" =~ ${regexTV1} ]] || [[ "${filename}" =~ ${regexTV2} ]] || [[ "${filename}" =~ ${regexTV3} ]] || [[ "${filename}" =~ ${regexTV4} ]]; then
	myShow=${BASH_REMATCH[1]};
	myShow=${myShow//./ }
	mySeason=${BASH_REMATCH[2]};
	myEpisode=${BASH_REMATCH[3]};
	if [ -s $dbNameTV ]; then
		if grep -q "\"Show\": \"${myShow}\"" $dbNameTV; then
			myTitle=""
			sub=""
			subStr='{"subFile":"", "lang":"en","label":"English"}'
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
					show=${1%%.mp4} #removes .mp4
					subName=${show#../} #removes ../
					subName=$(basename "$subName")
					tempPath=$(dirname $1)
					tempPath=$tempPath"/"
					sub=($(find $tempPath -name $subName"*.srt"))
					if [ "${#sub[@]}" -ge 1 ]; then
						subStr=''; 
					fi
					counter=0;
					for tempSub in "${sub[@]}"; do
						if  [ $counter -ge 1 ]; then
							subStr+=","
						fi
						tempSubNoExt="${tempSub%.*}"
						if [[ -f $tempSubNoExt".vtt" ]]; then
							lang="${tempSubNoExt##*_}"
							if [ $lang == $tempSubNoExt ]; then
								lang="en";
							fi
							tempSub=$tempSubNoExt".vtt"
							tempSub=${tempSub#../}
							subStr+='{"subFile":"'"${tempSub}"'", "lang":"'"${lang}"'","label":"'"${lang}"'"}'
						else
							if [[ -f $tempSub ]]; then
								$(ffmpeg -i $tempSub $tempSubNoExt".vtt" 2> /dev/null )
								lang="${tempSubNoExt##*_}"
								if [ $lang == $tempSubNoExt ]; then
									lang="en";
								fi
								tempSub=$tempSubNoExt".vtt"
								tempSub=${tempSub#../}
								subStr+='{"subFile":"'"${tempSub}"'", "lang":"'"${lang}"'","label":"'"${lang}"'"}'
							fi
						fi
						((counter++))
					done
				fi
			fi
			jq -r "map((select(.Show == \"${myShow}\") | .Episodes) |= . + [{\"Season\":\"${mySeason}\",\"Episode\":\"${myEpisode}\",\"Title\":\"${myTitle}\",\"File\":\"${file}\",\"Subs\":[${subStr}]}])" $dbNameTV | sponge $dbNameTV;
		else
			myPoster="";
			myID="";
			myTitle="";
			sub=""
			subStr='{"subFile":"", "lang":"en","label":"English"}'
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
					subName=$(basename "$subName")
					tempPath=$(dirname $1)
					tempPath=$tempPath"/"
					sub=($(find $tempPath -name $subName"*.srt"))
					if [ "${#sub[@]}" -ge 1 ]; then
						subStr=''; 
					fi
					counter=0;
					for tempSub in "${sub[@]}"; do
						if  [ $counter -ge 1 ]; then
							subStr+=","
						fi
						tempSubNoExt="${tempSub%.*}"
						if [[ -f $tempSubNoExt".vtt" ]]; then
							lang="${tempSubNoExt##*_}"
							if [ $lang == $tempSubNoExt ]; then
								lang="en";
							fi
							tempSub=$tempSubNoExt".vtt"
							tempSub=${tempSub#../}
							subStr+='{"subFile":"'"${tempSub}"'", "lang":"'"${lang}"'","label":"'"${lang}"'"}'
						else
							if [[ -f $tempSub ]]; then
								$(ffmpeg -i $tempSub $tempSubNoExt".vtt" 2> /dev/null )
								lang="${tempSubNoExt##*_}"
								if [ $lang == $tempSubNoExt ]; then
									lang="en";
								fi
								tempSub=$tempSubNoExt".vtt"
								tempSub=${tempSub#../}
								subStr+='{"subFile":"'"${tempSub}"'", "lang":"'"${lang}"'","label":"'"${lang}"'"}'
							fi
						fi
						((counter++))
					done
				fi
			fi
			tempPath=$(dirname $1);
			tempPath=${tempPath%/*};
			numSeasons=$(find $tempPath -mindepth 1 -type d | wc -l);
			jq -r ". |= . + [{\"Show\": \"${myShow}\",\"ID\":\"${myID}\",\"Poster\":\"${myPoster}\",\"Seasons\":\"${numSeasons}\",\"Episodes\":[{\"Season\":\"${mySeason}\",\"Episode\":\"${myEpisode}\",\"Title\":\"${myTitle}\",\"File\":\"${file}\",\"Subs\":[${subStr}]}]}]" $dbNameTV | sponge $dbNameTV;
		fi
	else
		myPoster="";
		myID="";
		myTitle=""
		sub=""
		subStr='"Subs":[{"subFile":"", "lang":"en","label":"English"}'
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
				subName=$(basename "$subName")
				tempPath=$(dirname $1)
				tempPath=$tempPath"/"
				sub=($(find $tempPath -name $subName"*.srt"))
				if [ "${#sub[@]}" -ge 1 ]; then
					subStr='"Subs":['; 
				fi
				counter=0;
				for tempSub in "${sub[@]}"; do
					if  [ $counter -ge 1 ]; then
						subStr+=","
					fi
					tempSubNoExt="${tempSub%.*}"
					if [[ -f $tempSubNoExt".vtt" ]]; then
						lang="${tempSubNoExt##*_}"
						if [ $lang == $tempSubNoExt ]; then
							lang="en";
						fi
						tempSub=$tempSubNoExt".vtt"
						tempSub=${tempSub#../}
						subStr+='{"subFile":"'"${tempSub}"'", "lang":"'"${lang}"'","label":"'"${lang}"'"}'
					else
						if [[ -f $tempSub ]]; then
							$(ffmpeg -i $tempSub $tempSubNoExt".vtt" 2> /dev/null )
							lang="${tempSubNoExt##*_}"
							if [ $lang == $tempSubNoExt ]; then
								lang="en";
							fi
							tempSub=$tempSubNoExt".vtt"
							tempSub=${tempSub#../}
							subStr+='{"subFile":"'"${tempSub}"'", "lang":"'"${lang}"'","label":"'"${lang}"'"}'
						fi
					fi
					((counter++))
				done
			fi
		fi
		tempPath=$(dirname $1);
		tempPath=${tempPath%/*};
		numSeasons=$(find $tempPath -mindepth 1 -type d | wc -l); #counts the number of seasons of episode by counting the first subfolders to the show folder
		echo -e '[\n{\n"Show": "'"${myShow}"'",\n"ID":"'"${myID}"'",\n "Poster":"'"${myPoster}"'", "Seasons":"'"${numSeasons}"'", "Episodes":[{"Season":"'"${mySeason}"'","Episode":"'"${myEpisode}"'","Title":"'"${myTitle}"'","File":"'"${file}"'",'"${subStr}"']}]}]\n' >> $dbNameTV;
	fi
else
	echo -n "Unparsable "
	echo $filename
fi
