#!/bin/bash

BASE='./source'
REGISTRY='./registry'
TMP='./tmp'

mkdir -p $BASE
mkdir -p $REGISTRY
mkdir -p $TMP

pkg=$1
echo $pkg
touch $TMP/archive

NAME=`echo $pkg|awk -F '/' '{print $5}'`

VERSION=`cat $REGISTRY/$NAME/latest/index.json|jq -r .version`

# Have we done this before?
grep "^$NAME-$VERSION\$" $TMP/archive &> /dev/null

if [ "$?" != "0" ]; then
  #Cleanup
  rm -r $BASE/$NAME &> /dev/null

  #Create new directory
  DIR="$BASE/$NAME/$VERSION"
  mkdir -p $DIR

  #Untar
  tar oxfz $pkg --strip-components=1 -C $DIR 2>> $TMP/error.log
  chmod -R 775 $DIR

  # remove cruft
  rm -rf $DIR/node_modules 2>> $TMP/error.log
  rm -rf $DIR/test 2>> $TMP/error.log
  find $DIR -name node_modules -type d -exec rm -rf {} \; -print0

  if [ "$?" == "0" ]; then
    echo $NAME-$VERSION >> $TMP/archive
  else
    echo $NAME-$VERSION >> $TMP/problem
  fi
fi
