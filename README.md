# Geurtsy's Dota 2 Helpers

Small AutoHotkey v2 helpers for Dota 2 on Windows.

## Toggle voice chat

Press **G** once to talk, then press **G** again to stop. The helper holds your existing **F10** push-to-talk binding while voice is on.

- A small green **Voice chat ON | G to turn off** indicator stays near the top center of the game while voice is on.
- Voice starts off each game and switches off when you Alt-Tab.
- The voice helper exits when Dota 2 closes.
- A lightweight watcher stays running and starts the helper the next time Dota 2 launches, including launches through Steam.
- G only controls voice while Dota 2 is focused. Holding G does not toggle repeatedly.

## Setup

1. Install [AutoHotkey v2](https://www.autohotkey.com/) on Windows.
2. Download this repository using **Code > Download ZIP**, then extract it into a permanent folder.
3. Keep `Dota2-Voice-Watcher.ahk` and `Dota2-Voice-Toggle.ahk` together.
4. In Dota 2, set your push-to-talk key to **F10**.
5. Double-click `Dota2-Voice-Watcher.ahk`, then launch Dota 2 as usual. If Dota 2 is already running, the watcher will detect it.
6. Press **G** to toggle voice on or off.

### Start automatically with Windows

1. Create a shortcut to `Dota2-Voice-Watcher.ahk`.
2. Press **Win+R**, type `shell:startup`, and press Enter.
3. Move the shortcut into that Startup folder.

The watcher will now start at sign-in. Keep the original scripts in their permanent folder so the shortcut continues to work.

## Notes

- **G is reserved for the toggle throughout Dota 2, including its text-chat box.** It will not type the letter G there while the helper is active.
- If exclusive fullscreen hides the indicator, use Dota 2's borderless window display mode.
- The indicator shows the helper's toggle state; it does not verify microphone audio or Dota 2's connection.
- After switching back from another app, press G again if you want voice on.
- Keep Dota 2 and the helper at the same privilege level; normally, run both without administrator privileges.

## Stop or uninstall

Right-click the watcher's AutoHotkey tray icon and select **Exit**. If Dota 2 is running, also exit the voice helper's tray icon to immediately release F10 and remove the indicator.

To prevent automatic startup, remove the shortcut you added to `shell:startup`. You can then delete the extracted folder when both scripts have stopped.

## Files

| File | Purpose |
| --- | --- |
| `Dota2-Voice-Watcher.ahk` | Watches for `dota2.exe` and launches the voice helper for each game session. |
| `Dota2-Voice-Toggle.ahk` | Implements the G toggle, F10 hold, visible indicator, and cleanup. |

## Validation

Both scripts include a `--validate` argument that loads and parses the script, then exits without enabling the helper. Run them with AutoHotkey v2 and this argument for syntax checking.

Syntax validation is not an in-game microphone test. Check voice transmission and indicator visibility in your own Dota 2 setup.
