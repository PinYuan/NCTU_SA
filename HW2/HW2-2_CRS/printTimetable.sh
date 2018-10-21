#! /bin/sh

seperateLine="  =============="
spaceLine="            "
spaceSmallLine="           "
spaceDayLine="            " 
daysFull=".Mon .Tue .Wed .The .Fri .Sat .Sun"
daysLimit=".Mon .Tue .Wed .The .Fri"
hoursFull="M N A B C D X E F G H I J K L" # less importtant: 0, 1, 6, 14
hoursLimit="A B C D E F G H I J K"
startChar="."
emptyChar="x"
boundaryChar="  |"
length=13 

# tmp
options1=0
options2=0
options3=0
# build a number2time array
while read item time; do
	time=$(echo ${time} | sed 's/\ /\\ /g')
	eval timeArray${item}=${time}
	# echo ${item} ${time}
done < classinfo/class_time.txt
   
# build a number2name array
while read item name; do
	name=$(echo ${name} | sed 's/\ /\\ /g' | sed 's/\x27/\\\x27/g' | sed 's/(/\\(/g' | sed 's/)/\\)/g')
	eval nameArray${item}=${name}
done < classinfo/class_name.txt

# build total imformation array
while read item class; do
	eval totalArray${item}=$(echo ${class} | sed 's/\ /\\ /g' | sed 's/\x27/\\\x27/g' | sed 's/(/\\(/g' | sed 's/)/\\)/g')
done < classinfo/class_total.txt

# build a number2place array
while read item place; do
	eval placeArray${item}=${place}
done < classinfo/class_place.txt

resetRowTable() {
	# rowtable=()
	
	if [ ${options2} = 0 ] ; then
		days=${daysLimit}
		hours=${hoursLimit}
		for i in $(seq 1 5); do
			eval rowtable${i}=""
		done
	else
		days=${daysFull}
		hours=${hoursFull}
		for i in $(seq 1 7); do
			eval rowtable${i}=""
		done
	fi
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
	for day in $(seq 1 ${#days}); do
	# for (( day=1; day<${#rowtable[@]}+1; day++ )); do
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
		if [ ${options1} = 0 ] ; then
			rowtable${day}=${class}@${place}
		else 
			rowtable${day}=${class}
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
			for day in $(seq 1 ${#days}); do # 5~7 day
			# for (( day=1; day<${#rowtable[@]}+1; day++ )); do # 5~7 day
				if [ -z "eval echo \${rowtable${day}}" ] ; then
					printf "${boundaryChar}${emptyChar}${startChar}${spaceSmallLine}" >> usr/table.txt
				else
					substr=$(eval echo \${rowtable${day}} | cut -c 1-${length})
					printf "${boundaryChar}%-*s" ${length} "${substr}" >> usr/table.txt
					# printf "${boundaryChar}%-*s" ${length} "${rowtable[${day}]:0:${length}}" >> usr/table.txt
				fi
			done
		else # print rest string
			for day in $(seq 1 ${#days}); do # 5~7 day
			# for (( day=1; day<${#rowtable[@]}+1; day++ )); do # 5~7 day
				str=$(eval echo \${rowtable${day}})
				if [ $(( ${#str} / ${length} )) -lt ${lineNum} ] ; then
					printf "${boundaryChar}${startChar}${spaceLine}" >> usr/table.txt
				else
					substr=$(echo ${str} | cut -c $(( ${length}*${lineNum}+1 ))-$(( ${length}*${lineNum}+1+${length}} ))) 
					printf "${boundaryChar}%-*s" ${length} "${substr}" >> usr/table.txt
					# printf "${boundaryChar}%-*s" ${length} "${rowtable[${day}]:$(( ${length}*${lineNum} )):${length}}" >> usr/table.txt
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

	# time name place 
	while read selected_num; do
		name=$(eval echo \${nameArray${selected_num}})
		place=$(eval echo \${placeArray${selected_num}})
		times=$(eval echo \${timeArray${selected_num}})
		for time in ${times}; do
			printf "%s\t%s\t%s\n" "${time}" "${name}" "${place}" >> usr/sortclass.txt
		done
	done < usr/selected.txt
	
	# sort by hour 
	sort -k 1 -o usr/sortclass.txt usr/sortclass.txt

	# declare -A hourMap
	for hour in ${hours}; do
		eval hourMap${hour}=""
	done

	IFS=$'\t'
	while read time name place; do
		hour=$(echo ${time} | cut -c 1)
		day=$(echo ${time} | cut -c 2)
		if [ ${day} = 6 -o ${day} = 7 ] ; then # [ ${options2} = 0 ] && 
			continue
		fi
		eval hourMap${hour}="$(eval echo \${hourMap${hour}})"+"${day}@${name}@${place}"$'\n'
	done < usr/sortclass.txt
	IFS=$' \t\n'

	table=""

	printDay

	# print hour row
	IFS=$'\n'
	for hour in ${hours}; do
		printRow ${hour} "$(eval echo \${hourMap${hour}})" #"${hourMap[${hour}]}"
	done
	IFS=$' \t\n'

	dialog --stdout --title "Timetable" --ok-label "Add class" --extra-button --extra-label "Options" --help-button --help-label "Exit" --textbox usr/table.txt  50 110
	echo $? > usr/state.txt
	
	rm usr/sortclass.txt usr/table.txt
}
resetRowTable
printTable