#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -eq 0 ]; then
    echo "$0": usage: getTVposter.cgi ID
    exit 1
fi

dTVImg=false
dTVFolder=../TVimg/
imgResizeTV="300x"

. config.cfg
ID=${1}
output=$(curl -s http://thetvdb.com/api/145AA2538B931320/series/$ID/banners.xml | grep -B 1 "<BannerType>poster</BannerType>" | head -n1 )
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
	chmod 755 -R $dTVFolder
	tempFolder=$(basename $dTVFolder)
	echo $tempFolder"/"$output;
else
	echo "https://thetvdb.com/banners/"$output
fi
