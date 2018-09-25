#!/bin/bash

def_install_path="~/.local/bin"
def_bashrc_path="~/.bashrc_projects"

# do we have these?
cmds=( "pip" "screen" "tmux" "tmuxp" "whiptail" "dialog"
       "flock" "lockfile" "jrnl" )
declare -A have_cmd=()
for cmd in ${cmds[@]}; do
  command -v ${cmd} >/dev/null 2>&1 && have_cmd[${cmd}]=true
done

# Install path is not optional for now
install_path=$( systemd-path user-binaries 2>/dev/null )
[ -z ${install_path} ] && install_path="${def_install_path}"

# helper functions
quit() {
  echo "Installation of 'projects' is cancelled."
  exit 1
}

contains() { [ -z "${1##*$2*}" ] && [ -n "$1" ]; }

# set-up which dialog we will use
# whiptail > dialog > cli_dialog
if [ "${have_cmd[whiptail]}" = true ]; then
  dialog="whiptail"
elif [ "${have_cmd[dialog]}" = true ]; then
  dialog="dialog"
else
  source cli_dialog.sh && dialog="cli_dialog"
fi

quit_if_not() {
  if [ "${have_cmd[${1}]}" != true ]; then
      case ${dialog} in
        whiptail)
        whiptail --msgbox "${2}" 10 65
      ;;
      dialog)
        dialog --msgbox "${2}" 10 65
      ;;
      cli_dialog)
              echo "${2}"
          ;;
      esac
      quit
  fi
}

need_this_or_that() {
  if [ "${have_cmd[${1}]}" != true ] && [ "${have_cmd[${2}]}" != true ]; then
    msg="'projects' depends on '${1}' or '${2}'. Installation will\
 continue, however, 'projects' will not work!\n"
    question=" Do you want to continue?"
    case ${dialog} in
      whiptail)
        whiptail --yesno "${msg}\n${question}" 10 65
      ;;
      dialog)
        dialog --yesno "${msg}\n${question}" 10 65
      ;;
      cli_dialog)
        yesno "${msg}" "${question}"
      ;;
    esac
    if [ $? -ne 0 ]; then
      quit
    fi
  fi
}

# check dependencies and requirements
need_this_or_that "tmux" "screen"
need_this_or_that "flock" "lockfile"

# tmux (default) or screen
opt_str=( "tmux" "screen" )
title="Which multiplexer will be used with 'projects'?"
options=("1" "tmux" "on" "2" "screen" "off")
case ${dialog} in
  whiptail)
    multplexer=$(whiptail --radiolist "${title}" 10 42 2 "${options[@]}" 3>&2 2>&1 1>&3)
    ;;
  dialog)
    multplexer=$(dialog --radiolist "${title}" 10 42 4 "${options[@]}" 3>&1 1>&2 2>&3 3>&-)
    ;;
  cli_dialog)
    multplexer=$(radiolist "${title}" "${options[@]}")
    ;;
  *)
    echo "Make sure that 'cli_dialog.sh' is in the same directory as 'install.sh'"
    exit 1
esac
multplexer=${opt_str[$((multplexer - 1))]}

# Options
opt_str=( "ehist" "phist" "jrnl" "autocompl" )
title="Which options should be enabled?"
options=("1" "Eternal bash history" "on" 
         "2" "Project bash history" "on" 
         "3" "Project journaling" "off" 
         "4" "Autocompletion for 'projects'" "off")
case ${dialog} in
  whiptail)
    optional=($(whiptail --checklist "${title}" 12 47 4 "${options[@]}" 3>&2 2>&1 1>&3))
    ;;
  dialog)
    optional=($(dialog --checklist "${title}" 12 50 8 "${options[@]}" 3>&1 1>&2 2>&3 3>&-))
    ;;
  cli_dialog)
    optional=($(checklist "${title}" "${options[@]}"))
    ;;
  *)
    optional=( )
