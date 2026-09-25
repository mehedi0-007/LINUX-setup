#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[GNOME] Applying workspace configuration..."

gsettings set org.gnome.mutter dynamic-workspaces true
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

echo "[GNOME] Applying window behavior..."

gsettings set org.gnome.desktop.wm.preferences focus-mode 'click'
gsettings set org.gnome.desktop.wm.preferences auto-raise false
gsettings set org.gnome.mutter center-new-windows true

echo "[GNOME] Applying keyboard shortcuts..."

if [[ -f "$CONFIG_DIR/config/gnome/wm-keybindings.dconf" ]]; then
    dconf load /org/gnome/desktop/wm/keybindings/ \
        < "$CONFIG_DIR/config/gnome/wm-keybindings.dconf"
fi

if [[ -f "$CONFIG_DIR/config/gnome/shell-keybindings.dconf" ]]; then
    dconf load /org/gnome/shell/keybindings/ \
        < "$CONFIG_DIR/config/gnome/shell-keybindings.dconf"
fi

if [[ -f "$CONFIG_DIR/config/gnome/media-keybindings.dconf" ]]; then
    dconf load /org/gnome/settings-daemon/plugins/media-keys/ \
        < "$CONFIG_DIR/config/gnome/media-keybindings.dconf"
fi

echo "[GNOME] Done."
