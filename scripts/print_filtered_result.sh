#!/bin/bash

# Prompt for test mode
echo "Enter the test mode (m, vm, d, ne, b):"
read test_mode

# Function to normalize yes/no answers
normalize_input() {
    case "$1" in
        y|Y|yes|YES)
            echo "yes"
            ;;
        n|N|no|NO)
            echo "no"
            ;;
        *)
            echo "invalid"
            ;;
    esac
}

# Ask if all parts should be included
echo "Include all tested parts? (STD_OUT, STD_ERR, EXIT_CODE, LEAKS) [y/n]:"
read include_all
include_all=$(normalize_input "$include_all")

# Initialize the awk command
awk_cmd="awk '"

# Always print headers, subheaders, and the summary section, and detect the start of the summary section
awk_cmd+="/🚀|#|🏁/ {print; if(/🏁/) inSummary=1; next;} "

# If not including all parts, add conditions for selected test parts
if [ "$include_all" != "yes" ]; then
    echo "Include STD_OUT? [y/n]:"
    read include_stdout
    include_stdout=$(normalize_input "$include_stdout")
    if [ "$include_stdout" == "yes" ]; then
        awk_cmd+="/STD_OUT: ❌/ && !inSummary {print; next;} "
    fi

    echo "Include STD_ERR? [y/n]:"
    read include_stderr
    include_stderr=$(normalize_input "$include_stderr")
    if [ "$include_stderr" == "yes" ]; then
        awk_cmd+="/STD_ERR: ❌/ && !inSummary {print; next;} "
    fi

    echo "Include EXIT_CODE? [y/n]:"
    read include_exitcode
    include_exitcode=$(normalize_input "$include_exitcode")
    if [ "$include_exitcode" == "yes" ]; then
        awk_cmd+="/EXIT_CODE: ❌/ && !inSummary {print; next;} "
    fi

    echo "Include LEAKS? [y/n]:"
    read include_leaks
    include_leaks=$(normalize_input "$include_leaks")
    if [ "$include_leaks" == "yes" ]; then
        awk_cmd+="/LEAKS: ❌/ && !inSummary {print; next;} "
    fi
else
    # If including all parts, print any line with a failure
    awk_cmd+="/❌/ && !inSummary {print;} "
fi

# Print all lines once in the summary section
awk_cmd+="inSummary {print}'"

# Use the full path to the tester.sh script, apply sed to remove ANSI escape codes, and then apply the awk command
eval "bash /nfs/homes/marondon/42_minishell_tester/tester.sh $test_mode | sed -e 's/\x1b\[[0-9;]*m//g' | $awk_cmd"

