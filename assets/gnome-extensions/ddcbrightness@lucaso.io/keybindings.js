import Meta from 'gi://Meta';
import Shell from 'gi://Shell';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
export class KeybindingManager {
    _settings;
    _actions;
    _bindings = new Map();
    _changedIds = [];
    constructor(settings, actions) {
        this._settings = settings;
        this._actions = actions;
    }
    enable() {
        for (const [name, callback] of Object.entries(this._actions)) {
            this._bind(name, callback);
        }
        for (const name of Object.keys(this._actions)) {
            this._changedIds.push(this._settings.connect(`changed::${name}`, () => {
                this._refresh(name);
            }));
        }
    }
    disable() {
        this._changedIds.forEach((id) => this._settings.disconnect(id));
        this._changedIds = [];
        this._bindings.forEach((_, key) => {
            Main.wm.removeKeybinding(key);
        });
        this._bindings.clear();
    }
    _bind(settingName, callback) {
        const keyBindingSettings = this._settings.get_strv(settingName);
        if (keyBindingSettings.length === 0 || keyBindingSettings[0] === '') {
            return;
        }
        const action = Main.wm.addKeybinding(settingName, this._settings, Meta.KeyBindingFlags.NONE, Shell.ActionMode.NORMAL, callback);
        this._bindings.set(settingName, action);
    }
    _refresh(settingName) {
        if (this._bindings.has(settingName)) {
            Main.wm.removeKeybinding(settingName);
            this._bindings.delete(settingName);
        }
        const action = this._actions[settingName];
        if (action)
            this._bind(settingName, action);
    }
}
