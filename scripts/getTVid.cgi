#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -ne 1 ]; then
	echo "$0": usage: getTVid.cgi nameOfSeries
	exit 1
fi
TMDBapi=""

. config.cfg

if [[ ! -z "$TMDBapi" ]]; then
	show=${1}
	show=${show// /%20}
	myUrl="https://api.themoviedb.org/3/search/tv?page=1&query="${show}"&language=en&api_key="${TMDBapi}
	output=$(curl -s --request GET --url $myUrl --data '{}' | jq -r '.results[0].id')
	echo $output
else
	echo "null"
fi
