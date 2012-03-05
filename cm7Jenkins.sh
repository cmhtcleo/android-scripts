#!/bin/bash

export manufacturer=$1
export device=$2

WORKDIR=$WORKSPACE
OUTPUT=$WORKDIR
SOURCE=$WORKDIR/source

date1=`date +%Y%m%d`
date2=`date +%m%d%Y`
date3=`date +%m-%d-%Y`

numProcs=$(( `cat /proc/cpuinfo  | grep processor | wc -l` + 1 ))

cd $SOURCE

export CYANOGEN_NIGHTLY=1
export USE_CCACHE=1

if [[ ${device} = "leo" ]] ; then
  sed -i s/developerid=cyanogenmodnightly/developerid=cyanogenmodleonightly/g vendor/cyanogen/products/common.mk

  # To make it for only cLK
  sed -i 's/\(^TARGET_CUSTOM_RELEASETOOL.*\)/#\1/g' device/htc/${device}/BoardConfig.mk
fi

cp ./vendor/cyanogen/products/cyanogen_${device}.mk buildspec.mk

echo "Getting ROMManager"
./vendor/cyanogen/get-rommanager
echo -n "setting up environment ... "
. build/envsetup.sh > /dev/null 2>&1
echo -n "running brunch ... "
lunch cyanogen_${device}-eng

make -j ${numProcs} bootimage
make -j ${numProcs} bacon

mkdir -p $OUTPUT

cp out/target/product/${device}/cyanogen_${device}-ota-${BUILD_NUMBER}.zip $OUTPUT/update-cm7-${device}-${BUILD_ID}.zip

cd $WORKSPACE
rm -rf $SOURCE
