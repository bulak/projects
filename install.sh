#!/bin/bash

# Need to check
# tmux (can use screen instead?)
# tmuxp (screen alternative?)
# jrnl (optional?)
# add_jrnl (not in bashrc, missing file)
# also project.yaml is missing


req_passed=1
required=( "./projects" "./bashrc" "./ThirdParty/bash-preexec/.bash-preexec.sh" )
for req_file in "${required[@]}"; do
	if [ ! -f $req_file ]; then
		echo "Could not locate required file: ${req_file}"
		req_passed=0
	fi
done
if (( $req_passed )); then
	echo "Installation will copy required files to your user home directory,"
    read -r -p "and modify your .bashrc file. Proceed (y/N)? " response
    case $response in
        [yY][eE][sS]|[yY])
			cp ~/.bashrc ~/.bashrc.old
			cp ./projects ~/
			cp ./ThirdParty/bash-preexec/.bash-preexec.sh ~/
			cat ./bashrc >> ~/.bashrc
        ;;
        *)
			exit 0
	esac
else
	echo "Missing one or more required installation files. Aborting."
	exit 1
fi
