#!/bin/sh

#Builds Version Strings
MAJOR=1
MINOR=1
PATCH=0
#odd minor versions are Dev
if (( $MINOR % 2 )); then
    VER=$MAJOR.$MINOR.$PATCH+dev
else
    VER=$MAJOR.$MINOR.$PATCH
fi
