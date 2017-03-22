#!/bin/sh

function usage () {
  echo USAGE: $0 input-filename start-time duration output-filename '[--test]'
  echo '    start-time: the timestamp of the start of the clip  [[hh:]mm:]ss[.dddd]'
  echo '    duration:   the duration of the clip in seconds     ss[.dddd]'
}

[ $# -lt 4 ] && usage && exit
[ $# -gt 5 ] && usage && exit
if [ $# -eq 5 ]; then
  ffmpeg -ss $2 -i $1 -t $3 -c copy $4
  exit
fi

# bc required to handle fractional second arithmatic.
outtime=`echo "$3 - 1" | bc`
ffmpeg -ss "$2" -i "$1" -t "$3" -vf fade=t=in:d=1,fade=t=out:st="$outtime":d=1 -af afade=t=in:d=1,afade=t=out:st="$outtime":d=1 "$4"

