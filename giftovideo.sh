#!/bin/bash
# This is a script to convert audio to video (with a gif) using ffmpeg
# Dependencies: ffmpeg, exiftool

echo "Audio file(s): "
read audio
echo "GIF file: "
read gif
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
  	ffmpeg -i $track -ignore_loop 0 -i $gif -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -shortest -strict -2 -c:v libx264 -threads 4 -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "$filename.mp4"
done
