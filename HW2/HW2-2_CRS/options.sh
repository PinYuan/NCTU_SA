#! /bin/bash

initOption() {
	test -e usr/options.txt
	if [ $? != 0 ]; then
		touch usr/options.txt
	fi

	ops=("Show\ classroom" "Hide\ extra\ column")
}

optionWin() {
	selected=$(cat usr/options.txt)
	local paires

	for i in 1 2; do
		have=1
		for num in ${selected}; do
			if [ "${i}" = "${num}" ] ; then
				have=0
				break
			fi
		done
		if [ ${have} = 0 ] ; then
			paires+=(${i} ${ops[$(( ${i}-1 ))]} on)
		else
			paires+=(${i} ${ops[$(( ${i}-1 ))]} off)
		fi
	done

	echo ${paires[@]} | xargs dialog --stdout --backtitle "Checklist" --checklist "Options" 25 60 2 > usr/options.txt
}