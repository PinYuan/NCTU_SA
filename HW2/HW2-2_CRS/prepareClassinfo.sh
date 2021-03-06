#! /bin/sh

test -d classinfo
if [ $? != 0 ] ; then
	mkdir classinfo
fi

# check whether the timetable exists, if not exists, curl.
test -e classinfo/nctucsClass.json
if [ $? != 0 ] ; then
	echo 'Downloading NCTH CS timetable...'
	curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data 'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crsname=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' > classinfo/nctucsClass.json
	echo 'Download success'
fi

# extract data from json
grep -o '"cos_time":"[^"]*"' classinfo/nctucsClass.json | grep -o '"[^"]*"$' | sed 's/"//g' > classinfo/class_time_place.txt
# "cos_ename":"Calculus (I)"
grep -o '"cos_ename":"[^"]*"' classinfo/nctucsClass.json | grep -o '"[^"]*"$' | sed 's/"//g' > classinfo/class_name_tmp.txt
# "cos_time_place":"1GH4CD-SC206"

# class time
grep -o '^.*-' classinfo/class_time_place.txt | sed 's/-[^,]*,/,/g' | \
while read line; do
	echo $(echo ${line} | grep -Eo '[0-9][A-Z]*')
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
		day=$(echo ${time} | cut -c 1) # day=${time:0:1}
		for i in $(seq 2 ${#time}); do
		# for (( i=1; i<${#time}; i++ )); do
			hour=$(echo ${time} | cut -c ${i}) # ${time:${i}:1}
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

# Load class info

# build a number2time array
while read item time; do
	time=$(echo ${time} | sed 's/\ /\\ /g')
	eval timeArray${item}=${time}
#	echo ${item} ${time}
done < classinfo/class_time.txt
   
# build a number2name array
while read item name; do
	name=$(echo ${name} | sed 's/\ /\\ /g' | sed "s/'/\\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g')
	eval nameArray${item}=${name}
done < classinfo/class_name.txt

# build total imformation array
while read item class; do
	class=$(echo ${class} | sed 's/\ /\\ /g' | sed "s/'/\\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g')
	eval totalArray${item}=${class}
	#eval totalArray${item}=$(echo ${class} | sed 's/\ /\\ /g' | sed 's/\x27/\\\x27/g' | sed 's/(/\\(/g' | sed 's/)/\\)/g')
done < classinfo/class_total.txt

# build a number2place array
while read item place; do
	eval placeArray${item}=${place}
done < classinfo/class_place.txt
