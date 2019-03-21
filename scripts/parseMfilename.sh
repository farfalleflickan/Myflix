#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -ne 1 ]; then
	echo "$0": usage: parseMfilename.sh /path/to/file
	exit 1
fi

#default values, see config.cfg
dbNameMovie="../dbM.json"
regexM="(.*)[.](.*)";
fetchMmetadata=false
createMsubs=false
. config.cfg

if [ ! -f $dbNameMovie ]; then #creates db if missing
	touch $dbNameMovie;
fi

file=${1#../}
filename=$(basename "$file")
if [[ "${filename}" =~ ${regexM} ]]; then #if filename matches regex then it's a movie we want to work on!
	movie=${BASH_REMATCH[1]}; # movie name matches 1st regex match
	if [ -s $dbNameMovie ]; then #checks if database is empty
		if ! grep -q ${filename} $dbNameMovie; then # if the movie not already in the database
			myPoster="";
                        subStr='{"subFile":"", "lang":"en","label":"English"}'
			if $fetchMmetadata; then
				myID=$(./getMid.sh "${movie}");

				if [[ $myID =~ ^-?[0-9]+$ ]]; then #checks if ID is a number
					myPoster=$(./getMposter.sh "${myID}"); #fetches poster for ID
				else
					myID=""
					myPoster=""
				fi
				if $createMsubs; then
					tempPath=$(dirname $file)
					tempPath="../"$tempPath"/"
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
			fi
			movie=${movie//./ }
			jq -r ". |= . + [{\"Movie\":\"${movie}\",\"ID\":\"${myID}\",\"Poster\":\"${myPoster}\",\"File\":\"${file}\",\"Subs\":[${subStr}]}]" $dbNameMovie | sponge $dbNameMovie;
		fi
	else
		myPoster="";
		subStr='"Subs":[{"subFile":"", "lang":"en","label":"English"}'
		if $fetchMmetadata; then
			if [[ $movie == *"Departures"* ]]; then
				myID="1069238";
			elif [[ $movie == *"Pilgrim"* ]]; then
				myID="0446029";
			elif [[ $movie == *"Guide.to.the.Galaxy"*  ]]; then
				myID="0371724";
			else
				myID=$(./getMid.sh "${movie}");
			fi

			if [[ $myID =~ ^-?[0-9]+$ ]]; then #checks if ID is a number
				myPoster=$(./getMposter.sh "${myID}");
			else
				myID=""
				myPoster=""
			fi
			if $createMsubs; then
				tempPath=$(dirname $file)
				tempPath="../"$tempPath"/"
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
		fi
		movie=${movie//./ }
		echo -e '[{"Movie":"'"${movie}"'", "ID":"'"${myID}"'", "Poster":"'"${myPoster}"'", "File":"'"${file}"'",'"${subStr}"']}]\n' > $dbNameMovie;
	fi
else	#regex had no matches
	echo -n "Unparsable "
	echo $filename
fi
