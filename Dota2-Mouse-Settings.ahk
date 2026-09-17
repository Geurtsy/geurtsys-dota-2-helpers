#Requires AutoHotkey v2.0
#SingleInstance Force

if A_Args.Length && A_Args[1] = "--validate"
    ExitApp()

settingsPath := A_AppData "\GeurtsyDota2Helpers\settings.ini"
savedMultiplier := 2.0
try {
    value := IniRead(settingsPath, "Mouse", "Multiplier", "2.0")
    if IsNumber(value) && value >= 1 && value <= 4
        savedMultiplier := Number(value)
}

settingsWindow := Gui(, "Geurtsy's Dota 2 Helpers - Mouse settings")
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
saveButton := settingsWindow.AddButton("w130 Default", "Save settings")
resetButton := settingsWindow.AddButton("x+12 w130", "Reset to 2x")
statusLabel := settingsWindow.AddText("xm w430 h40", "Saved settings apply on your next middle-mouse press.")
multiplierSlider.OnEvent("Change", UpdateLabel)
saveButton.OnEvent("Click", SaveSettings)
resetButton.OnEvent("Click", ResetSelection)
settingsWindow.OnEvent("Close", (*) => ExitApp())
settingsWindow.OnEvent("Escape", (*) => ExitApp())

; Build and exercise controls without opening a window or saving preferences.
if A_Args.Length && A_Args[1] = "--self-test" {
    multiplierSlider.Value := 35
    UpdateLabel()
    if multiplierLabel.Text != "3.5x normal speed"
        throw Error("Multiplier label test failed")
    settingsPath := A_Temp "\dota-mouse-settings-test-" A_TickCount ".ini"
    try {
        SaveSettings()
        if IniRead(settingsPath, "Mouse", "Multiplier") != "3.5"
            throw Error("Settings persistence test failed")
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
    global settingsPath, multiplierSlider, statusLabel
    try {
        DirCreate(A_AppData "\GeurtsyDota2Helpers")
        value := Format("{:.1f}", multiplierSlider.Value / 10)
        IniWrite(value, settingsPath, "Mouse", "Multiplier")
        statusLabel.Text := "Saved " value "x. Applies on your next middle-mouse press in Dota."
    } catch as err {
        MsgBox("Could not save settings: " err.Message, "Mouse settings", "Icon!")
    }
}
