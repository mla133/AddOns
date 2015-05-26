#!/bin/bash
# Bash script to clone NewAddon directory and rename the .lua & .toc files accordingly
# Also will accept a version number to update the Interface number in TOC file.

CLONEDIR=$1
VERSION=60100
cp -r wow-NewAddon/ $CLONEDIR
cd $CLONEDIR
mv NewAddon.lua $CLONEDIR.lua
mv NewAddon.toc $CLONEDIR.toc
sed -i -- "s/NewAddon/$CLONEDIR/g" $CLONEDIR.*
sed -i -- "s/60100/$VERSION/g" $CLONEDIR.toc
