#!/bin/bash
#
# This is a script to convert audio and image to video using ffmpeg
# Supports converting multiple tracks at once
# Supports still and animated images
#
# Dependencies: ffmpeg, exiftool

exists()
{
    command -v "$1" >/dev/null 2>&1
}

usage()
{
	printf "\nVideo Generator - Converts audio and image to video\n"
	printf "\nUsage:\n"
    printf "    %s [-a] [-f]\n" "$(basename "$0")"
	printf "    %s -h\n" "$(basename "$0")"
	printf "\nWhere:\n"
	printf "    -a    Enables the use of animated images in the conversion\n"
	printf "    -f    If this option is supplied, overwrites video files if necessary. Otherwise, video files won't be overwritten\n"
	printf "    -h    Shows usage help\n"
}

# Main

animated=false
forced=false

# Option and argument parsing
while getopts "haf" opt; do
	case $opt in
        h )
			usage
			exit 0
			;;
		a )
			animated=true
			;;
		f )
			forced=true
			;;
		\? )
			usage
			exit 1;
			;;
    esac
done

printf "\nWelcome to the Video Generator!\n"

# Checks if ffmpeg is available
if ! exists ffmpeg; then
	printf "\nffmpeg is not installed or is inaccessible from the current directory\n"
	printf "Exiting with code 127...\n"
	exit 127;
fi

# User input
printf "\nAudio file(s): "
read audio
printf "Image file: "
read image

# Expands glob if present
if [ "$audio" != "${audio//[*]/}"  ] ; then
  audio=($audio)
fi

# Conversion processing
for track in "${audio[@]}"; do
	# Removes prefix and extension from given path
	filename="${track##*/}"
	filename="${filename%.*}"
	# Title Metadata
	title="$(exiftool -s -s -s -title "$track")"
	# Artist Metadata
	artist="$(exiftool -s -s -s -artist "$track")"
	# If possible, have a nice track filename
	if [ -n "$title" ] && [ -n "$artist" ]; then
		filename="$title - $artist"
	fi
	# Removes unwanted characters and replace them with underscore
	filename="${filename//'?'/_}"
	# Where the magic happens
	if [ "$animated" = true ]; then
		ffmpeg -i "$track" -ignore_loop 0 -i "$image" -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -shortest -strict -2 -c:v libx264 -threads 4 -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "$filename.mp4"
	else
		ffmpeg -loop 1 -i "$image" -i "$track" -shortest -r 1 -f mp4 "$filename.mp4"
	fi
	printf "\nConversion ended\n"
done