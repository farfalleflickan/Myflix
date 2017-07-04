#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -eq 0 ]; then
	echo "$0": usage: getTVid.cgi nameOfSeries
	exit 1
fi

show=${1}
show=${show// /%20}
output=$(curl -s "http://thetvdb.com/api/GetSeries.php?seriesname=\""${show}"\"" | grep "<seriesid>" | head -n1)
output=${output#*>}
output=${output%<*}
echo $output
