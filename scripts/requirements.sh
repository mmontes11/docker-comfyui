#!/usr/bin/env bash
set -euo pipefail

# Install custom node requirements from remote URLs
# Usage: scripts/requirements.sh [constraints_file]
# Constraints file defaults to /app/constraints.txt

CONSTRAINTS="${1:-/app/constraints.txt}"

# ComfyUI custom node requirements (one URL per line)
read -r -d '' REQ_URLS << 'EOF' || true
https://raw.githubusercontent.com/kijai/ComfyUI-KJNodes/refs/heads/main/requirements.txt
https://raw.githubusercontent.com/yolain/ComfyUI-Easy-Use/refs/heads/main/requirements.txt
https://raw.githubusercontent.com/sipherxyz/comfyui-art-venture/refs/heads/main/requirements.txt
EOF

while IFS= read -r url; do
    # Skip empty lines and comments
    [[ -z "$url" || "$url" == \#* ]] && continue

    echo "Installing requirements from: $url"

    # Download to a temp file, install, then clean up
    tmpfile=$(mktemp)
    if curl -fsSL "$url" -o "$tmpfile"; then
        pip install -r "$tmpfile" -c "$CONSTRAINTS"
    else
        echo "ERROR: Failed to download $url"
        exit 1
    fi
    rm -f "$tmpfile"
done <<< "$REQ_URLS"


