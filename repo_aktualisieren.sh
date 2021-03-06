#!/bin/bash
# Author: PlayMovie Ltd.
# This Script Generates a new Inventory for a new Version or New Plugin
REPO=/www/repo/git
if [ "$1" != "" ]
then
    REPO="$1"
fi
if [ -f "$(pwd)/addons.xml" ]
then
    REPO="$(pwd)"
fi
if [ ! -f "$REPO/addons.xml" ]
then
    echo "repo path nicht korrekt"
    exit 0
fi
ZIP="$(command -v zip)"
if [ "$ZIP" = "" ]
then
    echo "zip fehlt. eg: apt-get install zip"
    exit 0
fi


cd $REPO
rm -rf .idea

# Lösche als Broken markierte Addons nach 3 Monaten

for addon in `git log -S'broken' --date=short --before="3 month" --after="6 month" --pretty="" --name-only ./*/addon.xml | cut -d / -f1`; do
    rm -rf $addon
done

echo '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' >$REPO/addons.xml
echo '<addons>' >> $REPO/addons.xml
for name in `find . -maxdepth 1 -type d |grep -v \.git|grep -v addons|egrep -v "^\.$"|cut -d \/ -f 2 `; do 
   VERSION=`cat $name/addon.xml|grep \<addon|grep $name |tr 'A-Z' 'a-z'|sed 's/.*version="\([^"]*\)"*.*/\1/g'`
     if [ ! -f "$name/$name-$VERSION.zip" ]; then
       zip -r $name/$name-$VERSION.zip $name -x \*.zip -x \*.git
     fi
   array=`find $name -maxdepth 1 -name \*.zip |sort -t . -V -k 2 | head -n -5`
    for zip in $array
    do
        rm -rf $zip
    done
    
   cat $name/addon.xml|grep -v "<?xml " >> $REPO/addons.xml
   echo "" >> $REPO/addons.xml
 done
 echo "</addons>" >> $REPO/addons.xml
 md5sum  $REPO/addons.xml > $REPO/addons.xml.md5
 
