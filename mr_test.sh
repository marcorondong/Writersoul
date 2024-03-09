#!/bin/bash

# Function to check for yes/no response
function is_yes {
    case "$1" in
        [yY] | [yY][eE][sS]) true ;;
        *) false ;;
    esac
}

function is_no {
    case "$1" in
        [nN] | [nN][oO]) true ;;
        *) false ;;
    esac
}

# Ask about temp file removal first
echo "Remove the temp file(s) after completion? (Y/n):"
read remove_temp
remove_temp=${remove_temp:-yes}

# Ask about creating a temp file for each execution
echo "Create a temp file for each execution/iteration? (y/N):"
read unique_temp_files
unique_temp_files=${unique_temp_files:-no}

if is_yes "$unique_temp_files"; then
    echo "Enter the prefix for the temp filenames:"
    read temp_file_prefix
    temp_file_prefix=${temp_file_prefix:-temp_output}
fi

echo "Enter the name for the results folder (default: 'results'):"
read results_folder
results_folder=${results_folder:-results}

# Create results folder if it doesn't exist
mkdir -p "$results_folder"

# Ask about creating a folder for temp files
echo "Create a folder for storing temp files? (y/N):"
read create_logs_folder
create_logs_folder=${create_logs_folder:-no}

if is_yes "$create_logs_folder"; then
    logs_folder="$results_folder/Logs"
    mkdir -p "$logs_folder"
fi

echo "Enter the arguments for 'philo':"
read philo_args

echo "Enter the number of iterations/tests to perform:"
read iterations

echo "Enter the duration (in seconds) for each test:"
read duration

echo "Enter the command(s) to be applied to 'philo' output (default: 'wc -l'):"
read output_command
output_command=${output_command:-'wc -l'}

echo "Enter the name for the results file:"
read results_file

# Full path to the results file
results_file_path="$results_folder/$results_file"

# Initialize the results file
> "$results_file_path"

for ((i=1; i<=iterations; i++)); do
    printf -v iter "%02d" $i  # Format iteration number with 2 digits

    # Determine temp file name and path
    if is_yes "$unique_temp_files"; then
        temp_file="$temp_file_prefix"_"$iter.txt"
        if is_yes "$create_logs_folder"; then
            temp_file="$logs_folder/$temp_file"
        else
            temp_file="$results_folder/$temp_file"
        fi
    else
        temp_file="temp_output.txt"
        temp_file="$results_folder/$temp_file"
    fi

    echo "Executing 'philo' with arguments: $philo_args (Iteration $iter)"
    ./philo $philo_args > "$temp_file" &
    PH_PID=$!

    sleep "$duration"
    if kill -0 $PH_PID 2>/dev/null; then
        kill -9 $PH_PID
        wait $PH_PID 2>/dev/null
    fi

    $output_command < "$temp_file" >> "$results_file_path"
done

# Remove temp files if required
if is_yes "$remove_temp"; then
    if is_yes "$create_logs_folder"; then
        # If a separate logs folder was created for temp files, remove the entire folder
        rm -rf "$logs_folder"
    else
        if is_yes "$unique_temp_files"; then
            # If unique temp files were created with a prefix and stored in the results folder, remove them individually
            rm -f "$results_folder/$temp_file_prefix"_*.txt
        else
            # If a single temp file was used and stored in the results folder, remove it
            rm -f "$results_folder/temp_output.txt"
        fi
    fi
fi

# Output the results file content
echo "Test completed. Results stored in '$results_file_path'."
echo "Results:"
cat "$results_file_path"

