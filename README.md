# Geurtsy's Dota 2 Helpers

Small AutoHotkey v2 helpers for Dota 2 on Windows.

## Only active with Dota 2

The watcher starts the helpers only after `dota2.exe` starts. Each helper verifies that its target is Dota 2, accepts hotkeys only while Dota is focused, and exits automatically when the game closes. Closing Dota releases voice chat, removes its indicator, and restores any boosted mouse speed. Alt-Tab also turns off voice and restores mouse speed.

When Dota is not running, only the idle watcher remains. It registers no keyboard or mouse hotkeys and changes no input settings; it waits for the next game launch. Starting a helper directly while Dota is closed simply exits.

## Toggle voice chat

The defaults below are configurable in the settings window. Set **Target key** to match your Dota push-to-talk binding and **Toggle key** to the key you want to press to turn voice on/off. Click a key box and press a single keyboard key without modifiers, then click **Save settings**. The keys must differ. Changes apply within about half a second without restarting Dota and turn any active voice hold off first. The indicator uses your selected toggle key. Your selected toggle is reserved throughout Dota, including text chat. The window does not edit Dota's own bindings.


Press **G** once to talk, then press **G** again to stop. The helper holds your existing **F10** push-to-talk binding while voice is on.

- A small green **Voice chat ON | G to turn off** indicator stays near the top center of the game while voice is on.
- Voice starts off each game and switches off when you Alt-Tab.
- The voice helper exits when Dota 2 closes.
- A lightweight watcher stays running and starts the helper the next time Dota 2 launches, including launches through Steam.
- G only controls voice while Dota 2 is focused. Holding G does not toggle repeatedly.

## Hold middle mouse for a speed boost

Hold the **middle mouse button** while Dota 2 is focused to boost Windows pointer speed toward **2x** its normal level. Release it to restore the speed captured when you pressed the button. Middle-click still reaches Dota normally, including camera dragging.

- Switching away from Dota, closing the game, or normally exiting the helper restores your original speed. After Alt-Tab, release and press middle mouse again to re-enable the boost.
- This changes Windows pointer speed, **not hardware CPI/DPI**. Windows exposes a system-wide setting; the helper applies it only while Dota is focused and restores it within the next timer check when focus changes.
- Windows speed steps are nonlinear: the helper selects the closest available nominal 2x gain, capped at Windows' maximum. For example, default speed 10 becomes 14, rather than 20. At higher baseline settings, 2x may be unavailable.
- **Enhance pointer precision** adds acceleration, so an exact 2x result is not guaranteed. The helper leaves this preference unchanged.
- Games using raw mouse input may ignore Windows pointer speed. Test its effect on your Dota setup.
- The change is not saved to your Windows profile. A forced process termination can bypass cleanup; if that happens while boosted, restore pointer speed in Windows Settings or sign out and back in.

## Setup
 
### Adjust mouse speed

Double-click **`Dota2-Mouse-Settings.ahk`**, or right-click the watcher's or mouse helper's AutoHotkey tray icon and choose **Settings...**.

Move the slider from **1x to 4x** and click **Save settings**. **Reset to 2x** selects the default; click Save to keep it. Saved changes apply on the next middle-mouse press without restarting Dota. Windows still rounds to its available speed steps and maximum.

Preferences are saved per Windows user in `%APPDATA%\GeurtsyDota2Helpers\settings.ini`. Missing or invalid settings fall back to 2x. This settings window can be opened without Dota; it only edits preferences and never enables mouse or keyboard helpers outside the game.

### Install

1. Install [AutoHotkey v2](https://www.autohotkey.com/) on Windows.
2. Download this repository using **Code > Download ZIP**, then extract it into a permanent folder.
3. Keep all downloaded files together, including `Setup.bat`, `Setup.ps1` and all `.ahk` scripts.
4. In Dota 2, set your push-to-talk key to **F10**.
5. Double-click **`Setup.bat`**. It finds AutoHotkey v2, checks the scripts, creates your Windows startup shortcut, and starts the watcher immediately. No administrator access is needed.
6. Press **G** to toggle voice on or off. Hold **middle mouse** for the temporary pointer-speed boost.

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

Right-click the watcher's AutoHotkey tray icon and select **Exit**. If Dota 2 is running, also exit the voice and mouse helpers' tray icons to immediately release F10, remove the indicator, and restore pointer speed.

To prevent automatic startup, press **Win+R**, enter `shell:startup`, and remove **Dota 2 Voice Toggle.lnk**. You can then delete the extracted folder when both scripts have stopped.

## Files

| File | Purpose |
| --- | --- |
| `Setup.bat` | Double-click installer that enables automatic startup and starts the watcher. |
| `Setup.ps1` | Detects AutoHotkey v2, validates the scripts, and creates the startup shortcut. |
| `Dota2-Voice-Watcher.ahk` | Watches for `dota2.exe` and launches the voice helper for each game session. |
| `Dota2-Voice-Toggle.ahk` | Implements the G toggle, F10 hold, visible indicator, and cleanup. |
| `Dota2-Mouse-Boost.ahk` | Temporarily boosts Windows pointer speed while middle mouse is held in Dota. |
| `Dota2-Mouse-Settings.ahk` | Settings window for the saved mouse multiplier and voice target/toggle keys. |

## Validation

All AutoHotkey scripts include a `--validate` argument that loads and parses the script, then exits without enabling the helper. Run them with AutoHotkey v2 and this argument for syntax checking.

Syntax validation is not an in-game microphone test. Check voice transmission and indicator visibility in your own Dota 2 setup.

