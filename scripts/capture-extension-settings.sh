#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$CONFIG_DIR/config/extensions"

mkdir -p "$OUTPUT_DIR"

extensions=(
    "blur-my-shell@aunetx"
    "dash-to-dock@micxgx.gmail.com"
    "user-theme@gnome-shell-extensions.gcampax.github.com"
    "compiz-alike-magic-lamp-effect@hermes83.github.com"
    "Vitals@CoreCoding.com"
    "compiz-windows-effect@hermes83.github.com"
    "ddcbrightness@lucaso.io"
)

for ext in "${extensions[@]}"; do

    echo
    echo "========================================"
    echo "Capturing: $ext"
    echo "========================================"

    extension_path="$(
        gnome-extensions show "$ext" |
        awk -F': ' '/Path:/ {print $2}'
    )"

    schema_file="$(
        find "$extension_path/schemas" \
            -maxdepth 1 \
            -name '*.gschema.xml' \
            -print -quit
    )"

    if [[ ! -f "$schema_file" ]]; then
        echo "WARNING: No schema found."
        continue
    fi

    dconf_path="$(
        grep -oP 'path="\K[^"]+' "$schema_file" |
        head -1
    )"

    if [[ -z "$dconf_path" ]]; then
        echo "WARNING: Could not determine dconf path."
        continue
    fi

    echo "Schema: $schema_file"
    echo "DConf path: $dconf_path"

    output_file="$OUTPUT_DIR/${ext}.dconf"

    dconf dump "$dconf_path" > "$output_file"

    echo "Saved: $output_file"
    echo "Lines: $(wc -l < "$output_file")"
done
