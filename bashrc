[ -z "${PROJECT_NAME}" ] && export PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'

# bin folder for projects in PATH
[ ! -z "${PROJECT_HOME}" ] && export PATH="${PROJECT_HOME}/bin:${PATH}"

