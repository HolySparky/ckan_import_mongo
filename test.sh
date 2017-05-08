#!/bin/bash

# mongo data tempfile
tempFloder="datatemp"

# create mongo data tempfile
if [ ! -d $tempFloder ]; then
   mkdir $tempFloder
fi

cd $tempFloder

# download swift object collection
swift --os-auth-url 'http://210.14.69.69:5000/v2.0' \
      --os-tenant-name 'changfeng' \
      --os-username 'changfeng' --os-password 'Changfeng2014!' \
      list mongo-backup  >> swiftobjectlists.txt

cat swiftobjectlists.txt | while read line  
do        
   if [ ! -f $line ]; then
   swift --os-auth-url 'http://210.14.69.69:5000/v2.0' \
         --os-tenant-name 'changfeng' \
         --os-username 'changfeng' --os-password 'Changfeng2014!' \
         download mongo-backup $line

   if [ -d platform ]; then
   	rm -rf platform
   fi
   tar -xzf $line
   echo "update mongodb data " $line " to mongodb"
   bsondump platform/m_label.bson > platform/m_label.json
   mongoimport --host 10.200.43.100 --port 27017 -d test -c tempmongo --upsert --file platform/m_label.json   
   fi
done