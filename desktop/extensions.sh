#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXT_SOURCE="$CONFIG_DIR/assets/gnome-extensions"
EXT_TARGET="$HOME/.local/share/gnome-shell/extensions"

echo "[Extensions] Installing user extensions..."

mkdir -p "$EXT_TARGET"

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

    source="$EXT_SOURCE/$ext"
    target="$EXT_TARGET/$ext"

    if [[ ! -d "$source" ]]; then
        echo "[Extensions] ERROR: Missing $ext"
        exit 1
    fi

    echo "[Extensions] Installing $ext"

    rm -rf "$target"
    cp -a "$source" "$target"

done

echo "[Extensions] Compiling extension schemas..."

for ext in "${extensions[@]}"; do
    schema_dir="$EXT_TARGET/$ext/schemas"

    if [[ -d "$schema_dir" ]]; then
        glib-compile-schemas "$schema_dir"
    fi
done

echo "[Extensions] Enabling extensions..."

for ext in "${extensions[@]}"; do
    gnome-extensions enable "$ext" || true
done

echo "[Extensions] Restoring extension settings..."

declare -A dconf_paths=(
    ["blur-my-shell@aunetx"]="/org/gnome/shell/extensions/blur-my-shell/"
    ["dash-to-dock@micxgx.gmail.com"]="/org/gnome/shell/extensions/dash-to-dock/"
    ["user-theme@gnome-shell-extensions.gcampax.github.com"]="/org/gnome/shell/extensions/user-theme/"
    ["compiz-alike-magic-lamp-effect@hermes83.github.com"]="/org/gnome/shell/extensions/ncom/github/hermes83/compiz-alike-magic-lamp-effect/"
    ["Vitals@CoreCoding.com"]="/org/gnome/shell/extensions/vitals/"
    ["compiz-windows-effect@hermes83.github.com"]="/org/gnome/shell/extensions/com/github/hermes83/compiz-windows-effect/"
    ["ddcbrightness@lucaso.io"]="/org/gnome/shell/extensions/ddcbrightness/"
)

for ext in "${extensions[@]}"; do

    config="$CONFIG_DIR/config/extensions/$ext.dconf"
    path="${dconf_paths[$ext]}"

    if [[ -f "$config" && -s "$config" ]]; then
        echo "[Extensions] Restoring $ext settings"
        dconf load "$path" < "$config"
    fi

done

echo "[Extensions] Done."
