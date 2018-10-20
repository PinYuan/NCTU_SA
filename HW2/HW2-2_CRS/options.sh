#! /bin/bash

initOption() {
	test -e usr/options.txt
	if [ $? != 0 ]; then
		touch usr/options.txt
	fi

	ops=("Show\ classroom" "Hide\ extra\ column" "Enable\ empty\ class\ selection")
}

optionWindow() {
	selected=$(cat usr/options.txt)
	local paires

	for i in 1 2 3; do
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

	echo ${paires[@]} | xargs dialog --stdout --backtitle "Checklist" --checklist "Options" 25 60 3 > usr/options_tmp.txt
	if [ $? = 0 ] ; then # ok
		cp usr/options_tmp.txt usr/options.txt
	fi
	rm usr/options_tmp.txt
}


loadOptions() {
	selected=$(cat usr/options.txt)

	for i in 1 2 3; do
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