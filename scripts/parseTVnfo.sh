#! /bin/bash

cd "$(dirname "$0")"
dbNameTV="../dbTV.json"
TVpath=../TV/;
. config.cfg

if ! grep -q "<episodedetails>" $1; then # $1 is NOT a episode file, but a tv show file...
	myShow=$(xmllint --xpath "string(//title)" $1);
    myID=$(xmllint --xpath "string(//id)" $1);
    myPoster=$(xmllint --xpath "string(//thumb)" $1);
    numSeasons=$(xmllint --xpath "string(//season)" $1);
	if [ -s $dbNameTV ]; then
		if ! grep -q "\"Show\": \"${myShow}\"" $dbNameTV; then
			jq -r ". |= . + [{\"Show\":\"${myShow}\",\"ID\":\"${myID}\",\"Poster\":\"${myPoster}\",\"Seasons\":\"${numSeasons}\",\"Episodes\":[]}]" $dbNameTV | sponge $dbNameTV;
		fi
	else
		echo -e '[\n{\n"Show": "'"${myShow}"'",\n"ID":"'"${myID}"'",\n "Poster":"'"${myPoster}"'", "Seasons":"'"${numSeasons}"'", "Episodes":[]}]\n' >> $dbNameTV;
	fi
else
	myShow=$(xmllint --xpath "string(//showtitle)" $1);
	myTitle=$(xmllint --xpath "string(//title)" $1);
	mySeason=$(xmllint --xpath "string(//season)" $1);
	myEpisode=$(xmllint --xpath "string(//episode)" $1);
	file=$(xmllint --xpath "string(//filenameandpath)" $1);
	relPath=$(readlink -f ${TVpath});
	file=${file/$relPath"/"/$TVpath};
	subStr='{"subFile":"", "lang":"en","label":"English"}'
	
	if $createTVsubs; then
		show=${file%%.mp4} #removes .mp4
		subName=${show#../} #removes ../
		subName=$(basename "$subName")
		tempPath=$(dirname $file)
		tempPath=$tempPath"/"
		sub=($(find $tempPath -name $subName"*.srt"))
		if [ "${#sub[@]}" -ge 1 ]; then
			subStr='';
		fi
		counter=0;
		for tempSub in "${sub[@]}"; do
			if [ $counter -ge 1 ]; then
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
	file=${file#../}
	jq -r "map((select(.Show == \"${myShow}\") | .Episodes) |= . + [{\"Season\":\"${mySeason}\",\"Episode\":\"${myEpisode}\",\"Title\":\"${myTitle}\",\"File\":\"${file}\",\"Subs\":[${subStr}]}])" $dbNameTV | sponge $dbNameTV;
fi
