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
3. Keep all downloaded files together, including `Setup.bat`, `Setup.ps1` and both `.ahk` scripts.
4. In Dota 2, set your push-to-talk key to **F10**.
5. Double-click **`Setup.bat`**. It finds AutoHotkey v2, checks the scripts, creates your Windows startup shortcut, and starts the watcher immediately. No administrator access is needed.
6. Press **G** to toggle voice on or off.

### Automatic startup

Setup creates **Dota 2 Voice Toggle.lnk** in your user Startup folder. The watcher starts whenever you sign in and detects Dota 2 automatically. Running setup again updates the same shortcut.

Keep the extracted folder in its current location. If you move it, exit the existing watcher and voice helper from the tray, then run `Setup.bat` in the new location. Setup requires AutoHotkey v2 to be installed; it displays instructions if it cannot find it. The batch file runs the included PowerShell setup helper with a process-only execution-policy override; it does not change your saved PowerShell policy.

For manual use without automatic startup, double-click `Dota2-Voice-Watcher.ahk` instead of running setup.

## Notes

- **G is reserved for the toggle throughout Dota 2, including its text-chat box.** It will not type the letter G there while the helper is active.
- If exclusive fullscreen hides the indicator, use Dota 2's borderless window display mode.
- The indicator shows the helper's toggle state; it does not verify microphone audio or Dota 2's connection.
- After switching back from another app, press G again if you want voice on.
- Keep Dota 2 and the helper at the same privilege level; normally, run both without administrator privileges.

## Stop or uninstall

Right-click the watcher's AutoHotkey tray icon and select **Exit**. If Dota 2 is running, also exit the voice helper's tray icon to immediately release F10 and remove the indicator.

To prevent automatic startup, press **Win+R**, enter `shell:startup`, and remove **Dota 2 Voice Toggle.lnk**. You can then delete the extracted folder when both scripts have stopped.

## Files

| File | Purpose |
| --- | --- |
| `Setup.bat` | Double-click installer that enables automatic startup and starts the watcher. |
| `Setup.ps1` | Detects AutoHotkey v2, validates the scripts, and creates the startup shortcut. |
| `Dota2-Voice-Watcher.ahk` | Watches for `dota2.exe` and launches the voice helper for each game session. |
| `Dota2-Voice-Toggle.ahk` | Implements the G toggle, F10 hold, visible indicator, and cleanup. |

## Validation

Both scripts include a `--validate` argument that loads and parses the script, then exits without enabling the helper. Run them with AutoHotkey v2 and this argument for syntax checking.

Syntax validation is not an in-game microphone test. Check voice transmission and indicator visibility in your own Dota 2 setup.
