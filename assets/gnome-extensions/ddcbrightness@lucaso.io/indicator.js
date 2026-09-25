import Clutter from 'gi://Clutter';
import St from 'gi://St';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';
import * as Slider from 'resource:///org/gnome/shell/ui/slider.js';
/**
 * The panel button and its popup menu: a brightness slider per display, a
 * "link displays" toggle, and refresh/settings actions.
 */
export class BrightnessIndicator {
    _button;
    _controller;
    _settings;
    _onRefresh;
    _onOpenPrefs;
    constructor(params) {
        this._controller = params.controller;
        this._settings = params.settings;
        this._onRefresh = params.onRefresh;
        this._onOpenPrefs = params.onOpenPrefs;
        this._button = new PanelMenu.Button(0.5, 'DDC Brightness');
        const icon = new St.Icon({
            iconName: 'display-brightness-symbolic',
            fallbackIconName: 'display-symbolic',
            styleClass: 'system-status-icon',
        });
        this._button.add_child(icon);
        this.rebuildMenu();
    }
    get button() {
        return this._button;
    }
    rebuildMenu() {
        const menu = this._button.menu;
        menu.removeAll();
        if (!this._controller.detectComplete) {
            const loadingItem = new PopupMenu.PopupMenuItem('Detecting displays...');
            loadingItem.setSensitive(false);
            menu.addMenuItem(loadingItem);
            return;
        }
        const displays = this._controller.displays;
        if (displays.length === 0) {
            const noDisplays = new PopupMenu.PopupMenuItem('No DDC displays found');
            noDisplays.setSensitive(false);
            menu.addMenuItem(noDisplays);
        }
        else {
            const linkRow = new PopupMenu.PopupSwitchMenuItem('Link displays', this._settings.get_boolean('link-displays'));
            linkRow.connect('toggled', (_item, state) => {
                this._settings.set_boolean('link-displays', state);
            });
            menu.addMenuItem(linkRow);
            menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
            for (const display of displays) {
                this._buildSliderForDisplay(menu, display);
            }
        }
        menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
        const refreshBtn = new PopupMenu.PopupMenuItem('Refresh Displays');
        refreshBtn.connect('activate', () => {
            this._onRefresh();
        });
        menu.addMenuItem(refreshBtn);
        const prefsBtn = new PopupMenu.PopupMenuItem('Settings');
        prefsBtn.connect('activate', () => {
            this._onOpenPrefs();
        });
        menu.addMenuItem(prefsBtn);
    }
    _buildSliderForDisplay(menu, display) {
        const labelRow = new PopupMenu.PopupMenuItem(display.name || `Display (bus ${display.bus})`);
        labelRow.setSensitive(false);
        menu.addMenuItem(labelRow);
        const sliderRow = new PopupMenu.PopupBaseMenuItem({ activate: false });
        sliderRow.add_style_class_name('ddc-brightness-slider');
        const slider = new Slider.Slider(display.currentValue / 100);
        const valueLabel = new St.Label({
            text: `${display.currentValue}%`,
            yAlign: Clutter.ActorAlign.CENTER,
            style: 'min-width: 40px; text-align: right;',
        });
        sliderRow.add_child(slider);
        sliderRow.add_child(valueLabel);
        menu.addMenuItem(sliderRow);
        display.slider = slider;
        display.valueLabel = valueLabel;
        slider.connect('notify::value', () => {
            if (display.updatingFromCode)
                return;
            const pct = Math.round(slider.value * 100);
            this._controller.setFromSlider(display, pct);
        });
        menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());
    }
    destroy() {
        this._button.destroy();
    }
}
