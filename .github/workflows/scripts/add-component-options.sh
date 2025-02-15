#!/usr/bin/env sh
#
#   Copyright The OpenTelemetry Authors.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Takes the list of components from the CODEOWNERS file and inserts them
# as a YAML list in a GitHub issue template, then prints out the resulting
# contents.
#
# Note that this is script is intended to be POSIX-compliant since it is
# intended to also be called from the Makefile on developer machines,
# which aren't guaranteed to have Bash installed.

if [ -z "${FILE}" ]; then
  echo 'FILE is empty, please ensure it is set.'
  exit 1
fi

COMPONENT_REGEX='(cmd|pkg|extension|processor|receiver|exporter)'

# Get the line number for text within a file
get_line_number() {
  text=$1
  file=$2
  
  grep -n "${text}" "${file}" | awk '{ print $1 }' | grep -oE '[0-9]+'
}

START_LINE=$(get_line_number '# Start Collector components list' "${FILE}")
END_LINE=$(get_line_number '# End Collector components list' "${FILE}")
TOTAL_LINES=$(wc -l "${FILE}" | awk '{ print $1 }')

head -n "${START_LINE}" "${FILE}"
grep -E "^${COMPONENT_REGEX}" < ".github/CODEOWNERS" | \
  awk '{ print $1 }' | \
  sed -E 's%(.+)/$%\1%' | \
  sed -E "s%${COMPONENT_REGEX}/(.+)${COMPONENT_REGEX}%\1/\2%" | \
  sort | \
  awk '{ printf "      - %s\n",$1 }'
tail -n $((TOTAL_LINES-END_LINE+1)) "${FILE}"

