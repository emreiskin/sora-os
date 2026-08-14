/* Sora Widgets - Material Design 3 masaüstü widget'ları */
import St from 'gi://St';
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const MARGIN = 16;
const SPACING = 12;
const CARD_WIDTH = 280;
const RADIUS = 24;
const TEXT = '#eaeaff';
const SUB = '#a0a0c0';
const ACCENT = '#8b8bf8';
const BAR_BG = 'rgba(255, 255, 255, 0.12)';
const CARD_BG = 'rgba(18, 18, 34, 0.55)';

const DAYS = ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'];
const MONTHS = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

function cardStyle() {
    return `background-color: ${CARD_BG}; border-radius: ${RADIUS}px; border: 1px solid rgba(255,255,255,0.10); padding: 18px;`;
}

function makeClockCard() {
    const actor = new St.BoxLayout({
        vertical: true,
        spacing: 4,
        style: cardStyle(),
        width: CARD_WIDTH,
    });
    const time = new St.Label({
        style: `font-size: 46px; font-weight: 300; color: ${TEXT};`,
    });
    const date = new St.Label({
        style: `font-size: 14px; font-weight: 500; color: ${SUB};`,
    });
    actor.add_child(time);
    actor.add_child(date);

    function update() {
        const now = new Date();
        const h = String(now.getHours()).padStart(2, '0');
        const m = String(now.getMinutes()).padStart(2, '0');
        time.text = `${h}:${m}`;
        date.text = `${DAYS[now.getDay()]}, ${now.getDate()} ${MONTHS[now.getMonth()]}`;
    }
    update();
    const timer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
        update();
        return GLib.SOURCE_CONTINUE;
    });
    return {actor, timer};
}

const cpuState = {prevIdle: 0, prevTotal: 0};

function readCpu() {
    try {
        const [ok, out] = GLib.spawn_command_line_sync('cat /proc/stat');
        if (!ok)
            return null;
        const parts = new TextDecoder().decode(out).split('\n')[0].trim().split(/\s+/).slice(1).map(Number);
        const idle = parts[3] + (parts[4] || 0);
        const total = parts.reduce((a, b) => a + b, 0);
        let usage = 0;
        if (cpuState.prevTotal > 0) {
            const dIdle = idle - cpuState.prevIdle;
            const dTotal = total - cpuState.prevTotal;
            if (dTotal > 0)
                usage = Math.max(0, Math.min(100, 100 * (1 - dIdle / dTotal)));
        }
        cpuState.prevIdle = idle;
        cpuState.prevTotal = total;
        return usage;
    } catch (e) {
        return null;
    }
}

function readRam() {
    try {
        const [ok, out] = GLib.spawn_command_line_sync('cat /proc/meminfo');
        if (!ok)
            return null;
        const text = new TextDecoder().decode(out);
        const get = (k) => {
            const m = text.match(new RegExp(`^${k}:\\s+(\\d+)`));
            return m ? Number(m[1]) : null;
        };
        const total = get('MemTotal');
        const avail = get('MemAvailable');
        if (total === null || avail === null)
            return null;
        return {used: (total - avail) / 1024 / 1024, total: total / 1024 / 1024};
    } catch (e) {
        return null;
    }
}

function readDisk() {
    try {
        const file = Gio.File.new_for_path('/');
        const info = file.query_filesystem_info('filesystem::size,filesystem::free', null);
        const size = info.get_attribute_uint64(Gio.FILE_ATTRIBUTE_FILESYSTEM_SIZE);
        const free = info.get_attribute_uint64(Gio.FILE_ATTRIBUTE_FILESYSTEM_FREE);
        const used = size - free;
        return {used: used / 1e9, total: size / 1e9};
    } catch (e) {
        return null;
    }
}

function readUptime() {
    try {
        const [ok, out] = GLib.spawn_command_line_sync('cat /proc/uptime');
        if (!ok)
            return null;
        const secs = Number(new TextDecoder().decode(out).split(' ')[0]);
        const h = Math.floor(secs / 3600);
        const m = Math.floor((secs % 3600) / 60);
        return h > 0 ? `${h} sa ${m} dk` : `${m} dk`;
    } catch (e) {
        return null;
    }
}

