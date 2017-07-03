#! /bin/bash

dbNameTV=../dbTV.json

. config.cfg

myImg=()
myImg=($(jq -r '.[].Poster' $dbNameTV))

rand=$[ $RANDOM % ${#myImg[@]} ]
printf "%s\n" ${myImg[$rand]}


