#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -eq 0 ]; then
    echo "$0": usage: getMposter.cgi ID
    exit 1
fi

dMoImg=false
dMoFolder=../MoImg/
imgResizeMo="300x"

. config.cfg

id=${1};
myUrl="https://api.themoviedb.org/3/movie/tt"${id}"/images?include_image_language=en&api_key=20eea39bfb9a68dd37efc7ac9836c5ab"
output=$(curl -s --request GET --url $myUrl --data '{}' | jq -r '.posters | map(select((.width | contains(1000)) and (.height | contains(1500))) | .file_path) | .[]' | head -n1)

if [[ $output == *".jpg"* ]]; then
	output="https://image.tmdb.org/t/p/original"$output;
else
	output="null"
	exit
fi

if $dMoImg; then
    if [ ! -d "$dMoFolder" ]; then
        mkdir $dMoFolder
    fi
    wget -q -P $dMoFolder $output;
    output=$(basename $output)
    if [ ! -z "$imgResizeMo" ]; then
        convert $dMoFolder$output -resize $imgResizeMo $dMoFolder$output
    fi
    chmod 755 -R $dMoFolder
	tempFolder=$(basename $dMoFolder)
    echo $tempFolder"/"$output;
else
    echo $output
fi


