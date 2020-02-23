#!/bin/bash

MEDIA_DIR="$1"
CARD_DEV="$2"
CARD_DIR=/tmp/card

HIGH_QUALITY="raw|rw2|dng"
LOW_QUALITY="jpg|jpeg|mp4|mpeg"

cleanup() {
	set +eu
	sync
	umount -lf "${CARD_DIR}"
	rmdir "${CARD_DIR}"
}

set -euo pipefail
trap cleanup EXIT

if [ "$MEDIA_DIR" == "" ]; then
    echo "No media destination directory specified. Exiting."
    exit 128
fi

mkdir -p ${CARD_DIR}
mount "${CARD_DEV}" "${CARD_DIR}"

PIC=$(find ${CARD_DIR} -regextype posix-extended -iregex ".*\.(${LOW_QUALITY})" -print -quit)

DEVICE_NAME=$(exiftool -s -s -s -Make ${PIC})
YEAR=$(exiftool -s -s -s -d "%Y" -CreateDate ${PIC})
MONTH=$(exiftool -s -s -s -d "%m" -CreateDate ${PIC})
LOCATION=$(exiftool -s -s -s -Location ${PIC})

if [ "$YEAR" == "" ]; then
    YEAR="$(date +%Y)"
    MONTH="$(date +%m)"
fi

if [ "$LOCATION" == "" ]; then
    LOCATION="Unknown_Location"
fi

SLUG=${MEDIA_DIR}/${YEAR}/${MONTH}/${LOCATION}/${DEVICE_NAME}

mkdir -p "${SLUG}/RAW"
find ${CARD_DIR} -regextype posix-extended -iregex ".*\.(${LOW_QUALITY})" -printf %P\\0 | rsync -au --no-relative --files-from=- --from0 ${CARD_DIR}/ ${SLUG}/
find ${CARD_DIR} -regextype posix-extended -iregex ".*\.(${HIGH_QUALITY})" -printf %P\\0 | rsync -au --no-relative --files-from=- --from0 ${CARD_DIR}/ ${SLUG}/RAW/
