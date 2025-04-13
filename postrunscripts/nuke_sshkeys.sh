#!/usr/bin/env bash

LOG_DIR="/root/ssh_key_logs"
mkdir -p "$LOG_DIR"

echo "[*] Fast SSH key cleanup with logging — logs in $LOG_DIR"

get_authorized_keys_paths() {
    local default=".ssh/authorized_keys .ssh/authorized_keys2"
    grep -iE "^AuthorizedKeysFile" /etc/ssh/sshd_config 2>/dev/null | awk '{$1=""; print $0}' | sed 's/^[ \t]*//' || echo "$default"
}

get_users() {
    awk -F: '($3 >= 1000 && $7 !~ /false|nologin/) { print $1 }' /etc/passwd
}

is_key_file() {
    local file="$1"
    grep -E -m 1 'BEGIN (OPENSSH|RSA|DSA|EC) PRIVATE KEY|^ssh-(rsa|ed25519|ecdsa)' "$file" 2>/dev/null | grep -qE '.'
}

# Save the key and metadata before deletion
log_and_remove_key_file() {
    local file="$1"
    [[ "$file" == *"ssh_host_"* ]] && return
    [[ ! -f "$file" || ! -r "$file" ]] && return
    if is_key_file "$file"; then
        encoded_path=$(echo "$file" | sed 's|/|_|g' | sed 's|^_||')
        cp "$file" "$LOG_DIR/${encoded_path}.key"
        stat "$file" > "$LOG_DIR/${encoded_path}.meta"
        echo "[!] Removed: $file → Logged to $LOG_DIR/${encoded_path}.key"
        shred -u "$file"
    fi
}

PRIVATE_KEY_NAMES=(id_rsa id_dsa id_ecdsa id_ed25519)
AUTHORIZED_PATHS=($(get_authorized_keys_paths))

for user in $(get_users); do
    home_dir=$(eval echo "~$user")
    for rel_path in "${AUTHORIZED_PATHS[@]}"; do
        clean_path="${rel_path//%h/$home_dir}"
        [[ "$clean_path" == ~* ]] && clean_path="$home_dir/${clean_path#\~}"
        log_and_remove_key_file "$clean_path"
    done
    for key_name in "${PRIVATE_KEY_NAMES[@]}"; do
        log_and_remove_key_file "$home_dir/.ssh/$key_name"
    done
done

# Also handle root
for rel_path in "${AUTHORIZED_PATHS[@]}"; do
    clean_path="${rel_path//%h//root}"
    [[ "$clean_path" == ~* ]] && clean_path="/root/${clean_path#\~}"
    log_and_remove_key_file "$clean_path"
done

for key_name in "${PRIVATE_KEY_NAMES[@]}"; do
    log_and_remove_key_file "/root/.ssh/$key_name"
done

echo "[*] Cleanup complete. Logs saved to: $LOG_DIR"
