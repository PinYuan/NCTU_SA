#! /bin/sh

initUserData() {
	test -d usr
	if [ $? != 0 ] ; then
		mkdir usr
	fi

	test -e usr/unselected.txt
	if [ $? != 0 ] ; then
		cp classinfo/class_total.txt usr/unselected.txt 
	fi

	test -e usr/selected.txt
	if [ $? != 0 ] ; then
		touch usr/selected.txt
	fi
}

addClass() {
	local paires=""
	selected=""
	new_unselected=""

	sort -n -k 1 -o usr/unselected.txt usr/unselected.txt
	sort -n -k 1 -o usr/selected.txt usr/selected.txt
	
	# initailize
	for num in $(seq 1 130); do
		eval unselected_arr${num}=""
		eval selected_arr${num}=""
	done

	while read item class; do
		class=$(echo "$class" | sed 's/\ /\\ /g' | sed "s/'/\\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g') 
		eval unselected_arr${item}="${class}"
	done < usr/unselected.txt

	while read item; do
		selected=${selected}" ${item}"
		class=$(eval echo \${totalArray${item}} | sed 's/\ /\\ /g' | sed "s/'/\\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g') 
		eval selected_arr${item}="${class}"
	done < usr/selected.txt
	
	for num in $(seq 1 130); do
		unselected_str="$(eval echo \${unselected_arr${num}})"
		selected_str="$(eval echo \${selected_arr${num}})"
		if [ -n "${unselected_str}" ] ; then
			unselected_str=$(echo ${unselected_str} | sed 's/\ /\\ /g' | sed "s/'/\\\'/g" | sed 's/(/\\\(/g' | sed 's/)/\\)/g')
			paires=${paires}" ${num} ${unselected_str} off"
		elif [ -n "${selected_str}" ] ; then
			selected_str=$(echo ${selected_str} | sed 's/\ /\\ /g' | sed "s/'/\\\'/g" | sed 's/(/\\\(/g' | sed 's/)/\\)/g')
			paires=${paires}" ${num} ${selected_str} on"
		fi
	done

	echo ${paires} | xargs dialog --stdout --buildlist "Add class" 50 150 30 > usr/new_selected.txt
	if [ $? != 0 ] ; then
		return 1
	fi
	
	new_selected=`cat usr/new_selected.txt`

	for i in ${selected}; do
	    	skip=
		for j in ${new_selected}; do
	        	if [ ${i} = ${j} ] ; then
				skip=1
				break
			fi
	    	done
	    	if [ -e ${skip} ] ; then
			new_unselected=${new_unselected}" ${i}"
		fi
	done
	return 0
}

checkCollision() {
	> usr/selected.txt
	test -e usr/conflictTimes.txt
	if [ $? = 0 ] ; then
		conflictTimes=$(cat usr/conflictTimes.txt)
		for time in ${conflictTimes}; do
			eval conflictMAP${time}=""
			eval inTime${time}=""
		done
		rm usr/conflictTimes.txt
	fi
	touch usr/conflictTimes.txt	
	
	new_selected_nums=$(cat usr/new_selected.txt)
	for new_selected_num in ${new_selected_nums}; do
		new_selected_time=$(eval echo \${timeArray${new_selected_num}})
		neverConflict=0
		
		for new_time in ${new_selected_time}; do
			conflict=1
			
			while read selected_num; do
				selected_time=$(eval echo \${timeArray${selected_num}})
				for time in ${selected_time}; do
					if [ ${new_time} = ${time} ] ; then
						# check whether has conflicted
						in=1
						
						for num in $(eval echo \${inTime${new_time}}); do
							if [ ${num} = ${selected_num} ] ; then 
								in=0 
								break
							fi	
						done
						# if not, add
						if [ ${in} = 1 ] ; then
							eval conflictMAP${new_time}="$(eval echo \${conflictMAP${new_time}} | sed 's/\ /\\ /g' | sed "s/'/\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g')"@"$(eval echo \${nameArray${selected_num}} | sed 's/\ /\\ /g' | sed "s/'/\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g')"
							eval inTime${new_time}="$(eval echo \${inTime${new_time}})""\ ${selected_num}"
						fi
						neverConflict=1
						conflict=0
						break
					fi
				done
			done < usr/selected.txt
			
			# if conflict add new at the end
			if [ ${conflict} = 0 ] ; then \
				echo ${new_time} >> usr/conflictTimes.txt
				eval conflictMAP${new_time}="$(eval echo \${conflictMAP${new_time}} | sed 's/\ /\\ /g' | sed "s/'/\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g')"@"$(eval echo \${nameArray${new_selected_num}} | sed 's/\ /\\ /g' | sed "s/'/\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g')"
			fi
		done
		
		if [ ${neverConflict} = 0 ] ; then
			echo ${new_selected_num} >> usr/selected.txt
			removes=${removes}" ${new_selected_num}"
		fi
	done 
	
	# update usr/unselected.txt
	# remove
	for remove in ${removes}; do
		linenum=1
		while read number class; do
			if [ ${number} = ${remove} ] ; then
				# sed -i ${linenum}d usr/unselected.txt
				sed ${linenum}d usr/unselected.txt > usr/unselected_tmp.txt
				break
			fi
			linenum=$(( ${linenum}+1 ))
		done < usr/unselected.txt
		cp usr/unselected_tmp.txt usr/unselected.txt
	done
	# add
	for add in ${new_unselected}; do
		printf "${add}\t%s\n" "$(eval echo \${totalArray${add}})" >> usr/unselected.txt
	done
}

showCollision() {
	msg=""
	NEWLINE=$'\n'
	conflictTimes=$(sort usr/conflictTimes.txt | uniq)
	
	for time in ${conflictTimes}; do 
		day=$(echo ${time} | cut -c 2)
		hour=$(echo ${time} | cut -c 1)
		msg=${msg}"Collision: ${day}${hour}${NEWLINE}"
		MSG_NO_LEAD_SPACE="$(eval echo \${conflictMAP${time}} | sed 's/^@//g' | sed 's/@/ and /g')"
		msg=${msg}"${MSG_NO_LEAD_SPACE}${NEWLINE}"
		msg=${msg}"======================================${NEWLINE}${NEWLINE}"
	done
	
	if [ -n "${msg}" ] ; then
		echo "${msg}" > usr/collisionMsg.txt
		dialog --textbox usr/collisionMsg.txt 25 50
		return 0
	else
		return 1
	fi
}
