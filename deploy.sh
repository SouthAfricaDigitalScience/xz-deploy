#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
module add deploy
whoami
echo ${SOFT_DIR}
module add deploy
echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
../configure \
--disable-doc \
--enable-shared \
--enable-static \
--prefix=${SOFT_DIR}
make
make install
echo "Creating the modules file directory ${LIBRARIES}"
mkdir -p ${LIBRARIES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/XZ-deploy"
setenv XZ_VERSION       $VERSION
setenv XZ_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(XZ_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(XZ_DIR)/include
prepend-path CFLAGS            "-I$::env(XZ_DIR)/include"
prepend-path LDFLAGS           "-L$::env(XZ_DIR)/lib"
MODULE_FILE
) > ${LIBRARIES}/${NAME}/${VERSION}

echo "checking module"
module  avail ${NAME}
module add ${NAME}/${VERSION}

which xz
