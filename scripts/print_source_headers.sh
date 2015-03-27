#!/bin/bash

find  ./sources -type f | while read f; do
	dr=`echo $f | sed 's|./sources/\(.*\)/[^/]\+.\w*$|\1|'`
	filename=$(basename "$f")
	extension="${filename##*.}"
	#echo $f
	if [ $extension == "csv" ]
		then
			#csvcut -u 0 -e UTF8 -n 
			
			echo "\"./sources/$dr/$filename\"",$(head -n 1 "./sources/$dr/$filename")
	fi
done;


