#!/bin/bash
if [ -d ./sources ];
then rm -rf ./sources;
else mkdir sources;
fi

find  ./excel_sources -type f | while read f; do
	dr=`echo $f | sed 's|./excel_sources/\(.*\)/[^/]\+.\w*$|\1|'`
	filename=$(basename "$f")
	extension="${filename##*.}"
	echo $f
	mkdir -p "./sources/$dr"
	case $extension in  
		ods | xls | xlsx) unoconv -f csv -o "./sources/$dr/" "$f";; 
		csv | txt) iconv -f MAC -t UTF8 -o "./sources/$dr/$filename" "$f";;
		docx | doc) unoconv -f txt -o "./sources/$dr/" "$f";;
	esac
done;


