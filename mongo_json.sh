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
      list mongo-backup  > new_list.txt

comm -3 new_list.txt old_list.txt > diff.txt
cp new_list.txt old_list.txt

cat diff.txt | while read line  
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
   c_name=${line%%.*}
   echo $c_name
   echo "update mongodb data " $line " to mongodb"
   bsondump platform/m_label.bson > platform/m_label.json
   mongoimport --host 127.0.0.1 --port 27017 -u ckan -p ckan -d ckanmongo -c temp --upsert --drop --file platform/m_label.json   
   mongoexport -u ckan -p ckan -d ckanmongo -c temp -o $c_name.json
   python ../json_csv.py n $c_name.json $c_name.csv
   echo "creating dataset $c_name"
   curl -H'Authorization: 67a6b4c3-b310-4b5e-8c9b-64107fdcdee3' 'http://127.0.0.1/api/action/package_create' --form name=$c_name --form title="食品溯源数据 $c_name "  --form owner_org=inesa_tracability --form notes="食品溯源csv格式数据" --form private=True
   echo "uploading file..."
   curl -H'Authorization: 67a6b4c3-b310-4b5e-8c9b-64107fdcdee3' 'http://127.0.0.1/api/action/resource_create' --form upload=@$c_name.csv --form package_id=$c_name --form name=$c_name
   fi
done
rm plat*
