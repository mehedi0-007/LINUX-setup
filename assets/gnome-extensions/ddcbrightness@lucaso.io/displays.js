import { DEFAULT_VCP_CODE, LOG_PREFIX } from './constants.js';
import * as Ddcutil from './ddcutil.js';
export class DisplayController {
    _settings;
    _displays = [];
    _detectComplete = false;
    _disposed = false;
    onDetectComplete = null;
    constructor(settings) {
        this._settings = settings;
    }
    get displays() {
        return this._displays;
    }
    get detectComplete() {
        return this._detectComplete;
    }
    get _vcpCode() {
        return this._settings.get_string('vcp-code') || DEFAULT_VCP_CODE;
    }
    reset() {
        this._displays = [];
        this._detectComplete = false;
    }
    cleanup() {
        this._disposed = true;
    }
    detect() {
        Ddcutil.detectDisplays((parsed) => {
            if (this._disposed)
                return;
            this._displays = parsed.map((p) => ({
                bus: p.bus,
                name: p.name,
                connector: p.connector,
                monitorIndex: -1,
                currentValue: 50,
                slider: null,
                valueLabel: null,
                sentValue: 50,
                inFlight: false,
                reading: false,
                updatingFromCode: false,
            }));
            this._detectComplete = true;
            console.debug(`${LOG_PREFIX} Found ${this._displays.length} displays`);
            this._mapMonitorsToDisplays();
            this.onDetectComplete?.();
            for (const display of this._displays) {
                this.readBrightness(display);
            }
        });
    }
    _mapMonitorsToDisplays() {
        const backend = global.backend;
        const monitorManager = backend.get_monitor_manager();
        for (const display of this._displays) {
            if (display.connector) {
                const idx = monitorManager.get_monitor_for_connector(display.connector);
                if (idx >= 0) {
                    display.monitorIndex = idx;
                    console.debug(`${LOG_PREFIX} Mapped ${display.name} connector=${display.connector} -> monitor ${idx}`);
                }
            }
        }
    }
    _getFocusedMonitorIndex() {
        const focusWindow = global.display.focus_window;
        if (focusWindow) {
            return focusWindow.get_monitor();
        }
        return global.display.get_primary_monitor();
    }
    /**
     * The display to act on for global actions, honoring "link displays".
     * This should grab the display that the active window is part of for adjusting when not linked
     */
    getActiveDisplay() {
        if (this._settings.get_boolean('link-displays')) {
            return this._displays[0] ?? null;
        }
        const monitorIdx = this._getFocusedMonitorIndex();
        const display = this._displays.find((d) => d.monitorIndex === monitorIdx);
        return display ?? this._displays[0] ?? null;
    }
    // Nudge brightness by `delta` steps (the step size comes from settings).
    adjustDelta(delta) {
        const step = this._settings.get_int('step');
        const change = delta * step;
        if (this._settings.get_boolean('link-displays')) {
            for (const display of this._displays) {
                this.applyChange(display, display.currentValue + change);
            }
        }
        else {
            const display = this.getActiveDisplay();
            if (display) {
                this.applyChange(display, display.currentValue + change);
            }
        }
    }
    // Set an absolute target value (clamped) on one display and reconcile.
    applyChange(display, rawValue) {
        const newValue = Math.max(0, Math.min(100, rawValue));
        this._setTarget(display, newValue);
        this._requestSend(display);
    }
    // Handle a user-driven slider change: update this display (and linked ones)
    // to the new target, then reconcile each.
    setFromSlider(display, pct) {
        display.currentValue = pct;
        if (display.valueLabel) {
            display.valueLabel.set_text(`${pct}%`);
        }
        if (this._settings.get_boolean('link-displays')) {
            for (const other of this._displays) {
                if (other === display)
                    continue;
                this._setTarget(other, pct);
                this._requestSend(other);
            }
        }
        this._requestSend(display);
    }
    // Update a display's target value and reflect it in the slider/label.
    _setTarget(display, value) {
        display.currentValue = value;
        display.updatingFromCode = true;
        if (display.slider) {
            display.slider.value = value / 100;
        }
        if (display.valueLabel) {
            display.valueLabel.set_text(`${value}%`);
        }
        display.updatingFromCode = false;
    }
    // Reconcile a display toward its target: if nothing is in flight and the
    // target differs from what we last sent, send it. On completion this is
    // re-run so any newer target is picked up. Guarantees one write at a time.
    _requestSend(display) {
        if (this._disposed)
            return;
        if (display.inFlight)
            return;
        if (display.currentValue === display.sentValue)
            return;
        const value = display.currentValue;
        display.sentValue = value;
        display.inFlight = true;
        Ddcutil.setBrightness(display.bus, this._vcpCode, value, () => {
            display.inFlight = false;
            this._requestSend(display);
        });
    }
    // Read the current brightness for a display and reflect it in the UI.
    readBrightness(display) {
        if (display.reading)
            return;
        display.reading = true;
        Ddcutil.readBrightness(display.bus, this._vcpCode, (value) => {
            display.reading = false;
            if (this._disposed)
                return;
            if (value !== null) {
                display.sentValue = value;
                this._setTarget(display, value);
            }
        });
    }
}
