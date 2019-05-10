#!/usr/bin/env bash

# add_note - .org based -

:<<'LICENSE'
MIT License

Copyright (c) 2019 A. Bulak Arpat

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
LICENSE

function join_tags { local IFS=":"; echo "$*"; }

timestamp="[$(date +"%Y-%m-%d %a %H:%M")]"
title="* "
tags=("self_note")
message=""
output=1

if [ -t 1 ]; then
  if [ -z "${ORG_BOOK}" ]; then
    (>&2 echo "Warning: ORG_BOOK environmental variable " \
     "was not set. Will print on STDOUT")
  else
    exec {output}>>${ORG_BOOK}
  fi
fi

while [[ $# > 0 ]]; do
  key="$1"
  case $key in
    -t|--tag)
    tags+=("$2")
    shift
    shift
    ;;
    *)
    message="${message}${key} "
    shift
    ;;
  esac
done

[ -z "${message}" ] && read -r -p "> " message
tag_str=$(join_tags "${tags[@]}")
cat >&$output << EOL
$(printf "%-25s %55s" "${title}${timestamp}" :${tag_str}:)

$(echo "${message}" | fold -s -w80)

EOL