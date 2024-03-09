#!/bin/bash

# Prompt for test mode and store the response
echo "Enter the test mode (m, vm, d, ne, b):"
read test_mode

# Function to normalize yes/no answers
normalize_input() {
    case "$1" in
        y|Y|yes|YES) echo "yes" ;;
        n|N|no|NO) echo "no" ;;
        *) echo "invalid" ;;
    esac
}

# Collect all inputs first
echo "Include all tested parts? (STD_OUT, STD_ERR, EXIT_CODE, LEAKS) [y/n]:"
read include_all
include_all=$(normalize_input "$include_all")

declare -A parts_selection
if [ "$include_all" == "yes" ]; then
    # If "yes" is selected for including all parts, set all parts to "yes"
    parts_selection[STD_OUT]="yes"
    parts_selection[STD_ERR]="yes"
    parts_selection[EXIT_CODE]="yes"
    parts_selection[LEAKS]="yes"
else
    # Otherwise, ask for each part individually
    echo "Include STD_OUT? [y/n]:"
    parts_selection[STD_OUT]=$(normalize_input "$(read input; echo $input)")

    echo "Include STD_ERR? [y/n]:"
    parts_selection[STD_ERR]=$(normalize_input "$(read input; echo $input)")

    echo "Include EXIT_CODE? [y/n]:"
    parts_selection[EXIT_CODE]=$(normalize_input "$(read input; echo $input)")

    echo "Include LEAKS? [y/n]:"
    parts_selection[LEAKS]=$(normalize_input "$(read input; echo $input)")
fi

# Run the test, remove ANSI escape codes, and process the output
bash /nfs/homes/marondon/42_minishell_tester/tester.sh $test_mode | sed -e 's/\x1b\[[0-9;]*m//g' | while IFS= read -r line; do
    if [[ $line =~ 🚀|# ]]; then
        echo "$line"  # Print headers and subheaders
    elif [[ $line =~ 🏁 ]]; then
        inSummary=true  # Flag to indicate summary section start
        echo "$line"
    elif [[ "$inSummary" == true ]]; then
        echo "$line"  # Print summary lines
    elif [[ "${line}" =~ ❌ ]]; then
        for part in "${!parts_selection[@]}"; do
            if [[ "${parts_selection[$part]}" == "yes" && "$line" =~ "$part: ❌" ]]; then
                echo "$line"  # Print the failed test line
                # Extract file path and line number from the test line
                file_path=$(echo "$line" | grep -oE '/[^ ]+\.sh')
                line_number=$(echo "$line" | grep -oE '\.sh:[0-9]+' | cut -d: -f2)
                # Print the test content
                echo "Test starting at line $line_number:"
                sed -n "${line_number},\$p" "$file_path" | awk 'NF {p=1} !NF {if(p) exit} {if(p) print}'
                echo "--------------------------------"
                break  # Proceed to the next line after printing the test content
            fi
        done
    fi
done

