#!/bin/bash

cp /data/android/CM/source/out/target/product/leo/ramdisk.img /data/android/leo/kernels/

for kernel in `echo charan marc tytung rafpigna`
do
cd $kernel > /dev/null 2>&1
./script.sh
cd - > /dev/null 2>&1
done
