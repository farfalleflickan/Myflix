#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -eq 0 ]; then
	echo "$0": usage: getTVposter.cgi ID
	exit 1
fi

dTVImg=false
dTVFolder=../TVimg/
imgResizeTV="300x"
tinyPNGapi=""
TVDBapi=""
compressImgTV=false

. config.cfg
ID=${1}

if [[ ! -z $TVDBapi ]]; then
	output=$(curl -s http://thetvdb.com/api/$TVDBapi/series/$ID/banners.xml | grep -B 1 "<BannerType>poster</BannerType>" | head -n1 )
	output=${output#*>}
	output=${output%<*}

	if $dTVImg; then
		if [ ! -d "$dTVFolder" ]; then
			mkdir $dTVFolder
		fi
		wget -q -P $dTVFolder "https://thetvdb.com/banners/"$output;
		output=${output##*posters/}
		if [ ! -z "$imgResizeTV" ]; then
			convert $dTVFolder$output -resize $imgResizeTV $dTVFolder$output
		fi
		if $compressImgTV; then
			convert -strip -interlace Plane -gaussian-blur 0.05 -quality 85% $dTVFolder$output $dTVFolder$output
		fi
		if [[ ! -z "$tinyPNGapi" ]]; then
			imgUrl=$(curl -s --user api:$tinyPNGapi  --data-binary @$dTVFolder$output https://api.tinify.com/shrink | jq -r '.output.url')
			curl -s --user api:$tinyPNGapi --output $dTVFolder$output $imgUrl
		fi
		chmod 755 -R $dTVFolder
		tempFolder=$(basename $dTVFolder)
		echo $tempFolder"/"$output;
	else
		echo "https://thetvdb.com/banners/"$output
	fi
fi
