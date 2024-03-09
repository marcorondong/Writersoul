#!/bin/bash

# Flag to indicate if the summary section has started
summary_started=false

# Read input from the pipeline or a file
while IFS= read -r line; do
    # Check if the summary section has started
    if [[ $line =~ 🏁 ]]; then
        summary_started=true
    fi

    # If the summary has started, print lines as is
    if [ "$summary_started" = true ]; then
        echo "$line"
        continue
    fi

    # Process only failed test lines before the summary starts
    if echo "$line" | grep -q '❌'; then
        # Extract the file path and line number
        file_path=$(echo "$line" | grep -oE '/nfs/homes/marondon/42_minishell_tester/cmds/[^ ]+\.sh')
        line_number=$(echo "$line" | grep -oE '\.sh:[0-9]+' | cut -d: -f2)

        echo "$line"
        echo ""
        if [[ -n "$file_path" && -n "$line_number" ]]; then
            echo "Test starting at line $line_number:"
            sed -n "${line_number},\$p" "$file_path" | awk 'NF {p=1} !NF {if(p) exit} {if(p) print}'
            echo "--------------------------------"
            echo ""
        else
            echo "Could not extract test details."
            echo "--------------------------------"
            echo ""
        fi
    else
        # Print headers and other lines as is, before the summary starts
        echo "$line"
    fi
done

