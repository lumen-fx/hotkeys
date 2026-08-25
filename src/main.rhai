// Global hotkeys, a tray icon with a context menu, and notifications
// with an action button. Everything lands in the in-app log, so the
// demo stays observable even where a shell surface is missing.

fn log_event(kind, text) {
    let n = signal("log_n", 0);
    n.set(n.get() + 1);
    let log = signal_array("log");
    log.push(#{ id: "" + n.get(), kind: kind, text: text });
    let rows = log.all();
    if rows.len() > 20 {
        rows.remove(0);
        log.set(rows);
    }
    signal("log_label", "").set("Event log (" + rows.len() + ")");
}

fn arm() {
    register_hotkey("log-line", "CommandOrControl+Shift+L");
    register_hotkey("notify",   "CommandOrControl+Shift+K");
}

fn disarm() {
    unregister_hotkey("log-line");
    unregister_hotkey("notify");
}

// on_ready runs on the first tick, once the tree is mounted, so the buttons
// are there to look up and bind. Fn("name") hands the binding a pointer to
// a function declared below.
fn on_ready() {
    get_by_id("notify-now").on("click", Fn("send_notification"));
    get_by_id("clear-log").on("click", Fn("clear_log"));
    arm();
    // A tray entry needs an icon asset. Drop one at icons/tray.png and
    // uncomment the call to light it up; the last argument is the macOS
    // template flag, true for a monochrome icon the menu bar recolours.
    // Picks from the menu reach on_menu below.
    // tray_icon_menu("main", "icons/tray.png", "Lumen hotkeys demo",
    //                "ping:Say hello|-|clear:Clear the log", false);
    log_event("ready", "hotkeys armed - try Ctrl/Cmd+Shift+L from another window");
}

fn on_hotkey(name) {
    if name == "log-line" {
        log_event("hotkey", "Ctrl/Cmd+Shift+L pressed");
    }
    if name == "notify" {
        log_event("hotkey", "Ctrl/Cmd+Shift+K pressed - sending notification");
        notify_ex("hotkey-fired", "Lumen hotkeys", "Global hotkey fired.",
                  "urgency:normal", "log:Log it");
    }
}

// The release half of the same chord. Holding a hotkey down and letting
// it go is how push-to-talk is built.
fn on_hotkey_release(name) {
    log_event("hotkey", name + " released");
}

fn on_notification_action(id, action_id) {
    log_event("notify", "notification button '" + action_id + "' pressed");
}

fn on_tray(id) {
    log_event("tray", "tray icon clicked (" + id + ")");
}

// Tray menu picks arrive as menu clicks, the same handler a menu bar uses.
fn on_menu(id) {
    if id == "ping"  { log_event("tray", "hello from the tray menu"); }
    if id == "clear" { reset_log(); }
}

fn on_toggle(id, checked) {
    if id == "armed" {
        if checked { arm();    log_event("state", "hotkeys armed"); }
        else       { disarm(); log_event("state", "hotkeys disarmed"); }
    }
}

// A bound handler is called with the event itself: `ev.target()`,
// `ev.modifiers()`, `ev.prevent_default()`.
fn send_notification(ev) {
    notify("Lumen", "Test notification from the hotkeys template.");
    log_event("notify", "test notification sent");
}

fn clear_log(ev) {
    reset_log();
}

fn reset_log() {
    signal_array("log").set([]);
    signal("log_label", "").set("Event log");
}
