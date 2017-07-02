#! /bin/bash

cd "$(dirname "$0")"
if [ "$#" -eq 0 ]; then
    echo "$0": usage: getMposter.cgi ID
    exit 1
fi

id=${1};
output=$(curl -s http://www.imdb.com/title/tt"$id"/ | sed -n '/<div class="poster">/,$p' | sed -n '/src/p' | head -1);
output=${output#src=\"};
if [[ $output == *"@"* ]]; then
	output=${output%@*.jpg\"};
	output="$output@.jpg";
else
	output=${output%._*.jpg\"};
    output="$output.jpg";
fi
echo $output
