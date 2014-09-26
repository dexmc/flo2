#!/bin/bash

BASE_VER=".kangaroo.semaphore.flo.v000"
VER=""
KERNEL_VER=$BASE_VER$VER

export LOCALVERSION=""`echo $KERNEL_VER`
export CROSS_COMPILE=${HOME}/Toolchains/arm-cortex_a15-linux-gnueabihf-linaro_4.7.4-2014.06/bin/arm-cortex_a15-linux-gnueabihf-

export ARCH=arm
export SUBARCH=arm

DATE_START=$(date +"%s")

make "flo_defconfig"

echo "LOCALVERSION="$LOCALVERSION
echo "CROSS_COMPILE="$CROSS_COMPILE
echo "ARCH="$ARCH

make -j4

DATE_END=$(date +"%s")
echo
DIFF=$(($DATE_END - $DATE_START))
echo "  Build completed in $(($DIFF / 60)) minutes and $(($DIFF % 60)) seconds."
echo
