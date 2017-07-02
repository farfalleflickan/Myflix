#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -eq 0 ]; then
    echo "$0": usage: getTVposter.cgi ID
    exit 1
fi

downloadImg=false
downloadFolder=../TVimg/
imgSize="300x"

. config.cfg
ID=${1}
output=$(curl -s http://thetvdb.com/api/145AA2538B931320/series/$ID/banners.xml | grep -B 1 "<BannerType>poster</BannerType>" | head -n1 )
output=${output#*>}
output=${output%<*}

if $downloadImg; then
	wget -q -P ../TVimg/ "https://thetvdb.com/banners/"$output;
	output=${output##*posters/}
	convert $downloadFolder$output -resize $imgSize $downloadFolder$output
	chmod 755 -R ../TVimg/
	echo "TVimg/"$output;
else
	echo "https://thetvdb.com/banners/"$output
fi
