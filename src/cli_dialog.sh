#!/bin/bash

print_menu() {
    declare -A status=( [on]="[x]" [off]="[ ]" )
    args=("$@")
    half=$((${#args[@]} / 2 ))
    options=("${args[@]::${half}}")
    selected=("${args[@]:${half}}")
    for ((i = 1; i<= half; i++)); do
    	o_i=$((i - 1))
       	echo "${status[${selected[${o_i}]}]}  ${i} - ${options[${o_i}]} " >&2
    done
}

multilist() {
	listmode="${1}"
    echo "${2}" >&2
    echo
    shift 2
    values=()
    options=()
    selected=()
    option_count=$(($# / 3))
    for ((i = 1; i<= option_count; i++));  do
        v=$((i * 3 - 2))
        o=$((v + 1))
        s=$((v + 2))
		values+=( "${!v}" )
		options+=( "${!o}" )
		selected+=( "${!s}" )
	done
	while true; do
		echo >&2
		print_menu "${options[@]}" "${selected[@]}"
		echo >&2 
		read -p "Your choice [1- ${option_count}] Toggle, [C] Cancel, [ENTER] OK: " selection
		if [ -z ${selection} ]; then
			result=()
			for ((i = 0; i < ${option_count}; i++)); do
				if [ ${selected[${i}]} = "on" ]; then
					if [ ${listmode} = "checklist" ]; then					
						result+=( "\"${values[${i}]}\"" )
					else
						result+=( "${values[${i}]}" )
					fi
				fi
			done
			echo "${result[@]}"
			break
		elif ((1<=selection && selection<=option_count)); then
			option_idx=$((selection - 1))
			if [ ${listmode} = "checklist" ]; then
				if [ ${selected[${option_idx}]} = "on" ]; then
					selected[${option_idx}]="off"
				else
					selected[${option_idx}]="on"
				fi
			elif [ ${listmode} = "radiolist" ]; then
				for ((i = 0; i < ${option_count}; i++)); do
					if [ ${option_idx} = ${i} ]; then
						selected[${i}]="on"
					else
						selected[${i}]="off"
					fi
                done
            fi
	    elif [ ${selection} = "C" ]; then
	    	return 1
	    else
	    	echo "Did not understand..." >&2
	    fi
    done
    return 0
}


checklist() {
	multilist "checklist" "$@"
}

radiolist() {
	multilist "radiolist" "$@"
}

yesno() {
	while true; do
		echo -e "${1}"
		read -r -p "${2} [Yes/No]: " response
		case $response in
			[Nn][Oo]|[Nn])
				return 1
			;;
			[Yy][Ee][Ss]|[Yy])
				return 0
			;;
			*)
				echo "Please use [Yes/No]"
			;;
		esac
	done
	return 1
}

# selection=( $( radiolist  "Which options should be enabled?" 1 "Eternal bash history" on 2 "Project bash history" off 3 "Project journaling" off 4 "Autocompletion for 'projects'" off ) )
# echo ${selection[@]}
# selection=( $( whiptail --checklist "Which options should be enabled?" 10 47 4 1 "Eternal bash history" on 2 "Project bash history" on 3 "Project journaling" off 4 "Autocompletion for 'projects'" off 3>&2 2>&1 1>&3 ) )
# echo ${selection[@]}
# selection=( $( dialog --checklist "Which options should be enabled?" 12 47 8 1 "Eternal bash history" on 2 "Project bash history" on 3 "Project journaling" off 4 "Autocompletion for 'projects'" off 3>&1 1>&2 2>&3 3>&- ) )
# echo ${selection[@]}