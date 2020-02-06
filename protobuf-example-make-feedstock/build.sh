#!/bin/bash
set -x #echo on

echo "******************* BUILD ENV VARS!!!!!!!!!!!!!!!!!!!!!!!! *******************"
echo "SITE PACKAGE DIRECTORY: $SP_DIR"
echo "PREFIX: $PREFIX"
echo "BUILD PREFIX: $BUILD_PREFIX"
echo "SOURCE DIRECTORY: $SRC_DIR"
echo "PYTHON VERSION: $PY_VER"
echo "PKG_VERSION: $PKG_VERSION"
echo "******************* BUILD ENV VARS!!!!!!!!!!!!!!!!!!!!!!!! *******************"

################
# Build C++
################
# clean
make clean -C $SRC_DIR
# build
make cpp -j -C $SRC_DIR

################################
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/bin

################################
# copy executable files to environments bin directory
################################
cp -f $SRC_DIR/add_person_cpp ${PREFIX}/bin
cp -f $SRC_DIR/list_people_cpp ${PREFIX}/bin

################################
# if we were building a shared library
# we would copy it to ${PREFIX}/lib
################################
