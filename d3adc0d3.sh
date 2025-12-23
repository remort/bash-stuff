#!/bin/bash

# Finds unused functions, classes and module-level variables in python code located in target directory.

if [ -z "$1" ]; then
    directory="."
else
    directory="$1"
fi

while read -r file_name function_name; do
    grep -qPr --include="*.py" "\bdef $function_name\b(*SKIP)(*FAIL)|\b$function_name\b" "$directory"

    if [ $? -eq 1 ]; then
        echo "Function $function_name in \"$file_name\" is not used"
    fi
done <<< $( grep -r --include="*.py" "def " ${directory} | sed -E 's/[ ]*(async )?def ([a-zA-Z0-9_]+)[\[\(].*$/\2/' | sort | uniq | awk -F ':' '{print $1" "$2}' )

while read -r file_name class_name; do
    grep -qPr --include="*.py" "\bclass $class_name\b(*SKIP)(*FAIL)|\b$class_name\b" "$directory"

    if [ $? -eq 1 ]; then
        echo "Class $class_name in \"$file_name\" is not used"
    fi
done <<< $( grep -r --include="*.py" "class [\(\)a-zA-Z0-9_-]*:" ${directory} | sed -E 's/class ([a-zA-Z0-9_]+)[\(:].*$/\1/' | sort | uniq | awk -F ':' '{print $1" "$2}' )

while read -r file_name variable_name; do
    grep -qPr --include="*.py" "\b$variable_name\b = (*SKIP)(*FAIL)|\b$variable_name\b" "$directory"

    if [ $? -eq 1 ]; then
        echo "Variable $variable_name in \"$file_name\" is not used"
    fi
done <<< $( grep -Er --include="*.py" "(^\b[a-zA-Z0-9_]+\b) = " -o ${directory} | sed -E 's/(\b[a-zA-Z0-9_]+\b) = /\1/'  | sort | uniq | awk -F ':' '{print $1" "$2}' )
