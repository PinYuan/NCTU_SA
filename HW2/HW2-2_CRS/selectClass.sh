#!/bin/bash

while read item class; do
	totalArray[${item}]=${class}
done < classinfo/class_total.txt

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
	unset paires
	unset selected
	unset new_unselected
	unset unselected_arr
	unset selected_arr
	local paires


	sort -n -k 1 -o usr/unselected.txt usr/unselected.txt
	sort -n -k 1 -o usr/selected.txt usr/selected.txt
	

	while read item class; do
		class=$(echo "$class" | sed 's/\ /\\ /g' | sed 's/\x27/\\\x27/g') 
	    # paires+=(${item} ${class} off)
	    unselected_arr[${item}]="${class}"
	done < usr/unselected.txt

	while read item; do
		selected+=(${item})
		class=$(echo "${totalArray[${item}]}" | sed 's/\ /\\ /g' | sed 's/\x27/\\\x27/g') 
	    # paires+=(${item} ${class} on)
	    selected_arr[${item}]="${class}"
	done < usr/selected.txt


	for num in {1..130}; do
		if [ -n "${unselected_arr[${num}]}" ] ; then
			paires+=(${num} ${unselected_arr[${num}]} off)
		else
			paires+=(${num} ${selected_arr[${num}]} on)
		fi
	done

	echo ${paires[@]} | xargs dialog --stdout --buildlist "Add class" 50 150 30 > usr/new_selected.txt
	if [ $? != 0 ] ; then
		return 1
	fi
	
	new_selected=`cat usr/new_selected.txt`

	for i in ${selected[@]}; do
	    skip=
	    for j in ${new_selected[@]}; do
	        [[ $i == $j ]] && { skip=1; break; }
	    done
	    [[ -n $skip ]] || new_unselected+=("${i}")
	done
	return 0
}

checkCollision() {
	> usr/selected.txt

	# build a number2time array
	while read item time; do
		timeArray[${item}]=${time}
	done < classinfo/class_time.txt

	# build a number2name array
	while read item name; do
		nameArray[${item}]=${name}
	done < classinfo/class_name.txt

	unset conflictMAP
	declare -Ag conflictMAP 

	new_selected_nums=`cat usr/new_selected.txt | xargs echo`
	for new_selected_num in ${new_selected_nums}; do
		new_selected_time=${timeArray[${new_selected_num}]}
		neverConflict=0
		
		for new_time in ${new_selected_time}; do
			conflict=1
			while read selected_num; do
				selected_time=${timeArray[${selected_num}]}
				for time in ${selected_time}; do
					if [ ${new_time} = ${time} ] ; then
						conflictMAP[${new_time}]="${conflictMAP[${new_time}]}@${nameArray[${selected_num}]}"
						neverConflict=1
						conflict=0
						break
					fi
				done
			done < usr/selected.txt

			# if conflict add new at the end
			if [ ${conflict} = 0 ] ; then 
				conflictMAP[${new_time}]="${conflictMAP[${new_time}]}@${nameArray[${new_selected_num}]}"
			fi
		done
		
		if [ ${neverConflict} = 0 ] ; then
			echo ${new_selected_num} >> usr/selected.txt
			removes+=(${new_selected_num})
		fi
	done 

	# update usr/unselected.txt
	# remove
	for remove in ${removes[@]}; do
		linenum=1
		while read number class; do
			if [ ${number} = ${remove} ] ; then
				sed -i ${linenum}d usr/unselected.txt
				break
			fi
			linenum=$(( ${linenum}+1 ))
		done < usr/unselected.txt
	done
	# add
	for add in ${new_unselected[@]}; do
		printf "${add}\t${totalArray[${add}]}\n" >> usr/unselected.txt
	done
}

showCollision() {
	# TODO sub fail
	msg=""
	NEWLINE=$'\n'
	for time in "${!conflictMAP[@]}"; do 
		msg+="Collision: ${time:1:1}${time:0:1}${NEWLINE}"
		MSG_NO_LEAD_SPACE="$(echo -e "${conflictMAP[${time}]}" | sed -e 's/^@//')"
		msg+="${MSG_NO_LEAD_SPACE//@/\ and\ }${NEWLINE}"
		msg+="======================================${NEWLINE}${NEWLINE}"
	done
	
	# for i in ${!conflictMAP[@]}; do
	# 	echo "Key: ${i}"
	# 	echo "Value: ${conflictMAP[${i}]}"
	# done
	if [ -n "${msg}" ] ; then
		dialog --msgbox "${msg}" 25 50
		return 0
	else
		return 1
	fi
}
# addClass