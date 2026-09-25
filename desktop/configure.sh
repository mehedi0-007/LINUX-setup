#!/usr/bin/env bash

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_HOME="$HOME"

echo "[Desktop] Installing fonts..."

FONT_DIR="$USER_HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if [[ -f "$CONFIG_DIR/assets/fonts/SF-Pro.ttf" ]]; then
    cp "$CONFIG_DIR/assets/fonts/SF-Pro.ttf" "$FONT_DIR/SF-Pro.ttf"
fi

fc-cache -f "$FONT_DIR"

echo "[Desktop] Installing themes..."

THEME_DIR="$USER_HOME/.themes"
ICON_DIR="$USER_HOME/.icons"

mkdir -p "$THEME_DIR" "$ICON_DIR"

if [[ -d "$CONFIG_DIR/assets/themes/WhiteSur-Dark" ]]; then
    rm -rf "$THEME_DIR/WhiteSur-Dark"
    cp -a "$CONFIG_DIR/assets/themes/WhiteSur-Dark" \
        "$THEME_DIR/"
fi

for icon_theme in WhiteSur WhiteSur-dark WhiteSur-light Bibata-Modern-Ice; do
    if [[ -d "$CONFIG_DIR/assets/icons/$icon_theme" ]]; then
        rm -rf "$ICON_DIR/$icon_theme"
        cp -a "$CONFIG_DIR/assets/icons/$icon_theme" \
            "$ICON_DIR/"
    fi
done

echo "[Desktop] Installing wallpaper..."

WALLPAPER_DIR="$USER_HOME/.local/share/backgrounds"
mkdir -p "$WALLPAPER_DIR"

WALLPAPER="$WALLPAPER_DIR/linux-machine-wallpaper.jpg"

if [[ -f "$CONFIG_DIR/assets/wallpaper/wallpaper.jpg" ]]; then
    cp "$CONFIG_DIR/assets/wallpaper/wallpaper.jpg" "$WALLPAPER"
fi

echo "[Desktop] Applying GNOME appearance..."

gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface font-name 'SF Pro weight=509 11'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo "[Desktop] Applying wallpaper..."

if [[ -f "$WALLPAPER" ]]; then
    gsettings set org.gnome.desktop.background picture-uri \
        "file://$WALLPAPER"

    gsettings set org.gnome.desktop.background picture-uri-dark \
        "file://$WALLPAPER"
fi

echo "[Desktop] Applying Dash-to-Dock configuration..."

if [[ -f "$CONFIG_DIR/config/dash-to-dock.dconf" ]]; then
    dconf load /org/gnome/shell/extensions/dash-to-dock/ \
        < "$CONFIG_DIR/config/dash-to-dock.dconf"
fi

echo "[Desktop] Applying GNOME configuration..."

if [[ -f "$CONFIG_DIR/config/gnome-settings.dconf" ]]; then
    echo "GNOME configuration captured from reference machine."
    echo "Hardware-specific settings will not be blindly restored."
fi

echo "[Desktop] Installing GNOME extensions..."

"$CONFIG_DIR/desktop/extensions.sh"

echo "[Desktop] Applying GNOME settings..."

"$CONFIG_DIR/desktop/gnome-settings.sh"

echo "[Desktop] Installing GNOME extensions..."

"$CONFIG_DIR/desktop/extensions.sh"

echo "[Desktop] Done."
