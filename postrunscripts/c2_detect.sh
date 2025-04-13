#!/usr/bin/env bash

    echo "Running C2 detection script"

    # Find all unique executable files in /proc/**/exe
    readarray -t executables < <(find /proc/**/exe -exec ls -l {} + 2>/dev/null | grep - | awk '{print $NF}' | sort | uniq -u)

    # Search for specific patterns in each executable
    for exe in "${executables[@]}"; do
        if [[ -e "$exe" ]]; then
            grep -lr "/usr/local/go\|sliver\|runtime.*\.go" "$exe" 2>/dev/null
        fi
    done

