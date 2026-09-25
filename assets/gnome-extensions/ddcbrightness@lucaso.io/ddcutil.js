import Gio from 'gi://Gio';
import { LOG_PREFIX, DDCUTIL_SLEEP_MULTIPLIER } from './constants.js';
// Run a command asynchronously, capturing stdout. The callback always fires:
// with stdout on success, or an empty string on failure.
export function runCommandAsync(args, callback) {
    console.debug(`${LOG_PREFIX} Running: ${args.join(' ')}`);
    try {
        const subprocess = new Gio.Subprocess({
            argv: args,
            flags: Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE,
        });
        subprocess.init(null);
        subprocess.communicate_utf8_async(null, null, (proc, result) => {
            try {
                const [, stdout] = (proc ?? subprocess).communicate_utf8_finish(result);
                console.debug(`${LOG_PREFIX} Done: ${stdout.trim().substring(0, 80)}`);
                callback(stdout);
            }
            catch (e) {
                console.error(`${LOG_PREFIX} Command failed: ${e}`);
                callback('');
            }
        });
    }
    catch (e) {
        console.error(`${LOG_PREFIX} Failed to spawn: ${e}`);
        callback('');
    }
}
// Detect connected DDC displays and return them parsed.
export function detectDisplays(callback) {
    runCommandAsync(['ddcutil', 'detect', '--brief'], (stdout) => {
        callback(parseDisplays(stdout));
    });
}
// Parse the output of `ddcutil detect --brief` into a list of displays.
export function parseDisplays(stdout) {
    const displays = [];
    const blocks = stdout.split(/^Display\s+\d+/m);
    for (const block of blocks) {
        if (!block.trim())
            continue;
        const busMatch = block.match(/I2C bus:\s+\/dev\/i2c-(\d+)/);
        const monitorMatch = block.match(/Monitor:\s+(.+)/);
        const connectorMatch = block.match(/DRM connector:\s+card\d+-(\S+)/);
        if (busMatch) {
            const bus = busMatch[1];
            const name = monitorMatch ? monitorMatch[1].trim() : `Display (bus ${bus})`;
            const connector = connectorMatch ? connectorMatch[1] : '';
            displays.push({ bus, name, connector });
        }
    }
    return displays;
}
// Read the current brightness (0-100) for a bus, or null if unreadable.
export function readBrightness(bus, vcpCode, callback) {
    runCommandAsync(['ddcutil', 'getvcp', vcpCode, '--bus', bus, '--brief', '--sleep-multiplier', DDCUTIL_SLEEP_MULTIPLIER], (stdout) => {
        const match = stdout.match(/VCP\s+\w+\s+\w+\s+(\d+)\s+(\d+)/);
        callback(match ? parseInt(match[1]) : null);
    });
}
// Set the brightness (0-100) for a bus. `callback` fires when the write
// completes (success or failure), so callers can chain the next write.
// `--noverify` skips ddcutil's post-write read-back for speed.
export function setBrightness(bus, vcpCode, value, callback) {
    runCommandAsync(['ddcutil', 'setvcp', vcpCode, String(value), '--bus', bus, '--noverify', '--sleep-multiplier', DDCUTIL_SLEEP_MULTIPLIER], () => callback());
}
