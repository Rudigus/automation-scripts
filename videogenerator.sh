#!/bin/bash
#
# This is a script to convert audio and image to video using ffmpeg
# Supports converting multiple tracks at once
#
# Dependencies: ffmpeg, exiftool

exists()
{
    command -v "$1" >/dev/null 2>&1
}

usage()
{
	echo
	echo "Video Generator - Converts audio and image to video"
	echo
	echo "Usage:"
    echo "    $(basename "$0") -a \"<audio(s)>\" -i <image>"
	echo "    $(basename "$0") -h"
}

# Main

if [ $# -eq 0 ];
then
    usage
    exit 1
fi
# Option and argument parsing
while getopts "ha:i:" opt; do
	case $opt in
        h )
			usage
			exit 0
			;;
		a )
			audio=($OPTARG)
			until [[ $(eval "echo \${$OPTIND}") =~ ^-.* ]] || [ -z $(eval "echo \${$OPTIND}") ]; do
                audio+=($(eval "echo \${$OPTIND}"))
                OPTIND=$((OPTIND + 1))
            done
			;;
		i )
			image=$OPTARG
			;;
        \? )
			usage
			exit 1
			;;
    esac
done

# Conversion processing
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
	echo
	echo "Conversion ended"
done