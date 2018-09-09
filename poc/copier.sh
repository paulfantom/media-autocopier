#!/bin/bash

CARD=/dev/sda1
CARD_DIR=/mnt/card
MEDIA_DIR=/srv/media
EXTENSIONS="raw|rw2|dng|jpg|jpeg|mp4|mpeg"

mkdir -p ${CARD_DIR}
mount ${CARD} ${CARD_DIR}

FIRST_PIC=$(find ${CARD_DIR} -regextype posix-extended -iregex ".*\.(${EXTENSIONS})" | sort | head -n1)
LAST_PIC=$(find ${CARD_DIR} -regextype posix-extended -iregex ".*\.(${EXTENSIONS})" | sort | tail -n1)

DEVICE_NAME=$(exiftool -s -s -s -Make ${FIRST_PIC})
BEGIN_DATE=$(exiftool -s -s -s -d "%Y-%m-%d" -CreateDate ${FIRST_PIC})
END_DATE=$(exiftool -s -s -s -d "%Y-%m-%d" -CreateDate ${LAST_PIC})

if [ $BEGIN_DATE == "" -a $END_DATE == "" ]; then
    BEGIN_DATE=$(date +%F)
    END_DATE="or_earlier"
fi

mkdir -p ${MEDIA_DIR}/${BEGIN_DATE}_${END_DATE}/RAW/${DEVICE_NAME}
find ${CARD_DIR} -regextype posix-extended -iregex ".*\.(${EXTENSIONS})" -printf %P\\0 | rsync -aPu --no-relative --files-from=- --from0 ${CARD_DIR}/ ${MEDIA_DIR}/${BEGIN_DATE}_${END_DATE}/RAW/${DEVICE_NAME}/
sync
umount ${CARD}
