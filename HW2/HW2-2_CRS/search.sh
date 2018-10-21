msgLength=55

searchByTime() {
	dialog --inputbox "Courses in particular time" 10 30 2> usr/searchByTime.txt 
	wantedTime=()

	times=$(cat usr/searchByTime.txt)

	test -e ${times}
	if [ $? = 0 ] ; then
		rm usr/searchByTime.txt 
		return
	fi

	for time in ${times}; do
		day=${time:0:1}
		for (( i=1; i<${#time}; i++ )); do
			hour=${time:${i}:1}
			wantedTime+=("${hour}${day}")
		done
	done

	matchNum=()
	for num in {1..130}; do
		found=0
		for wTime in ${wantedTime[@]}; do
			tmpFound=1
			for time in ${timeArray[${num}]}; do
				if [ ${time} = ${wTime} ] ; then
					tmpFound=0
					break
				fi
			done
			if [ ${tmpFound} = 1 ] ; then
				found=1
				break
			fi
		done
		if [ ${found} = 0 ] ; then
			matchNum+=(${num})
		fi
	done

	if [ ${#matchNum[@]} -eq 0 ] ; then
		printf "Can not find (ಥ_ʖಥ)\n" >> usr/searchMsg.txt
	else
		printf "Find %s match:\n\n" ${#matchNum[@]} >> usr/searchMsg.txt

		for num in "${matchNum[@]}"; do
			for lineNum in 0 1; do
				case ${lineNum} in 
					0)
						printf "%-*s\n" ${msgLength} "${totalArray[${num}]:0:${msgLength}}" >> usr/searchMsg.txt
					;;
					1)
						if [ $(( ${#totalArray[${num}]} / ${msgLength} )) -lt ${lineNum} ] ; then
							printf "\n" >> usr/searchMsg.txt
						else
							printf "%-*s\n\n" ${msgLength} "${totalArray[${num}]:$(( ${msgLength}*${lineNum} )):${msgLength}}" >> usr/searchMsg.txt
							
						fi
					;;
				esac
			done
		done
	fi 

	dialog --textbox usr/searchMsg.txt 20 60 
	rm usr/searchMsg.txt usr/searchByTime.txt 
}

searchByName() {
	dialog --inputbox "Courses keyword" 10 30 2> usr/searchByName.txt 
	wantedName=$(cat usr/searchByName.txt)

	test -e ${wantedName}
	if [ $? = 0 ] ; then
		rm usr/searchByName.txt 
		return
	fi

	matchNum=()
	for num in {1..130}; do
		if echo ${nameArray[${num}]} | grep -iqF ${wantedName}; then
		    matchNum+=(${num})
		fi
	done

	if [ ${#matchNum[@]} -eq 0 ] ; then
		printf "Can not find (ಥ_ʖಥ)\n" >> usr/searchMsg.txt
	else
		printf "Find %s match:\n\n" ${#matchNum[@]} >> usr/searchMsg.txt

		for num in "${matchNum[@]}"; do
			for lineNum in 0 1; do
				case ${lineNum} in 
					0)
						printf "%-*s\n" ${msgLength} "${totalArray[${num}]:0:${msgLength}}" >> usr/searchMsg.txt
					;;
					1)
						if [ $(( ${#totalArray[${num}]} / ${msgLength} )) -lt ${lineNum} ] ; then
							printf "\n" >> usr/searchMsg.txt
						else
							printf "%-*s\n\n" ${msgLength} "${totalArray[${num}]:$(( ${msgLength}*${lineNum} )):${msgLength}}" >> usr/searchMsg.txt
							
						fi
					;;
				esac
			done
		done
	fi 

	dialog --textbox usr/searchMsg.txt 20 60 
	rm usr/searchMsg.txt usr/searchByName.txt 
}

searchOrNot() {
	dialog --title "Search class" --menu "Choose one" 10 40 3 1 "By particular time" 2 "By keyword" 3 "Skip" 2> usr/searchWhich.txt
}