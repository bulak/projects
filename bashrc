[ -z "${PROJECT_NAME}" ] && export PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'

[ ! -z "${PROJECT_NAME}" ] && alias pj="jrnl ${PROJECT_NAME}"


eternal_history_dir="${HOME}/.history"
[ -d "${eternal_history_dir}" ] || mkdir -p ${eternal_history_dir}
export ETERNALHISTFILE="${eternal_history_dir}/bash_history-${HOSTNAME}"
export ETERNALIGNOREDUPS=""
hnote () {
  echo "[$(date +'%Y/%m/%d %H:%M %Z')] ## NOTE ##; $*" >> ${ETERNALHISTFILE}
}
ehist () {
  cat ${ETERNALHISTFILE} | awk 'BEGIN {
    FS="]"; OFS="]" } {
        n = index( $2, ";" );
        subdir = substr( $2, 1, n-1 );
        cmd = substr( $2, n+1 );
        print "\033[34m"$1,"\033[32m"subdir"\033[0m"cmd;}'
}

# Utility commands PROJECT
if  [ ! -z "${PROJECT_NAME}" ]; then
  # colored PROJECT history
  phist () {
    cat ${eternal_history_dir}/${PROJECT_NAME}.bash_history | awk 'BEGIN {
      FS="]"; OFS="]" } {
          n = index( $3, ";" );
          subdir = substr( $3, 1, n-1 );
          cmd = substr( $3, n+1 );
          print "\033[34m"$1,"\033[33m"$2,"\033[32m"subdir"\033[0m"cmd;}'
  }
  # sorted PROJECT history by PANE_ID
  pphist () {
    phist | sort -t] -k2,2 -k1,1
  }
  # hnote for PROJECT only
  pnote () {
    echo "[$(date +'%Y/%m/%d %H:%M %Z')] [Pane:$TMUX_PANE] ## NOTE ##; $*" >> ${eternal_history_dir}/${PROJECT_NAME}.bash_history;
  }
fi
# bin folder for projects in PATH
[ ! -z "${PROJECT_HOME}" ] && export PATH="${PROJECT_HOME}/bin:${PATH}"

# This is from https://github.com/rcaloras/bash-preexec
# Super cool function to execute stuff before prompt command execution

precmd_normal_shell () {
  history -a;
  if [ ! "$1" = "${__last_cmd}" ]; then
    echo "[$(date +'%Y/%m/%d %H:%M %Z')] $PWD; $1" >> $ETERNALHISTFILE;
  fi
  export __last_cmd="$1"
}

precmd_project_shell () {
  echo "[$(date +'%Y/%m/%d %H:%M %Z')] [Pane:$TMUX_PANE] $PWD; $1" >> ${eternal_history_dir}/${PROJECT_NAME}.bash_history;
}
preexec_functions+=(precmd_normal_shell)
[ ! -z "${PROJECT_NAME}" ] && preexec_functions+=(precmd_project_shell)

## This line should be at the end of the .bashrc script
source ~/.bash-preexec.sh
