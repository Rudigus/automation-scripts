#!/bin/bash
# This is a script to convert audio to video (with a still image) using ffmpeg
# Dependencies: ffmpeg, exiftool

echo "Audio file(s): "
read audio
echo "Image file: "
read image
# Supports converting multiple tracks
for track in $audio; do 
	# Removes prefix and extension from given path
	filename="${track##*/}"
	filename="${filename%.*}"
	# Title Metadata
	title="$(exiftool -s -s -s -title $track)"
	# Artist Metadata
	artist="$(exiftool -s -s -s -artist $track)"
	# If possible, have a nice track filename
	if [ -n "$title" ] && [ -n "$artist" ]
	then
		filename="$title - $artist"
	fi
	# Removes unwanted characters and replace them with underscore
	filename="${filename//'?'/_}"
	# Where the magic happens
	ffmpeg -loop 1 -i $image -i $track -shortest -f mp4 "$filename.mp4"
done