function makeBar(barWidth) {
    const fill = new St.Widget({
        width: 0,
        height: 6,
        reactive: false,
        style: `background-color: ${ACCENT}; border-radius: 3px;`,
    });
    const bar = new St.Widget({
        width: barWidth,
        height: 6,
        reactive: false,
        style: `background-color: ${BAR_BG}; border-radius: 3px;`,
    });
    bar.add_child(fill);
    return {
        bar,
        setRatio: (r) => fill.set_width(Math.max(0, Math.min(barWidth, Math.round(barWidth * r)))),
    };
}

function makeRow(labelText, barWidth) {
    const {bar, setRatio} = makeBar(barWidth);
    const label = new St.Label({
        text: labelText,
        style: `color: ${TEXT}; font-size: 13px; text-align: left;`,
        x_expand: true,
    });
    const value = new St.Label({text: '', style: `color: ${SUB}; font-size: 13px;`});
    const row = new St.BoxLayout({spacing: 10});
    row.add_child(label);
    row.add_child(bar);
    row.add_child(value);
    return {
        row,
        setRatio,
        setValue: (t) => { value.text = t; },
    };
}

function makeSystemCard() {
    const actor = new St.BoxLayout({
        vertical: true,
        spacing: 8,
        style: cardStyle(),
        width: CARD_WIDTH,
    });
    const title = new St.Label({
        text: 'Sistem',
        style: `font-size: 14px; font-weight: 700; color: ${TEXT}; text-align: left;`,
    });
    actor.add_child(title);

    const cpuRow = makeRow('CPU', 120);
    const ramRow = makeRow('RAM', 120);
    const diskRow = makeRow('Disk', 120);
    actor.add_child(cpuRow.row);
    actor.add_child(ramRow.row);
    actor.add_child(diskRow.row);

    const uptime = new St.Label({text: '', style: `font-size: 12px; color: ${SUB}; text-align: left;`});
    actor.add_child(uptime);

    function update() {
        const cpu = readCpu();
        if (cpu !== null) {
            cpuRow.setRatio(cpu / 100);
            cpuRow.setValue(`${Math.round(cpu)}%`);
        }
        const ram = readRam();
        if (ram !== null) {
            ramRow.setRatio(ram.used / ram.total);
            ramRow.setValue(`${ram.used.toFixed(1)}/${ram.total.toFixed(1)} GB`);
        }
        const disk = readDisk();
        if (disk !== null) {
            diskRow.setRatio(disk.used / disk.total);
            diskRow.setValue(`${disk.used.toFixed(1)}/${disk.total.toFixed(1)} GB`);
        }
        const up = readUptime();
        if (up !== null)
            uptime.text = `Çalışma süresi: ${up}`;
    }
    update();
    const timer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 2, () => {
        update();
        return GLib.SOURCE_CONTINUE;
    });
    return {actor, timer};
}

export default class SoraWidgetsExtension extends Extension {
    enable() {
        try {
            this._timers = [];
            this._container = new St.BoxLayout({
                vertical: true,
                spacing: SPACING,
                reactive: false,
                can_focus: false,
                track_hover: false,
            });
            const clock = makeClockCard();
            const system = makeSystemCard();
            this._timers.push(clock.timer, system.timer);
            this._container.add_child(clock.actor);
            this._container.add_child(system.actor);
            global.stage.add_child(this._container);
            this._reposition();
            this._resizeTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 150, () => {
                this._reposition();
                return GLib.SOURCE_REMOVE;
            });
            this._monitorsChanged = Main.layoutManager.connect('monitors-changed', () => this._reposition());
        } catch (e) {
            log(`Sora Widgets hatası: ${e}`);
        }
    }

    _reposition() {
        try {
            const mon = Main.layoutManager.primaryMonitor;
            if (!mon || !this._container)
                return;
            const [, , w, h] = this._container.get_preferred_size();
            this._container.set_position(mon.x + mon.width - w - MARGIN, mon.y + mon.height - h - MARGIN);
        } catch (e) {
            /* yoksay */
        }
    }

    disable() {
        try {
            if (this._monitorsChanged)
                Main.layoutManager.disconnect(this._monitorsChanged);
            if (this._resizeTimer)
                GLib.source_remove(this._resizeTimer);
            for (const t of this._timers)
                GLib.source_remove(t);
            if (this._container)
                this._container.destroy();
            this._container = null;
        } catch (e) {
            /* yoksay */
        }
    }
}
