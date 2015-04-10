#!/bin/bash

find  ./sources -type f | while read f; do
	
	dr=`echo $f | sed 's|./sources/\(.*\)/[^/]\+.\w*$|\1|'`
	filename=$(basename "$f")
	extension="${filename##*.}"
	#echo $f
	if [ $extension == "csv" ]
		then
			if grep --quiet -P ",\"\d+,\d+\"" "$f" 
			then
				# there are some float delimited by coma
				#let's change that to dot separator
				echo "replacing coma float separator by dot separator "$f
				sed -r 's|,\"([0-9]+),([0-9]+)\"|,\1.\2|' "$f" > no_coma_in_integer.csv
				mv no_coma_in_integer.csv "$f"
			fi
				#echo $f" ordered"
			csvsort  -c SourceType,year,exportsimports,numrodeligne,marchandises,pays "$f" > last_ordered.csv
			if [ `echo $?` == 0 ] 
			then
				mv last_ordered.csv "$f"
				echo $f" ordered"
			else
				rm last_ordered.csv
				echo "couldn't order "$f
			fi
			# else
			# 	echo $f" dont order"
			# fi
	# 		#csvcut -u 0 -e UTF8 -n 
				
	# 		echo "\"./sources/$dr/$filename\"",$(head -n 1 "./sources/$dr/$filename")
	fi
done;
