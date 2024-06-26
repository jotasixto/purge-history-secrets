# This function checks the number of lines in the .zsh_history file
function check_history_lines() {
    gitleaks detect --no-git --log-level fatal -f json --no-color --no-banner --redact --source ~/.zsh_history -r ~/.report_gitleaks.json

    # Parse the JSON to extract line numbers into an array
    local -a line_numbers_array
    line_numbers_array=($(cat ~/.report_gitleaks.json | jq '.[].StartLine'))

    rm -rf ~/.report_gitleaks.json

    # Check if jq had an error or if line_numbers_array is empty
    if [[ $? -ne 0 || ${#line_numbers_array[@]} -eq 0 ]]; then
        # echo "No secrets found in ~/.zsh_history."
        exit 0
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
}

# If on VSCODE not enable the check
if [[ "$TERM_PROGRAM" != "vscode" ]]; then
    # Define the cron job command
    CRON_JOB="* * * * * /bin/zsh ~/.oh-my-zsh/custom/plugins/purge-history-secrets/purge-history-secrets.plugin.zsh"

    # Check if the cron job already exists
    CRON_EXISTS=$(crontab -l | grep -F "$CRON_JOB")

    if [ -z "$CRON_EXISTS" ]; then
        # Cron job does not exist, so add it

        # Add the cron job to the crontab
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

        # echo "Cron job has been added."
    fi

    # Start the function in the background when the terminal starts
    check_history_lines &
fi
