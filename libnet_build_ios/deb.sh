#!/bin/bash

# brew install fakeroot

Package=`grep 'Package:' control | cut -d ':' -f 2 | tr -d ' '`;
Version=`grep 'Version:' control | cut -d ':' -f 2 | tr -d ' '`;
Architecture=`grep 'Architecture:' control | cut -d ':' -f 2 | tr -d ' '`;
filename=$Package"_"$Version"_"$Architecture;

DEB_DIR=`pwd`"/out";

mkdir -p $DEB_DIR/DEBIAN;
cp -f control $DEB_DIR/DEBIAN/;

sudo chown -R 0:0 $DEB_DIR/usr/*;
sudo chmod -R 0755 $DEB_DIR/usr/bin/*;
sudo find $DEB_DIR -iname "*DS_Store" -type f -delete;

dpkg-deb -Z gzip -b $DEB_DIR $filename.deb;
readlink $filename.deb;

sudo chown -R `whoami`:staff $DEB_DIR/*;
