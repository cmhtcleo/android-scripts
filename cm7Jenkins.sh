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
  sed -i &apos;s/\(^TARGET_CUSTOM_RELEASETOOL.*\)/#\1/g&apos; device/htc/${device}/BoardConfig.mk
fi

cp ./vendor/cyanogen/products/cyanogen_${device}.mk buildspec.mk

echo &quot;Getting ROMManager&quot;
./vendor/cyanogen/get-rommanager
echo -n &quot;setting up environment ... &quot;
. build/envsetup.sh &gt; /dev/null 2&gt;&amp;1
echo -n &quot;running brunch ... &quot;
lunch cyanogen_${device}-eng

make -j ${numProcs} bootimage
make -j ${numProcs} bacon

mkdir -p $OUTPUT

cp out/target/product/${device}/cyanogen_${device}-ota-${BUILD_NUMBER}.zip $OUTPUT/update-cm7-${device}-${BUILD_ID}.zip

cd $WORKSPACE
rm -rf $SOURCE
