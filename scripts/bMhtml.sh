#! /bin/bash

cd "$(dirname "$0")"
dbNameMovie="../dbM.json"
Mhtml=../Movies.html
dMoImg=false
dMoFolder=../MoImg/
imgResizeMo="-resize 500x"
tinyPNGapi=""
compressImgMo=false
. config.cfg

printf "<!DOCTYPE html>\n<html>\n<head>\n<title>Myflix</title>\n<meta http-equiv=\"Content-type\" content=\"text/html\;charset=UTF-8\">\n<meta name=\"description\" content=\"Daria Rostirolla\">\n<meta name=\"keywords\" content=\"HTML, CSS\">\n<meta name=\"author\" content=\"Daria Rostirolla\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n<link href=\"css/movie.css\" rel=\"stylesheet\" type=\"text/css\">\n<link rel=\"icon\" type=\"image/png\" href=\"img/favicon.png\">\n</head>\n<body>\n<script async type=\"text/javascript\" src=\"js/Mcript.js\"></script><div id=\"wrapper\">" > $Mhtml 
#html specific id given to elements 
# A+myID identifies the movie's "input button"
# B+myID identifies the movie's modal
# C+myID identifies the movie's video player
myID=1
IFS=$'\n'
MovieList=$(jq -r '.[].Movie' $dbNameMovie); #puts all movie titles in "MovieList variable
for i in $MovieList; do #loops through every movie in the database
	myImg=$(jq -r "map(select(.Movie==\"${i}\") .Poster) | .[]" $dbNameMovie)
	if [[ $myImg != *".jpg"*  ]]; then
		echo -e "Please note, \"""${i}""\" does NOT have a poster!\nGenerating one...";
		myImg=""

		output="rangen_"$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)".jpg"
		currentFile=$(jq -r "map(select(.Movie==\"${i}\") .File) | .[]" $dbNameMovie)
		movieFile="../"$currentFile

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
		$(./fixFile.sh $currentFile $myID $myImg);
	fi
	myFile=$(jq -r "map(select(.Movie==\"${i}\") .File) | .[]" $dbNameMovie)
	mySub=($(jq -r "map(select(.Movie==\"${i}\") .Subs[].subFile) | .[]" $dbNameMovie))
	mySubNum=${#mySub[@]}
	myAlt=$(echo ${i} | sed "s/'//")
	htmlStr="<div class=\"movieDiv\">\n"
	tempHtml=""
	tempHtmlStr=""
	if [ $mySubNum -ge 1 ]; then
		tempIndex=0;
		while [ $tempIndex -lt $mySubNum ]; do
			myLang=($(jq -r "map(select(.Movie==\"${i}\") .Subs[${tempIndex}].lang) | .[]" $dbNameMovie));
			myLabel=($(jq -r "map(select(.Movie==\"${i}\") .Subs[${tempIndex}].lang) | .[]" $dbNameMovie));
			if [ $tempIndex -eq 0 ]; then
            	tempHtml+="\n<track src='' kind=\"subtitles\" srclang=\"${myLang}\" label=\"${myLabel}\" default>";
            else
            	tempHtml+="\n<track src='' kind=\"subtitles\" srclang=\"${myLang}\" label=\"${myLabel}\">";
            fi
			tempHtmlStr+=${mySub[${tempIndex}]}"," #path to the sub, to be fed to JS function that loads it in if needed
			((tempIndex++))
		done
		htmlStr+="<input id=\"A${myID}\" class=\"myBtn\" value=\"\" onclick=\"javascript:showModalsetSubs(this, '"${tempHtmlStr}"')\" type=\"image\" src=\"${myImg}\" onload=\"javascript:setAlt(this, '${myAlt}')\">"
	else
		htmlStr+="<input id=\"A${myID}\" class=\"myBtn\" value=\"\" onclick=\"javascript:showModal(this)\" type=\"image\" src=\"${myImg}\" onload=\"javascript:setAlt(this, '${myAlt}')\">"
	fi
	htmlStr+="\n<div id=\"B${myID}\" class=\"modal\">\n<div class=\"modal-content\">\n<video id=\"C${myID}\" class=\"video_player\" controls preload=\"none\">\n<source src=\"${myFile}\" type=\"video/mp4\">";
	htmlStr+=$tempHtml;
	htmlStr+="\n</video>\n<span onclick=\"javascript:hideModal()\" class=\"close\">&times;</span>\n";
	htmlStr+="</div>\n</div>\n</div>";
	echo -e $htmlStr >> $Mhtml;
	htmlStr="";
	((myID++));
done
echo -e '\n<div id="paddingDiv">\n</div>\n</div>\n</body>\n</html>' >> $Mhtml
chmod 755 $Mhtml
