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

resetRowTable() {
	if [ ${options2} = 0 ] ; then
		days=${daysLimit}
		hours=${hoursLimit}
		dayNum=5
	else
		days=${daysFull}
		hours=${hoursFull}
		dayNum=7
	fi
	for i in $(seq 1 ${dayNum}); do
		eval rowtable${i}=""
	done
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
	for day in $(seq 1 ${dayNum}); do
		printf ${seperateLine} >> usr/table.txt
	done 
	printf "  =\n" >> usr/table.txt
}

printRow() {
	# args: time 1@class 2@class
	# EX: A 1@Calculus (I) 2@Physics (I)
	local time=$1
	resetRowTable
	local index=0
	
	IFS=$'#\n'

	for day_class in $@; do 
		if [ index = 0 ] ; then 
			index=$(( ${index}+1 ))
			continue	
		fi
		day="$(echo "${day_class}" | cut -d '@' -f 1)"
		class="$(echo "${day_class}" | cut -d '@' -f 2)"
		place="$(echo "${day_class}" | cut -d '@' -f 3)"
		if [ ${options1} = 0 ] ; then
			eval rowtable${day}=${class}@${place}
		else 
			eval rowtable${day}=${class}
		fi
	done

	IFS=$'\n'

	for lineNum in $(seq 0 4); do # block have 5 line
		if [ ${lineNum} = 0 ] ; then
			printf "${time}" >> usr/table.txt
		else
			printf "${startChar}" >> usr/table.txt
		fi
		
		# class block

		if [ ${lineNum} = 0 ] ; then
			for day in $(seq 1 ${dayNum}); do # 5~7 day
				str=$(eval echo \${rowtable${day}})
				if [ -z ${str} ] ; then
					printf "${boundaryChar}${emptyChar}${startChar}${spaceSmallLine}" >> usr/table.txt
				else
					substr=$(echo ${str} | cut -c 1-${length})
					printf "${boundaryChar}%-*s" ${length} "${substr}" >> usr/table.txt
				fi
			done
		else # print rest string
			for day in $(seq 1 ${dayNum}); do # 5~7 day
				str=$(eval echo \${rowtable${day}})
				if [ $(( ${#str} / ${length} )) -lt ${lineNum} ] ; then
					printf "${boundaryChar}${startChar}${spaceLine}" >> usr/table.txt
				else
					substr=$(echo ${str} | cut -c $(( ${length}*${lineNum}+1 ))-$(( ${length}*${lineNum}+${length} ))) 
					printf "${boundaryChar}%-*s" ${length} "${substr}" >> usr/table.txt
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
		name=$(eval echo \${nameArray${selected_num}} | sed 's/\ /\\ /g' | sed "s/'/\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g')
		place=$(eval echo \${placeArray${selected_num}})
		times=$(eval echo \${timeArray${selected_num}})
		for time in ${times}; do
			printf "%s\t%s\t%s\n" "${time}" "${name}" "${place}" >> usr/sortclass.txt
		done
	done < usr/selected.txt
	
	# sort by hour 
	sort -k 1 -o usr/sortclass.txt usr/sortclass.txt
	
	for hour in ${hours}; do
		eval hourMap${hour}=""
	done
	
	IFS=$'\t'
	while read time name place; do
		name=$(echo $name | sed 's/\ /\\ /g' | sed "s/'/\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g')
		hour=$(echo ${time} | cut -c 1)
		day=$(echo ${time} | cut -c 2)
		if [ ${options2} = 0 ] && [ ${day} = 6 -o ${day} = 7 ] ; then  
			continue
		fi
		eval hourMap${hour}="$(eval echo \${hourMap${hour}} | sed 's/\ /\\ /g' | sed "s/'/\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g')""${day}@${name}@${place}#"
	done < usr/sortclass.txt
	IFS=$' \t\n'
	table=""
	printDay
	
	# print hour row
	for hour in ${hours}; do
		IFS=$'\n'
		printRow ${hour} "$(eval echo \${hourMap${hour}} | sed 's/\ /\\ /g' | sed "s/'/\\'/g" | sed 's/(/\\(/g' | sed 's/)/\\)/g')" 
		IFS=$' \t\n'
	done

	dialog --stdout --title "Timetable" --ok-label "Add class" --extra-button --extra-label "Options" --help-button --help-label "Exit" --textbox usr/table.txt  50 110
	echo $? > usr/state.txt
	
	rm usr/sortclass.txt usr/table.txt

}
