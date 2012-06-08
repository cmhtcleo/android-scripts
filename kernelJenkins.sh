# Set-up environment
NAME=android_kernel_cmhtcleo

export K_ROOT=$WORKSPACE
export K_SRC=$K_ROOT/$NAME
export K_WORK=$K_SRC-work
export K_OUTPUT=$K_SRC-out
export ARCH=arm
export CROSS_COMPILE=/data/android/toolchain/arm-2011.03/bin/arm-none-eabi-
export INSTALL_MOD_PATH=$K_OUTPUT/system/lib/modules

# Clean any previous directories
rm -rf $K_WORK
rm -rf $K_OUTPUT

# Set-up directories
# Working Directories
cp -al $K_SRC $K_WORK

# Output directories
mkdir -p $K_OUTPUT/boot
mkdir -p $K_OUTPUT/devs

# Start compilation process
# Go into working directory
cd $K_WORK

# Grab the relevant config
make htcleo_defconfig

# Compile the zImage
make -j4 zImage

cp $K_WORK/arch/arm/boot/zImage $K_OUTPUT/boot/
cp .config $K_OUTPUT/devs/build_config

# Compile/install the modules
make -j4 modules
make -j4 modules_install
cd $K_OUTPUT/system/lib/modules
find -iname *.ko | xargs -i -t cp {} .
rm -rf $K_OUTPUT/system/lib/modules/lib

# Check to see if the zImage is the right one 
stat $K_OUTPUT/boot/zImage
