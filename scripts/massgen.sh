#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

scripts/wordgen.js "${1-CVCV}" "$(expr ${2-8} \* ${3-8})" \
  | xargs -n ${2-8} \
  | column -t -s' '
