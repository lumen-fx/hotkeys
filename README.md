# hotkeys

Native shell showcase: OS-global hotkeys, a system tray icon with a
context menu, and desktop notifications with an action button - with an
in-app event log so everything is observable even where a shell surface
is unavailable.

This is the Rhai template. Builtins are bare globals, a handler bound to
a node is a function pointer (`Fn("clear_log")`), and `create(tag)` is
the spelling of the create verb because `spawn` is a Rhai keyword.

Concepts demonstrated:

- **`register_hotkey(name, accel)` / `unregister_hotkey(name)`** -
  OS-level accelerators (Electron-style `CommandOrControl+Shift+L`
  strings); `on_hotkey(name)` fires even when the app is unfocused, and
  `on_hotkey_release(name)` fires on the way back up. The "Hotkeys
  armed" toggle registers and unregisters live.
- **`tray_icon_menu(id, icon_path, tooltip, menu, template)`** - system
  tray entry with a right-click menu whose picks reach `on_menu(id)`.
  Ship an icon at `icons/tray.png` and uncomment the call in `src/main.rhai`
  to light it up.
- **`notify_ex(id, title, body, options, actions)`** - a notification
  carrying a button; a press reaches
  `on_notification_action(id, action_id)`.
- **Element handles** - `get_by_id("clear-log").on("click", Fn("clear_log"))`
  binds one button to one function, from `on_ready` where the tree exists.
- **Bounded log feed** - the same array-signal + `<for>` pattern the
  dashboard template uses.

Run it:

```sh
lumenc run .
```
