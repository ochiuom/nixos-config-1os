import St from 'gi://St';
import GLib from 'gi://GLib';
import Clutter from 'gi://Clutter';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const QUOTE_FILE = `${GLib.get_home_dir()}/.cache/desktop-quote/quote.txt`;
const REFRESH_INTERVAL = 3600; // seconds

let _label = null;
let _timeout = null;

function loadQuote() {
    try {
        let [ok, contents] = GLib.file_get_contents(QUOTE_FILE);
        if (ok) {
            let text = new TextDecoder().decode(contents).trim();
            _label.set_text(text);
        }
    } catch (e) {
        _label.set_text('The obstacle is the way.\n— Marcus Aurelius');
    }
    return GLib.SOURCE_CONTINUE;
}

export default class DesktopQuoteExtension {
    enable() {
        _label = new St.Label({
            style: `
                font-family: "JetBrains Mono", monospace;
                font-size: 13px;
                font-style: italic;
                color: rgba(255, 255, 255, 0.80);
                background-color: rgba(30, 30, 30, 0.45);
                border-radius: 12px;
                padding: 16px 20px;
            `,
            x_align: Clutter.ActorAlign.END,
            y_align: Clutter.ActorAlign.START,
        });

        _label.set_position(
            global.screen_width - 380,   // 40px from right edge
            80                            // 80px from top
        );

        // render behind all windows, on the desktop layer
        global.window_group.get_parent().insert_child_below(_label, global.window_group);

        loadQuote();
        _timeout = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, REFRESH_INTERVAL, loadQuote);
    }

    disable() {
        if (_timeout) {
            GLib.source_remove(_timeout);
            _timeout = null;
        }
        if (_label) {
            _label.destroy();
            _label = null;
        }
    }
}
