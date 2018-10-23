#! /bin/sh
msgLength=55

searchByTime() {
	dialog --inputbox "Courses in particular time" 10 30 2> usr/searchByTime.txt 
	wantedTime=""

	times=$(cat usr/searchByTime.txt)

	test -e "${times}"
	if [ $? = 0 ] ; then
		rm usr/searchByTime.txt 
		return
	fi

	for time in ${times}; do
		day=$(echo ${time} | cut -c 1)
		for i in $(seq 2 ${#time}); do
			hour=$(echo ${time} | cut -c ${i})
			wantedTime=${wantedTime}" ${hour}${day}"
		done
	done

	matchNum=""
	for num in $(seq 1 130); do
		found=0
		for wTime in ${wantedTime}; do
			tmpFound=1
			times=$(eval echo \${timeArray${num}})
			for time in ${times}; do
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
			matchNum=${matchNum}" ${num}"
		fi
	done

	if [ ${#matchNum} -eq 0 ] ; then
		printf "Can not find (ಥ_ʖಥ)\n" >> usr/searchMsg.txt
	else
		for num in ${matchNum}; do
			class=$(eval echo \${totalArray${num}})
			strlen=${#class}
			for lineNum in 0 1; do
				case ${lineNum} in 
					0)
						substr=$(echo ${class} | cut -c 1-${msgLength})
						printf "%-*s\n" ${msgLength} "${substr}" >> usr/searchMsg.txt
					;;
					1)
						if [ $(( ${strlen} / ${msgLength} )) -lt ${lineNum} ] ; then
							printf "\n" >> usr/searchMsg.txt
						else
							substr=$(echo ${class} | cut -c $(( ${msgLength}*${lineNum}+1 ))-$(( ${msgLength}*${lineNum}+1+${msgLength} )))
							printf "%-*s\n\n" ${msgLength} "${substr}" >> usr/searchMsg.txt
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

	test -e "${wantedName}"
	if [ $? = 0 ] ; then
		rm usr/searchByName.txt 
		return
	fi
	
	matchNum=""
	for num in $(seq 1 130); do
		eval echo \${nameArray${num}} | grep -iqF "${wantedName}"
		if [ $? = 0 ] ; then
		    matchNum=${matchNum}" ${num}"
		fi
	done

	if [ ${#matchNum} -eq 0 ] ; then
		printf "Can not find (ಥ_ʖಥ)\n" >> usr/searchMsg.txt
	else
		for num in ${matchNum}; do
			class=$(eval echo \${totalArray${num}})
			strlen=${#class}
			for lineNum in 0 1; do
				case ${lineNum} in 
					0)
						substr=$(echo ${class} | cut -c 1-${msgLength})
						printf "%-*s\n" ${msgLength} "${substr}" >> usr/searchMsg.txt
					;;
					1)

						if [ $(( ${strlen} / ${msgLength} )) -lt ${lineNum} ] ; then
							printf "\n" >> usr/searchMsg.txt
						else
							substr=$(echo ${class} | cut -c $(( ${msgLength}*${lineNum}+1 ))-$(( ${msgLength}*${lineNum}+1+${msgLength} )))
							printf "%-*s\n\n" ${msgLength} "${substr}" >> usr/searchMsg.txt
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
