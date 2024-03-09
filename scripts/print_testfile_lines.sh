#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: Just run $0 and follow the prompts."
    echo "The script will ask for the file path and the line numbers."
    exit 1
}

# Check if arguments were provided and show usage if they were
if [ "$#" -gt 0 ]; then
    echo "Error: No arguments expected."
    usage
fi

# Prompt for FILE input
echo "Enter the file path:"
read FILE

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found."
    exit 1
fi

# Prompt for LINES input
echo "Enter the comma-separated list of line numbers:"
read LINES

# Convert comma-separated line numbers into space-separated
LINE_NUMBERS=$(echo "$LINES" | tr ',' ' ')

for line in $LINE_NUMBERS; do
    echo "Test starting at line $line:"
    sed -n "${line},\$p" "$FILE" | awk 'NF {p=1} !NF {if(p) exit} {if(p) print}'
    echo "--------------------------------"
done

