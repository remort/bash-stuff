#!/bin/bash

# Finds unused function defenitions in python code located in target directory.

if [ -z "$1" ]; then
    directory="."
else
    directory="$1"
fi

while read -r function_name; do
    grep -qPr --include="*.py" "\bdef $function_name\b(*SKIP)(*FAIL)|\b$function_name\b" "$directory"

    if [ $? -eq 1 ]; then
        echo "$function_name is not used"
    fi
done <<< $( grep -rh --include="*.py" "def " ${directory} | sed -E 's/[ ]*(async )?def ([a-zA-Z0-9_]+)\(.*$/\2/' | sort | uniq )
