#!/bin/bash

test -d classinfo
if [ $? != 0 ] ; then
	mkdir classinfo
fi

# check whether the timetable exists, if not exists, curl.
test -e nctucsClass.json
if [ $? != 0 ] ; then
	echo 'Downloading NCTH CS timetable...'
	curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data 'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crsname=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' > classinfo/nctucsClass.json
	echo 'Download success'
fi

# extract data from json

# "cos_ename":"Calculus (I)"
grep -oP '"cos_ename":"\K[^"]*(?=")' classinfo/nctucsClass.json > classinfo/class_name_tmp.txt
# "cos_time_place":"1GH4CD-SC206"
grep -oP '"cos_time":"\K[^"]*(?=")' classinfo/nctucsClass.json > classinfo/class_time_place.txt

# class time
grep -oP '^.*(?=-)' classinfo/class_time_place.txt | sed 's/-[^,]*,/,/g' | \
while read line; do
	echo $(grep -Eo '[0-9][A-Z]*' <<< ${line}) 
done > classinfo/class_time_tmp.txt

# class place
sed 's/[^,-]*-//g' classinfo/class_time_place.txt > classinfo/class_place_tmp.txt

# paste time-place and name
paste -d ' ' classinfo/class_time_tmp.txt classinfo/class_place_tmp.txt > classinfo/tmp.txt
paste -d "@" classinfo/tmp.txt classinfo/class_name_tmp.txt | sed 's/@/ - /g' | awk '{print NR"\t"$0}' > classinfo/class_total.txt
rm classinfo/tmp.txt

cat classinfo/class_name_tmp.txt | awk '{print NR"\t"$0}' > classinfo/class_name.txt
cat classinfo/class_time_tmp.txt | \
while read line; do
	first=0
	for time in ${line}; do
		day=${time:0:1}
		for (( i=1; i<${#time}; i++ )); do
			hour=${time:${i}:1}
			if [ ${first} = 0 ] ; then
				printf "${hour}${day}"
				first=1
			else
				printf " ${hour}${day}"
			fi
		done
	done
	printf "\n"
done | \
awk '{print NR"\t"$0}' > classinfo/class_time.txt
cat classinfo/class_place_tmp.txt | awk '{print NR"\t"$0}' > classinfo/class_place.txt

rm classinfo/class_name_tmp.txt classinfo/class_time_tmp.txt classinfo/class_place_tmp.txt
