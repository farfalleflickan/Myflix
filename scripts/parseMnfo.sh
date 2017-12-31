#! /bin/bash

if [ "$#" -ne 1 ]; then
	echo "$0": usage: parseMnfo.sh /path/to/file.nfo
	exit 1
fi

cd "$(dirname "$0")"
dbNameMovie="../dbM.json"
MoviesPath=../Movies/;
. config.cfg


movie=$(xmllint --xpath "string(//title)" $1);
myID=$(xmllint --xpath "string(//id)" $1);
file=$(xmllint --xpath "string(//filenameandpath)" $1);
myPoster=$(xmllint --xpath "string(//thumb)" $1);
relPath=$(readlink -f ${MoviesPath});
file=${file/$relPath"/"/$MoviesPath};

if [ -s $dbNameMovie ]; then #checks if database is empty
	if ! grep -q ${file} $dbNameMovie; then # if the movie not already in the database
		subStr='{"subFile":"", "lang":"en","label":"English"}';
		if $createMsubs; then
			tempPath=$(dirname $file)
			sub=($(find $tempPath -name "*.srt"))
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
	file=${file#../}
	jq -r ". |= . + [{\"Movie\":\"${movie}\",\"ID\":\"${myID}\",\"Poster\":\"${myPoster}\",\"File\":\"${file}\",\"Subs\":[${subStr}]}]" $dbNameMovie | sponge $dbNameMovie;
	fi
else
	subStr='"Subs":[{"subFile":"", "lang":"en","label":"English"}'
	if $createMsubs; then
		tempPath=$(dirname $file)
		sub=($(find $tempPath -name "*.srt"))
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
	file=${file#../}
	echo -e '[{"Movie":"'"${movie}"'", "ID":"'"${myID}"'", "Poster":"'"${myPoster}"'", "File":"'"${file}"'",'"${subStr}"']}]\n' > $dbNameMovie;
fi
