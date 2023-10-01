# This function checks the number of lines in the .zsh_history file
function check_history_lines() {
    while true; do
        local json_trivy=$(trivy fs -f json --scanners secret ~/.zsh_history 2>/dev/null)

        # Parse the JSON to extract line numbers into an array
        local -a line_numbers_array
        line_numbers_array=($(printf "%s\n" "$json_trivy" | jq 'if .Results then .Results[].Secrets[].Code.Lines[].Number else empty end'))


        # Check if jq had an error or if line_numbers_array is empty
        if [[ $? -ne 0 || ${#line_numbers_array[@]} -eq 0 ]]; then
            sleep 60
            continue
        fi
        
        # Sort the array in descending order
        sorted_line_numbers=($(printf "%s\n" "${line_numbers_array[@]}" | sort -rn))

        # Empty the log file before appending new data
        # > ~/.purge-secrets-zshhistory.log

        # Iterate over sorted numbers and run sed for each
        for number in "${sorted_line_numbers[@]}"; do
            line_content=$(sed -n "${number}p" ~/.zsh_history 2>/dev/null)
            if [[ $? -ne 0 ]]; then
                echo "Error reading line $number from ~/.zsh_history." >&2
                continue  # skip to the next iteration
            fi

            # Delete the line from ~/.zsh_history
            sed -i "${number}d" ~/.zsh_history

            echo "$(date '+%Y-%m-%d %H:%M:%S') - $number line purged from history" >> ~/.purge-secrets-zshhistory.log
        done

        sleep 60
    done
}

# Start the function in the background when the terminal starts
check_history_lines &
