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

savedBoostKey := "MButton"
savedCameraKey := "MButton"
savedCameraMode := "Hold"
try {
    savedBoostKey := IniRead(settingsPath, "Mouse", "BoostKey", "MButton")
    savedCameraKey := IniRead(settingsPath, "Camera", "ActivationKey", "MButton")
    savedCameraMode := IniRead(settingsPath, "Camera", "Mode", "Hold")
}
activationChoices := ["MButton", "XButton1", "XButton2", "Space", "LShift", "LControl", "LAlt", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12"]
settingsWindow := Gui(, "Geurtsy's Dota 2 Helpers - Settings")
settingsWindow.BackColor := "F5F6F8"
settingsWindow.SetFont("s18 Bold c202938", "Segoe UI")
settingsWindow.AddText("x24 y18 w496 h32", "Dota 2 Helpers")
settingsWindow.SetFont("s10 Norm c586174", "Segoe UI")
settingsWindow.AddText("x24 y54 w496 h22", "Configure your mouse boost and voice chat keys.")

; Mouse controls are enclosed separately from voice controls.
settingsWindow.SetFont("s11 Bold c202938", "Segoe UI")
settingsWindow.AddGroupBox("x24 y88 w496 h238", "Mouse speed")
settingsWindow.SetFont("s10 Norm c202938", "Segoe UI")
settingsWindow.AddText("x44 y118 w456 h36", "Hold your chosen boost key in Dota to temporarily increase pointer speed.")
settingsWindow.SetFont("s13 Bold c202938", "Segoe UI")
multiplierLabel := settingsWindow.AddText("x44 y158 w456 h26 Center", Format("{:.1f}x normal speed", savedMultiplier))
settingsWindow.SetFont("s10 Norm c202938", "Segoe UI")
multiplierSlider := settingsWindow.AddSlider("x44 y188 w456 h34 Range10-40 TickInterval5", Round(savedMultiplier * 10))
settingsWindow.AddText("x44 y225 w200 h20", "1x - normal")
settingsWindow.AddText("x300 y225 w200 h20 Right", "4x - maximum request")
settingsWindow.AddText("x44 y251 w74 h26", "Hold key")
boostKeyControl := settingsWindow.AddComboBox("x124 y250 w178", activationChoices)
boostKeyControl.Text := savedBoostKey
resetButton := settingsWindow.AddButton("x344 y250 w156 h28", "Reset mouse to 2x")
settingsWindow.SetFont("s9 Norm c586174", "Segoe UI")
settingsWindow.AddText("x44 y291 w456 h26", "Windows speed limits apply. Normal speed returns when released.")

settingsWindow.SetFont("s11 Bold c202938", "Segoe UI")
settingsWindow.AddGroupBox("x24 y342 w496 h226", "Voice chat")
settingsWindow.SetFont("s9 Norm c586174", "Segoe UI")
settingsWindow.AddText("x44 y371 w456 h20", "Click a key box and press a single key, without modifiers.")
settingsWindow.SetFont("s10 Bold c202938", "Segoe UI")
settingsWindow.AddText("x44 y407 w270 h22", "Target key")
settingsWindow.SetFont("s9 Norm c586174", "Segoe UI")
settingsWindow.AddText("x44 y433 w270 h22", "Your push-to-talk binding inside Dota")
settingsWindow.SetFont("s10 Norm c202938", "Segoe UI")
targetControl := settingsWindow.AddHotkey("x342 y409 w158 h28", StrLower(savedTarget))
settingsWindow.SetFont("s10 Bold c202938", "Segoe UI")
settingsWindow.AddText("x44 y469 w270 h22", "Toggle key")
settingsWindow.SetFont("s9 Norm c586174", "Segoe UI")
settingsWindow.AddText("x44 y495 w270 h22", "Press once to talk, again to stop")
settingsWindow.SetFont("s10 Norm c202938", "Segoe UI")
toggleControl := settingsWindow.AddHotkey("x342 y471 w158 h28", StrLower(savedToggle))
settingsWindow.SetFont("s9 Norm c586174", "Segoe UI")
settingsWindow.AddText("x44 y531 w456 h24", "Match the target key to Dota's own push-to-talk setting.")

settingsWindow.SetFont("s11 Bold c202938", "Segoe UI")
settingsWindow.AddGroupBox("x540 y88 w320 h302", "WASD camera controls")
settingsWindow.SetFont("s10 Norm c202938", "Segoe UI")
settingsWindow.AddText("x560 y118 w280 h42", "While active, WASD sends arrow keys and blocks the original letter inputs.")
settingsWindow.AddText("x560 y170 w280 h24", "W = Up     A = Left     S = Down     D = Right")
settingsWindow.AddText("x560 y207 w280 h22", "Activation key or mouse button")
cameraKeyControl := settingsWindow.AddComboBox("x560 y234 w280", activationChoices)
cameraKeyControl.Text := savedCameraKey
settingsWindow.AddText("x560 y278 w80 h24", "Mode")
cameraModeControl := settingsWindow.AddDropDownList("x648 y275 w192 Choose1", ["Hold", "Toggle"])
cameraModeControl.Choose(savedCameraMode = "Toggle" ? 2 : 1)
settingsWindow.SetFont("s9 Norm c586174", "Segoe UI")
settingsWindow.AddText("x560 y318 w280 h56", "Hold: active while pressed.`nToggle: press to turn on, press again to turn off. Alt-Tab turns it off.")
settingsWindow.SetFont("s11 Bold c202938", "Segoe UI")
settingsWindow.AddGroupBox("x540 y406 w320 h162", "Choosing activation keys")
settingsWindow.SetFont("s9 Norm c586174", "Segoe UI")
settingsWindow.AddText("x560 y436 w280 h112", "MButton = middle mouse`nXButton1 / XButton2 = side buttons`nYou can also type a single key name.`nBoth features can share an activation key.`nSpeed boost changes pointer speed, not Dota's arrow-key camera pan rate.")
; Shared actions and feedback.
settingsWindow.AddText("x24 y586 w836 h2 0x10")
settingsWindow.SetFont("s10 Bold c202938", "Segoe UI")
saveButton := settingsWindow.AddButton("x704 y603 w156 h34 Default", "Save settings")
settingsWindow.SetFont("s9 Norm c586174", "Segoe UI")
statusLabel := settingsWindow.AddText("x24 y603 w652 h52", "Voice changes apply automatically; mouse changes apply on the next press.")
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
    boostKeyControl.Text := "XButton1"
    cameraKeyControl.Text := "MButton"
    cameraModeControl.Choose(2)
    targetControl.Value := "F9"
    toggleControl.Value := "v"
    try {
        SaveSettings()
        if IniRead(settingsPath, "Mouse", "Multiplier") != "3.5"
            throw Error("Settings persistence test failed")
        if IniRead(settingsPath, "Voice", "TargetKey") != "F9" || StrLower(IniRead(settingsPath, "Voice", "ToggleKey")) != "v"
            throw Error("Voice persistence test failed")
        if IniRead(settingsPath, "Camera", "Mode") != "Toggle" || IniRead(settingsPath, "Mouse", "BoostKey") != "XButton1"
            throw Error("Camera settings persistence test failed")
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
settingsWindow.Show("w884 h672")

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
    global settingsPath, multiplierSlider, statusLabel, targetControl, toggleControl, boostKeyControl, cameraKeyControl, cameraModeControl
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
    boostChoice := Trim(boostKeyControl.Text)
    cameraChoice := Trim(cameraKeyControl.Text)
    if !ValidActivationKey(boostChoice) || !ValidActivationKey(cameraChoice) || RegExMatch(cameraChoice, "i)^(w|a|s|d|Up|Down|Left|Right)$") {
        MsgBox("Choose single activation keys or mouse buttons. Camera activation cannot be WASD or an arrow key.", "Activation keys", "Icon!")
        return
    }
    if GetKeyVK(boostChoice) = GetKeyVK(target) || GetKeyVK(boostChoice) = GetKeyVK(toggle) || GetKeyVK(cameraChoice) = GetKeyVK(target) || GetKeyVK(cameraChoice) = GetKeyVK(toggle) || RegExMatch(target, "i)^(w|a|s|d|Up|Down|Left|Right)$") || RegExMatch(toggle, "i)^(w|a|s|d|Up|Down|Left|Right)$") {
        MsgBox("Voice keys must differ from activation keys, WASD and arrow keys to avoid conflicts.", "Conflicting keys", "Icon!")
        return
    }
    try {
        DirCreate(A_AppData "\GeurtsyDota2Helpers")
        multiplierValue := Format("{:.1f}", multiplierSlider.Value / 10)
        IniWrite("Multiplier=" multiplierValue "`nBoostKey=" boostChoice, settingsPath, "Mouse")
        IniWrite("ActivationKey=" cameraChoice "`nMode=" cameraModeControl.Text, settingsPath, "Camera")
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



ValidActivationKey(key) {
    return RegExMatch(key, "i)^[a-z0-9]+$") && GetKeyVK(key) && !RegExMatch(key, "i)^Wheel")
}
