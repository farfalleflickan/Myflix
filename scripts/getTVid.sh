#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -ne 1 ]; then
	echo "$0": usage: getTVid.sh name Of Series
	exit 1
fi
TMDBapi=""
. config.cfg

#checks if the TMDB api is set...
if [[ ! -z "$TMDBapi" ]]; then
	show=${1} 
	show=${show// /%20} #spaces to html spaces
	myUrl="https://api.themoviedb.org/3/search/tv?page=1&query="${show}"&language=en&api_key="${TMDBapi}
	#curl fetch the return json, piped into jq that grabs the id of the first result (0)
	output=$(curl -s --request GET --url $myUrl | jq -r '.results[0].id')
	echo $output
else
	echo "null"
fi
