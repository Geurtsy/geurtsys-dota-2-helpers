#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1

if A_Args.Length && A_Args[1] = "--validate"
    ExitApp()

voiceOn := false
heldTarget := ""
targetKey := "F10"
toggleKey := "G"
settingsPath := A_AppData "\GeurtsyDota2Helpers\settings.ini"
gamePID := A_Args.Length ? Integer(A_Args[1]) : ProcessExist("dota2.exe")
if !DotaIsRunning()
    ExitApp()
gameWindow := "ahk_pid " gamePID
voiceIndicator := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +E0x08000000")
voiceIndicator.BackColor := "153D2A"
voiceIndicator.MarginX := 14
voiceIndicator.MarginY := 8
voiceIndicator.SetFont("s11 cFFFFFF", "Segoe UI")
indicatorLabel := voiceIndicator.AddText(, "Voice chat ON  |  G to turn off")
A_IconTip := "Dota 2 voice: OFF (G toggles)"
OnExit(ReleaseVoice)
OnError(VoiceError)
HotIf(VoiceContext)
Hotkey("$*" toggleKey, ToggleVoice, "On")
HotIf()
LoadVoiceSettings()
SetTimer(CheckGame, 100)
SetTimer(LoadVoiceSettings, 500)

VoiceContext(*) {
    global gameWindow
    return DotaIsRunning() && WinActive(gameWindow)
}

ToggleVoice(*) {
    global voiceOn, heldTarget, targetKey, toggleKey, voiceIndicator, gameWindow, indicatorLabel
    Critical("On")
    if !VoiceContext() {
        Critical("Off")
        return
    }
    waitKey := toggleKey
    if voiceOn {
        ReleaseVoice()
    } else {
        heldTarget := targetKey
        voiceOn := true
        SendEvent("{Blind}{" heldTarget " down}")
        A_IconTip := "Dota 2 voice: ON (" toggleKey " toggles)"
        indicatorLabel.Text := "Voice chat ON  |  " toggleKey " to turn off"
        WinGetPos(&gameX, &gameY, &gameWidth, , gameWindow)
        voiceIndicator.Show("NoActivate AutoSize Hide")
        voiceIndicator.GetPos(, , &indicatorWidth)
        voiceIndicator.Show("NoActivate x" (gameX + (gameWidth - indicatorWidth) // 2) " y" (gameY + 40))
    }
    Critical("Off")
    KeyWait(waitKey)
}

LoadVoiceSettings(*) {
    global settingsPath, targetKey, toggleKey
    nextTarget := "F10"
    nextToggle := "G"
    try {
        nextTarget := IniRead(settingsPath, "Voice", "TargetKey", "F10")
        nextToggle := IniRead(settingsPath, "Voice", "ToggleKey", "G")
    }
    if !ValidVoiceKey(nextTarget) || !ValidVoiceKey(nextToggle) || GetKeyVK(nextTarget) = GetKeyVK(nextToggle) {
        nextTarget := "F10"
        nextToggle := "G"
    }
    if nextTarget = targetKey && nextToggle = toggleKey
        return
    Critical("On")
    try {
        ; Release the previous target before replacing bindings.
        ReleaseVoice()
        Critical("On")
        HotIf(VoiceContext)
        Hotkey("$*" nextToggle, ToggleVoice, "On")
        if StrLower(nextToggle) != StrLower(toggleKey)
            Hotkey("$*" toggleKey, "Off")
        targetKey := nextTarget
        toggleKey := nextToggle
        A_IconTip := "Dota 2 voice: OFF (" toggleKey " toggles)"
    } finally {
        HotIf()
        Critical("Off")
    }
}

ValidVoiceKey(key) {
    return RegExMatch(key, "i)^[a-z0-9]+$") && GetKeyVK(key)
        && !RegExMatch(key, "i)^(.*Button|Wheel.*|.*Shift|.*Control|.*Ctrl|.*Alt|.*Win)$")
}

CheckGame() {
    global gameWindow, voiceOn
    if !DotaIsRunning()
        ExitApp()
    if voiceOn && !WinActive(gameWindow)
        ReleaseVoice()
}

ReleaseVoice(*) {
    global voiceOn, voiceIndicator, heldTarget, toggleKey
    voiceIndicator.Hide()
    if voiceOn {
        SendEvent("{Blind}{" heldTarget " up}")
        voiceOn := false
        heldTarget := ""
        A_IconTip := "Dota 2 voice: OFF (" toggleKey " toggles)"
    }
}

VoiceError(*) {
    ReleaseVoice()
}

DotaIsRunning() {
    global gamePID
    try {
        return gamePID && StrLower(ProcessGetName(gamePID)) = "dota2.exe"
    } catch {
        return false
    }
}
