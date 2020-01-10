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

if [ -s $dbNameMovie ]; then #checks if database is empty
    if ! grep -q ${filename} $dbNameMovie; then # if the movie not already in the database
        myID="";
        subStr='{"subFile":"", "lang":"en","label":"English"}'
        myImg=""
        output="rangen_"$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)".jpg"
        movieFile=${1}

        if [ ! -d "$dMoFolder" ]; then
                mkdir $dMoFolder
        fi

        durationTime=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $movieFile)
        durationTime=${durationTime%.*}
        halfTime=$((durationTime/2))
        $(ffmpeg -ss $halfTime -i $movieFile -vframes 1 -q:v 3 $dMoFolder$output 2> /dev/null);
        if [ ${#AutogenImgResizeMo[@]} -gt 0 ]; then
                convert "${AutogenImgResizeMo[@]}" $dMoFolder$output $dMoFolder$output
        fi
        if $compressImgMo; then
                convert -strip -interlace Plane -gaussian-blur 0.05 -quality 90% $dMoFolder$output $dMoFolder$output
        fi
        if [[ ! -z "$tinyPNGapi" ]]; then
            imgUrl=$(curl -s --user api:$tinyPNGapi  --data-binary @$dMoFolder$output https://api.tinify.com/shrink | jq -r '.output.url')
            curl -s --user api:$tinyPNGapi --output $dMoFolder$output $imgUrl
        fi
        chmod 755 -R $dMoFolder
        tempFolder=$(basename $dMoFolder)
        myImg=$tempFolder"/"$output;
        
        if [[ "${filename}" =~ ${regexHM} ]]; then
            myID=${BASH_REMATCH[0]}; # movie name matches 1st regex match            
        fi
        jq -r ". |= . + [{\"Movie\":\"${filename}\",\"ID\":\"${myID}\",\"Poster\":\"${myImg}\",\"File\":\"${file}\",\"Subs\":[${subStr}]}]" $dbNameMovie | sponge $dbNameMovie;
    fi
else
    myID="";
    subStr='"Subs":[{"subFile":"", "lang":"en","label":"English"}'
    myImg=""
    output="rangen_"$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)".jpg"
    movieFile=${1}

    if [ ! -d "$dMoFolder" ]; then
            mkdir $dMoFolder
    fi

    durationTime=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $movieFile)
    durationTime=${durationTime%.*}
    halfTime=$((durationTime/2))
    $(ffmpeg -ss $halfTime -i $movieFile -vframes 1 -q:v 3 $dMoFolder$output 2> /dev/null);
    if [ ${#AutogenImgResizeMo[@]} -gt 0 ]; then
            convert "${AutogenImgResizeMo[@]}" $dMoFolder$output $dMoFolder$output
    fi
    if $compressImgMo; then
            convert -strip -interlace Plane -gaussian-blur 0.05 -quality 90% $dMoFolder$output $dMoFolder$output
    fi
    if [[ ! -z "$tinyPNGapi" ]]; then
        imgUrl=$(curl -s --user api:$tinyPNGapi  --data-binary @$dMoFolder$output https://api.tinify.com/shrink | jq -r '.output.url')
        curl -s --user api:$tinyPNGapi --output $dMoFolder$output $imgUrl
    fi
    chmod 755 -R $dMoFolder
    tempFolder=$(basename $dMoFolder)
    myImg=$tempFolder"/"$output;
    
    if [[ "${filename}" =~ ${regexHM} ]]; then
        myID=${BASH_REMATCH[0]}; # movie name matches 1st regex match            
    fi
    echo -e '[{"Movie":"'"${filename}"'", "ID":"'"${myID}"'", "Poster":"'"${myImg}"'", "File":"'"${file}"'",'"${subStr}"']}]\n' > $dbNameMovie;
fi
