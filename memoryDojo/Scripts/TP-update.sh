#! /bin/sh
TP=/usr/local/bin/TexturePacker
if [ "${ACTION}" = "clean" ]
then
    # remove sheets - please add a matching expression here
    rm -f ${PROJECT_DIR}/SpriteSheets/*.pvr.ccz
    rm -f ${PROJECT_DIR}/SpriteSheets/*.pvr
    rm -f ${PROJECT_DIR}/SpriteSheets/*.plist
    rm -f ${PROJECT_DIR}/SpriteSheets/*.png
else
    # create all assets from tps files
    mkdir -p ${PROJECT_DIR}/SpriteSheets
 
    ${TP} *.tps
fi
exit 0