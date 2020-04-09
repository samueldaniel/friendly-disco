#!/usr/bin/env bash
ARGS=""
TURBO=false
SIZE=64
DELAY=10

USAGE=<< EOF
party time! excellent!
EOF

while (( "$#" )); do
  case "$1" in
    -t|--turbo)
      TURBO=true
      shift
      ;;
    -s|--size)
      SIZE=$2
      shift 2
      ;;
    -d|--delay)
      DELAY=$2
      shift 2
      ;;
    -h|--help)
      echo "${USAGE}"
      exit 1
      ;;
    -*|--*=)  # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *)
      ARGS="$ARGS $1"
      shift
      ;;
  esac
done
eval set -- "$ARGS"

ARGS_ARR=($ARGS)
IMGFILE=${ARGS_ARR[0]}
FNAME="${IMGFILE%%.*}"

for ROT in `seq -f %03.0f 0 5 200`; do
  convert ${IMGFILE} -modulate 100,100,${ROT} rot_${ROT}_${IMGFILE}
done

for ROT in `seq -f %03.0f 0 5 200`; do
  mogrify -resize ${SIZE}x${SIZE} rot_${ROT}_${IMGFILE}
done

if [[ "$TURBO" == true ]]; then
  DEGREES=15
  for ROT in rot_*_${IMGFILE}; do
    convert ${ROT} -background 'rgba(0,0,0,0)' -rotate ${DEGREES} ${ROT}
    DEGREES=$((DEGREES + 15))
  done
fi

convert -dispose Background -loop 0 -delay ${DELAY} -coalesce -layers OptimizeFrame rot_*_${IMGFILE} $FNAME.gif

for ROT in `seq -f %03.0f 0 5 200`; do
  rm rot_${ROT}_${IMGFILE}
done
