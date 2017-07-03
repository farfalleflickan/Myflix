#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -eq 0 ]; then
    echo "$0": usage: parseMfilename.cgi /path/to/file
    exit 1
fi

dbNameMovie="../dbM.json"
regexM="(.*)[.](.*)";

. config.cfg
if [ ! -f $dbNameMovie ]; then
    touch $dbNameMovie;
fi

file=${1#../}
filename=$(basename "$file")
if [[ "${filename}" =~ ${regexM} ]]; then
    movie=${BASH_REMATCH[1]};
    if [ -s $dbNameMovie ]; then
		if ! grep -q ${file} $dbNameMovie; then
			myPoster="";
			
			if [[ $movie == *"Departures"* ]]; then
            	myID="1069238";
        	elif [[ $movie == *"Pilgrim"* ]]; then
            	myID="0446029";
			elif [[ $movie == *"Guide.to.the.Galaxy"*  ]]; then
				myID="0371724";
        	else
            	myID=$(./getMid.cgi "${movie}");
        	fi

            if [[ $myID =~ ^-?[0-9]+$ ]]; then #checks if ID is a number
               	myPoster=$(./getMposter.cgi "${myID}");
            else
               	myID=""
                myPoster=""
            fi
			jq -r ". |= . + [{\"Movie\":\"${movie}\",\"ID\":\"${myID}\",\"Poster\":\"${myPoster}\",\"File\":\"${file}\"}]" $dbNameMovie | sponge $dbNameMovie;
            #printf '{"Movie":"%s", "ID":"%s", "Poster":"%s", "File":"%s"},\n' "${movie}" "${myID}" "${myPoster}" "${file}" >> $dbNameMovie;
        fi
	else
    	myPoster="";
		if [[ $movie == *"Departures"* ]]; then
			myID="1069238";
		elif [[ $movie == *"Pilgrim"* ]]; then
			myID="0446029";
		else
			myID=$(./getMid.cgi "${movie}");
		fi

        if [[ $myID =~ ^-?[0-9]+$ ]]; then #checks if ID is a number
			myPoster=$(./getMposter.cgi "${myID}");
        else
          	myID=""
          	myPoster=""
        fi
        printf '[{"Movie":"%s", "ID":"%s", "Poster":"%s", "File":"%s"}]\n' "${movie}" "${myID}" "${myPoster}" "${file}" > $dbNameMovie;
	fi
else
        echo -n "Unparsable "
        echo $filename
fi


