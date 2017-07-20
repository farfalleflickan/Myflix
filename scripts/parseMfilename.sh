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
		if ! grep -q ${file} $dbNameMovie; then # if the movie not already in the database
			myPoster="";
			if $fetchMmetadata; then
				if [[ $movie == *"Departures"* ]]; then #hardcoded id's for movies
					myID="1069238";
				elif [[ $movie == *"Pilgrim"* ]]; then
					myID="0446029";
				elif [[ $movie == *"Guide.to.the.Galaxy"*  ]]; then
					myID="0371724";
				else
					myID=$(./getMid.sh "${movie}");
				fi

				if [[ $myID =~ ^-?[0-9]+$ ]]; then #checks if ID is a number
					myPoster=$(./getMposter.sh "${myID}"); #fetches poster for ID
				else
					myID=""
					myPoster=""
				fi
				if $createMsubs; then 
					tempPath=$(dirname $file)"/" 
					searchPath="../"$tempPath"/"
					sub=""
					if [[ -f $searchPath$movie".vtt" ]]; then #if sub is already present
						sub=$tempPath$movie".vtt"
					else
						sub=$(find $searchPath -name "*.srt") #searches for a srt in same folder as movie
						if [[ -f $sub ]]; then
							$(ffmpeg -i $sub $searchPath$movie".vtt" 2> /dev/null ) #converts srt to vtt
							sub=$tempPath$movie".vtt" 
						fi
					fi
				fi
			fi
			movie=${movie//./ }
			jq -r ". |= . + [{\"Movie\":\"${movie}\",\"ID\":\"${myID}\",\"Poster\":\"${myPoster}\",\"File\":\"${file}\",\"Subs\":[{\"subFile\":\"${sub}\", \"lang\":\"en\", \"label\":\"English\"}]}]" $dbNameMovie | sponge $dbNameMovie;
		fi
	else
		myPoster="";
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
				sub=""
				if [[ -f $tempPath$movie".vtt" ]]; then
					sub=$tempPath$movie".vtt"
				else
					sub=$(find $tempPath -name "*.srt")
					if [[ -f $sub ]]; then
						$(ffmpeg -i $sub $tempPath$movie".vtt" 2> /dev/null )
						sub=$tempPath$movie".vtt"
					fi
				fi
			fi
		fi
		movie=${movie//./ }
		printf '[{"Movie":"%s", "ID":"%s", "Poster":"%s", "File":"%s", "Subs":[{"subFile":"%s", "lang":"en","label":"English"}]}]\n' "${movie}" "${myID}" "${myPoster}" "${file}" "${sub}"  > $dbNameMovie;
	fi
else	#regex had no matches
	echo -n "Unparsable "
	echo $filename
fi
