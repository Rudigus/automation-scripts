#!/bin/bash
#
# This converts a whole folder .wav files to .mp3
# Just execute this script inside the folder with the .wav files
#
# Dependencies: ffmpeg

for i in *.wav; do ffmpeg -i "$i" -acodec libmp3lame "${i%.*}.mp3"; done