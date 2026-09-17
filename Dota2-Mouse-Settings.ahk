#Requires AutoHotkey v2.0
#SingleInstance Force

if A_Args.Length && A_Args[1] = "--validate"
    ExitApp()

settingsPath := A_AppData "\GeurtsyDota2Helpers\settings.ini"
savedMultiplier := 2.0
savedTarget := "F10"
savedToggle := "G"
try {
    savedTarget := IniRead(settingsPath, "Voice", "TargetKey", "F10")
    savedToggle := IniRead(settingsPath, "Voice", "ToggleKey", "G")
    if !ValidVoiceKey(savedTarget) || !ValidVoiceKey(savedToggle) || GetKeyVK(savedTarget) = GetKeyVK(savedToggle) {
        savedTarget := "F10"
        savedToggle := "G"
    }
}
try {
    value := IniRead(settingsPath, "Mouse", "Multiplier", "2.0")
    if IsNumber(value) && value >= 1 && value <= 4
        savedMultiplier := Number(value)
}

settingsWindow := Gui(, "Geurtsy's Dota 2 Helpers - Settings")
settingsWindow.SetFont("s10", "Segoe UI")
settingsWindow.MarginX := 24
settingsWindow.MarginY := 20
settingsWindow.AddText("w430", "Middle-mouse speed boost")
settingsWindow.AddText("w430", "Choose how much faster the pointer moves while you hold the middle mouse button in Dota 2.")
multiplierLabel := settingsWindow.AddText("w430 Center", Format("{:.1f}x normal speed", savedMultiplier))
multiplierSlider := settingsWindow.AddSlider("w430 Range10-40 TickInterval5 ToolTip", Round(savedMultiplier * 10))
settingsWindow.AddText("w430", "1x = normal speed                                       4x = maximum request")
settingsWindow.AddText("w430", "Windows uses fixed speed steps and a maximum limit. Actual speed may be lower than requested, especially with pointer acceleration enabled.")
settingsWindow.AddText("w430", "Your normal speed is restored on release or when you leave Dota. These settings do not change hardware CPI.")
settingsWindow.AddText("xm w430", "Voice chat keys")
settingsWindow.AddText("w430", "Click each box and press a single keyboard key (no modifiers).")
settingsWindow.AddText("w430", "Target key - your push-to-talk binding inside Dota 2")
targetControl := settingsWindow.AddHotkey("w210", StrLower(savedTarget))
settingsWindow.AddText("w430", "Toggle key - press once to talk, again to stop")
toggleControl := settingsWindow.AddHotkey("w210", StrLower(savedToggle))
settingsWindow.AddText("w430", "Set Dota's push-to-talk binding to the same target key. This window does not change Dota's own settings.")
saveButton := settingsWindow.AddButton("w130 Default", "Save settings")
resetButton := settingsWindow.AddButton("x+12 w130", "Reset to 2x")
statusLabel := settingsWindow.AddText("xm w430 h40", "Voice changes apply automatically; mouse changes apply on the next press.")
multiplierSlider.OnEvent("Change", UpdateLabel)
saveButton.OnEvent("Click", SaveSettings)
resetButton.OnEvent("Click", ResetSelection)
targetControl.OnEvent("Change", (*) => statusLabel.Text := "Unsaved changes. Click Save settings to apply.")
toggleControl.OnEvent("Change", (*) => statusLabel.Text := "Unsaved changes. Click Save settings to apply.")
settingsWindow.OnEvent("Close", (*) => ExitApp())
settingsWindow.OnEvent("Escape", (*) => ExitApp())

; Build and exercise controls without opening a window or saving preferences.
if A_Args.Length && A_Args[1] = "--self-test" {
    multiplierSlider.Value := 35
    UpdateLabel()
    if multiplierLabel.Text != "3.5x normal speed"
        throw Error("Multiplier label test failed")
    settingsPath := A_Temp "\dota-mouse-settings-test-" A_TickCount ".ini"
    targetControl.Value := "F9"
    toggleControl.Value := "v"
    try {
        SaveSettings()
        if IniRead(settingsPath, "Mouse", "Multiplier") != "3.5"
            throw Error("Settings persistence test failed")
        if IniRead(settingsPath, "Voice", "TargetKey") != "F9" || StrLower(IniRead(settingsPath, "Voice", "ToggleKey")) != "v"
            throw Error("Voice persistence test failed")
        if ValidVoiceKey("^G") || ValidVoiceKey("MButton") || ValidVoiceKey("")
            throw Error("Invalid voice key accepted")
    } finally {
        if FileExist(settingsPath)
            FileDelete(settingsPath)
    }
    ResetSelection()
    if multiplierSlider.Value != 20 || multiplierLabel.Text != "2.0x normal speed"
        throw Error("Reset test failed")
    FileAppend("PASS: settings GUI creation, slider label, persistence and reset.`n", "*")
    ExitApp()
}
settingsWindow.Show("AutoSize")

UpdateLabel(*) {
    global multiplierLabel, multiplierSlider, statusLabel
    multiplierLabel.Text := Format("{:.1f}x normal speed", multiplierSlider.Value / 10)
    statusLabel.Text := "Unsaved changes. Click Save settings to apply."
}

ResetSelection(*) {
    global multiplierSlider
    multiplierSlider.Value := 20
    UpdateLabel()
}

SaveSettings(*) {
    global settingsPath, multiplierSlider, statusLabel, targetControl, toggleControl
    target := targetControl.Value
    toggle := toggleControl.Value
    if !ValidVoiceKey(target) || !ValidVoiceKey(toggle) {
        MsgBox("Choose a single keyboard key in each voice box, without Ctrl, Alt, Shift or Win.", "Voice settings", "Icon!")
        return
    }
    if GetKeyVK(target) = GetKeyVK(toggle) {
        MsgBox("The target and toggle keys must be different.", "Voice settings", "Icon!")
        return
    }
    try {
        DirCreate(A_AppData "\GeurtsyDota2Helpers")
        multiplierValue := Format("{:.1f}", multiplierSlider.Value / 10)
        IniWrite(multiplierValue, settingsPath, "Mouse", "Multiplier")
        IniWrite("TargetKey=" target "`nToggleKey=" toggle, settingsPath, "Voice")
        statusLabel.Text := "Saved. Voice keys update automatically; " multiplierValue "x applies on the next mouse press."
    } catch as err {
        MsgBox("Could not save settings: " err.Message, "Mouse settings", "Icon!")
    }
}

ValidVoiceKey(key) {
    return RegExMatch(key, "i)^[a-z0-9]+$") && GetKeyVK(key)
        && !RegExMatch(key, "i)^(.*Button|Wheel.*|.*Shift|.*Control|.*Ctrl|.*Alt|.*Win)$")
}

