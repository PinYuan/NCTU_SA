#!/bin/bash

seperateLine="  =============="
spaceLine="            "
spaceSmallLine="           "
spaceDayLine="            "
daysFull=".Mon .Tue .Wed .The .Fri .Sat .Sun"
daysLimit=".Mon .Tue .Wed .The .Fri"
hoursFull=(M N A B C D X E F G H I J K L) # less importtant: 0, 1, 6, 14
hoursLimit=(A B C D E F G H I J K)
startChar="."
emptyChar="x"
boundaryChar="  |"
length=13 


# inArray() {
# 	# ( keyOrValue, arrayKeysOrValues ) 
# 	local e
# 	for e in ${@:2}; do 
# 		[[ "$e" == "$1" ]] && return 0; 
# 	done
#   	return 1
# }

resetRowTable() {
	unset rowtable
	
	if [ ${options[2]} = 0 ] ; then
		days=${daysLimit}
		hours=( "${hoursLimit[@]}" )
		for i in {1..5}; do
			rowtable[${i}]=""
		done
	else
		days=${daysFull}
		hours=( "${hoursFull[@]}" )
		for i in {1..7}; do
			rowtable[${i}]=""
		done
	fi
}

loadOptions() {
	selected=$(cat usr/options.txt)

	for i in 1 2; do
		options[${i}]=1
		for num in ${selected}; do
			if [ "${i}" = "${num}" ] ; then
				options[${i}]=0
				break
			fi
		done
	done

	resetRowTable
}

printDay() {
	printf "${emptyChar}  " >> usr/table.txt
	for day in ${days}; do
		printf "${day}${spaceDayLine}" >> usr/table.txt
	done
	printf "\n" >> usr/table.txt
}

printSepRow() {
	printf "=" >> usr/table.txt
	for (( day=1; day<${#rowtable[@]}+1; day++ )); do
		printf ${seperateLine} >> usr/table.txt
	done 
	printf "  =\n" >> usr/table.txt
}

printRow() {
	# args: time 1@class 2@class
	# EX: A 1@Calculus (I) 2@Physics (I)

	local time=$1
	resetRowTable

	for day_class in ${@:2}; do 
		day="$(echo "${day_class}" | cut -d '@' -f 1)"
		class="$(echo "${day_class}" | cut -d '@' -f 2)"
		place="$(echo "${day_class}" | cut -d '@' -f 3)"
		if [ ${options[1]} = 0 ] ; then
			rowtable[${day}]=${class}@${place}
		else 
			rowtable[${day}]=${class}
		fi
	done

	for lineNum in {0..4}; do # block have 5 line
		if [ ${lineNum} = 0 ] ; then
			printf "${time}" >> usr/table.txt
		else
			printf "${startChar}" >> usr/table.txt
		fi
		
		# class block

		if [ ${lineNum} = 0 ] ; then
			for (( day=1; day<${#rowtable[@]}+1; day++ )); do # 5~7 day
				if [ -z "${rowtable[${day}]}" ] ; then
					printf "${boundaryChar}${emptyChar}${startChar}${spaceSmallLine}" >> usr/table.txt
				else
					printf "${boundaryChar}%-*s" ${length} "${rowtable[${day}]:0:${length}}" >> usr/table.txt
				fi
			done
		else # print rest string
			for (( day=1; day<${#rowtable[@]}+1; day++ )); do # 5~7 day
				if [ $(( ${#rowtable[${day}]} / ${length} )) -lt ${lineNum} ] ; then
					printf "${boundaryChar}${startChar}${spaceLine}" >> usr/table.txt
				else
					printf "${boundaryChar}%-*s" ${length} "${rowtable[${day}]:$(( ${length}*${lineNum} )):${length}}" >> usr/table.txt
				fi
			done
		fi
		printf '  |\n' >> usr/table.txt
	done

	printSepRow
}

printTable() {
	test -e usr/sortclass.txt
	if [ $? != 0 ] ; then
		touch usr/sortclass.txt
	fi

	# build a number2time array
	while read item time; do
		timeArray[${item}]=${time}
	done < classinfo/class_time.txt

	# build a number2name array
	while read item name; do
		nameArray[${item}]=${name}
	done < classinfo/class_name.txt

	# build a number2place array
	while read item place; do
		placeArray[${item}]=${place}
	done < classinfo/class_place.txt

	# time name place 
	while read selected_num; do
		name=${nameArray[${selected_num}]}
		place=${placeArray[${selected_num}]}
		for time in ${timeArray[${selected_num}]}; do
			printf "%s\t%s\t%s\n" "${time}" "${name}" "${place}" >> usr/sortclass.txt
		done
	done < usr/selected.txt
	
	# sort by hour 
	sort -k 1 -o usr/sortclass.txt usr/sortclass.txt

	declare -A hourMap

	IFS=$'\t'
	while read time name place; do
		hourMap[${time:0:1}]+=${time:1:1}@${name}@${place}$'\n'
	done < usr/sortclass.txt
	IFS=$' \t\n'

	printDay

	# print hour row
	IFS=$'\n'
	for hour in "${hours[@]}"; do
		printRow ${hour} "${hourMap[${hour}]}"
	done
	IFS=$' \t\n'

	dialog --stdout --title "Timetable" --ok-label "Add class" --extra-button --extra-label "Options" --help-button --help-label "Exit" --textbox usr/table.txt  50 110
	echo $? > usr/state.txt

	rm usr/sortclass.txt usr/table.txt
}