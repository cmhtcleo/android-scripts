#!/bin/bash

export device=$1

export BUILD_NO=$BUILD_NUMBER
unset BUILD_NUMBER

WORKDIR=$WORKSPACE
OUTPUT=$WORKDIR
SOURCE=$WORKDIR/source

date1=`date +%Y%m%d`
date2=`date +%m%d%Y`
date3=`date +%m-%d-%Y`

numProcs=$(( `cat /proc/cpuinfo  | grep processor | wc -l` + 1 ))

checkStatus()
{
  STAT=$?
  [[ $STAT -ne 0 ]] && exit $STAT
}

cd $SOURCE

export CYANOGEN_NIGHTLY=1
export USE_CCACHE=1

if [[ ${device} = "leo" ]] ; then
  sed -i s/developerid=cyanogenmodnightly/developerid=cyanogenmodleonightly/g vendor/cyanogen/products/common.mk

  # To make it for only cLK
  sed -i 's/\(^TARGET_CUSTOM_RELEASETOOL.*\)/#\1/g' device/htc/${device}/BoardConfig.mk
fi

cp ./vendor/cyanogen/products/cyanogen_${device}.mk buildspec.mk

if [[ $device = "leo" ]] ; then
  # Copying the latest kernel stuff from the automated jenkins build
  cp ~jenkins/workspace/leo_kernel_gb/android_kernel_cmhtcleo-out/boot/zImage ./device/htc/leo/prebuilt/kernel
  cp ~jenkins/workspace/leo_kernel_gb/android_kernel_cmhtcleo-out/system/lib/modules/* ./device/htc/leo/prebuilt/modules/.
fi

echo "Getting ROMManager"
./vendor/cyanogen/get-rommanager
checkStatus 
echo -n "setting up environment ... "
. build/envsetup.sh
checkStatus 
echo -n "running brunch ... "
lunch cyanogen_${device}-eng
checkStatus 

make -j ${numProcs} bootimage
checkStatus 
make -j ${numProcs} bacon
checkStatus 

mkdir -p $OUTPUT

cp $SOURCE/out/target/product/${device}/cm-7-*.zip $OUTPUT/cm-7-${date1}-NIGHTLY-${device}.zip

if [[ $UPLOAD = "true" ]] ; then
  scp $OUTPUT/cm-7-${date1}-NIGHTLY-${device}.zip arif-ali.co.uk:cmleonightly/rom
  scp $OUTPUT/cm-7-${date1}-NIGHTLY-${device}.zip cmhtcleo@upload.goo.im:public_html/cm7
  checkStatus 
fi

cd $WORKSPACE
rm -rf $SOURCE
checkStatus

exit 0