esac
for ((i=0; i<${#optional[@]}; i++)); do
  unquoted_opt="${optional[$i]//\"}"
  val="${opt_str[$((unquoted_opt - 1))]}"
  optional[$i]=${val}
done
option_str="${optional[@]}"

# Setting up installation string that will be eval at the end
install_script=""
bashrc_file="./bashrc_temp_preinstall"

# tmux or screen
case ${multplexer} in
  tmux)
    quit_if_not "tmuxp" "You have selected 'tmux' as the multiplexer to be used\
 with 'projects'. This requires 'tmuxp'; however, I couldn't find it. You can\
 install it by 'pip install [--user] tmuxp'. The installation will terminate."
    install_script="${install_script} install ./src/projects_tmux ${install_path}/projects;\
 cp ./src/project.yaml ~/.tmuxp/;"
  ;;
  screen)
    install_script="${install_script} install ./src/projects_screen ${install_path}/projects;"
  ;;
  *)
    echo "Error: Multiplexer selected could be one of following: tmux, screen."
    quit
esac
echo -e "\n\n# PROJECTS modifications -- $(date +"%Y-%m-%d")" > ${bashrc_file}
cat ./src/bashrc >> ${bashrc_file}

# Is install path in PATH?
case :$PATH: in
  *:${install_path}:*)
  ;; # do nothing, it's there
  *)
    echo "PATH=\"\$PATH:${install_path}\"" >> ${bashrc_file}
    echo >> ${bashrc_file}
  ;;
esac

# Is bash-completion requested?
if contains "${option_str}" "autocompl"; then
  install_script="${install_script} cp ./src/projects_autocompletion ~/.projects_autocompletion.sh;"
  cat ./src/bashrc_autocompletion >> ${bashrc_file}
fi

# Is journaling requested?
if contains "${option_str}" "jrnl"; then
  quit_if_not "jrnl" "You have selected the 'Project journaling'. This option\
 depends on 'jrnl'; however, I couldn't find it. You can install it by 'pip\
 install [--user] jrnl'. Either re-try installation without 'journaling'\
 or install 'jrnl' first."
 install_script="${install_script} install ./src/add_jrnl.py ${install_path}/add_jrnl;"
 cat ./src/bashrc_journaling >> ${bashrc_file}
fi

# Is eternal history for bash requested?
if contains "${option_str}" "ehist"; then
  cat ./src/bashrc_eternal_history >> ${bashrc_file}
  option_str="${option_str} pre-exec"
fi

# Is eternal history for projects requested?
if contains "${option_str}" "phist"; then
  cat ./src/bashrc_project_history >> ${bashrc_file}
  option_str="${option_str} pre-exec"
fi

# Ask if user prefer us to modify the .bashrc or not
msg="A small bash script needs to be sourced from user's .bashrc file.\n\
It can be done by executing\n\necho \"source ${def_bashrc_path}\" >> ~/.bashrc\
\n\nI can do it for you (and keep a copy of .bashrc as .bashrc.old).\n"
question=" Do you want me to modify your .bashrc file?"
case ${dialog} in
  whiptail)
    whiptail --yesno "${msg}\n${question}" 15 70
  ;;
  dialog)
    dialog --yesno "${msg}\n${question}" 15 70
  ;;
  cli_dialog)
    yesno "${msg}" "${question}"
  ;;
esac
if [ $? -eq 0 ]; then
  install_script="${install_script} cp ~/.bashrc ~/.bashrc.old;\
 echo \"# This is added by 'projects', remove if redundant\" >> ~/.bashrc;\
 echo \"source ${def_bashrc_path}\" >> ~/.bashrc;"
fi

# Is pre-exec required?
if contains "${option_str}" "pre-exec"; then
  install_script="${install_script} cp ./ThirdParty/bash-preexec/.bash-preexec.sh ~;"
  echo -e "\n# This sourcing is necessary for eternal histories" >> ${bashrc_file}
  echo "source ~/.bash-preexec.sh" >> ${bashrc_file}
fi

# finalization
install_script="${install_script} mv ${bashrc_file} ${def_bashrc_path};"
echo -e "\n# END OF PROJECTS modifications -- $(date +"%Y-%m-%d")" >> ${bashrc_file}
echo "# -----------------------------" >> ${bashrc_file}

# installation
eval "${install_script}"
