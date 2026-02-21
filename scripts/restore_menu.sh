#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/variables.sh"
source "$CURRENT_DIR/helpers.sh"

resurrect_dir="$(resurrect_dir)"

while true; do
    clear
    files=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && files+=("$line")
    done <<< "$(ls -1t "$resurrect_dir"/${RESURRECT_FILE_PREFIX}_*.${RESURRECT_FILE_EXTENSION} 2>/dev/null)"

    if [ ${#files[@]} -eq 0 ]; then
        echo "No resurrect files found."
        sleep 2
        exit 0
    fi

    echo "=== Tmux Resurrect - Saved Sessions ==="
    echo "Select a session to restore, or type 'rm <number>' to delete."
    echo "--------------------------------------------------------"
    echo "0) last (default)"
    for i in "${!files[@]}"; do
        filename=$(basename "${files[$i]}")
        name=${filename#${RESURRECT_FILE_PREFIX}_}
        name=${name%.${RESURRECT_FILE_EXTENSION}}
        echo "$((i+1))) $name"
    done
    echo "--------------------------------------------------------"
    echo "Enter a number, 'rm <number>', or 'q' to quit."
    read -p "> " choice

    if [[ "$choice" == rm\ * ]]; then
        idx=${choice#rm }
        if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -gt 0 ] && [ "$idx" -le "${#files[@]}" ]; then
            file_to_rm="${files[$((idx-1))]}"
            rm -f "$file_to_rm"
            echo "Deleted $(basename "$file_to_rm")"
            sleep 1
        else
            echo "Invalid selection for removal."
            sleep 1
        fi
    elif [ "$choice" = "0" ]; then
        tmux run-shell -b "\"$CURRENT_DIR/restore.sh\""
        exit 0
    elif [ "$choice" = "q" ]; then
        exit 0
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -gt 0 ] && [ "$choice" -le "${#files[@]}" ]; then
        filename=$(basename "${files[$((choice-1))]}")
        tmux run-shell -b "\"$CURRENT_DIR/restore.sh\" \"\" \"$filename\""
        exit 0
    else
        echo "Invalid choice."
        sleep 1
    fi
done
