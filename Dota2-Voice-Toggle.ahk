#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1

if A_Args.Length && A_Args[1] = "--validate"
    ExitApp()

featureEnabled := true
voiceOn := false
heldTarget := ""
targetKey := "F10"
toggleKey := "G"
settingsPath := A_AppData "\GeurtsyDota2Helpers\settings.ini"
gamePID := A_Args.Length ? Integer(A_Args[1]) : ProcessExist("dota2.exe")
if !DotaIsRunning()
    ExitApp()
gameWindow := "ahk_pid " gamePID
voiceIndicator := Gui("+AlwaysOnTop -Caption +Border +ToolWindow +E0x20 +E0x08000000", "Geurtsy Dota Voice Indicator")
voiceIndicator.BackColor := "17212B"
voiceIndicator.AddProgress("x0 y0 w4 h46 c55D6A0 Background55D6A0", 100)
voiceIndicator.SetFont("s10 Bold c75E6B5", "Segoe UI")
voiceIndicator.AddText("x16 y6 w290 h18", "VOICE CHAT  ON")
voiceIndicator.SetFont("s9 Norm cE2E8F0", "Segoe UI")
indicatorLabel := voiceIndicator.AddText("x16 y25 w290 h17", "G to turn off")
voiceIndicator.Show("NoActivate Hide w320 h46")
WinSetTransparent(235, voiceIndicator.Hwnd)
A_IconTip := "Dota 2 voice: OFF (G toggles)"
OnExit(ReleaseVoice)
OnError(VoiceError)
; Tilde passes the physical toggle key through to Dota, including text chat.
HotIf(VoiceContext)
Hotkey("~$*" toggleKey, ToggleVoice, "On")
HotIf()
LoadVoiceSettings()
SetTimer(CheckGame, 100)
SetTimer(LoadVoiceSettings, 500)

VoiceContext(*) {
    global gameWindow, featureEnabled
    return featureEnabled && DotaIsRunning() && WinActive(gameWindow)
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
        indicatorLabel.Text := toggleKey " to turn off"
        PositionVoiceIndicator()
    }
    Critical("Off")
    KeyWait(waitKey)
}

LoadVoiceSettings(*) {
    global settingsPath, targetKey, toggleKey, featureEnabled
    featureEnabled := FeatureIsEnabled("Voice")
    if !featureEnabled
        ReleaseVoice()
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
        Hotkey("~$*" nextToggle, ToggleVoice, "On")
        if StrLower(nextToggle) != StrLower(toggleKey)
            Hotkey("~$*" toggleKey, "Off")
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
    else if voiceOn
        PositionVoiceIndicator()
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

PositionVoiceIndicator() {
    global voiceIndicator, gameWindow
    if !WinActive(gameWindow)
        return
    WinGetPos(&gameX, &gameY, &gameWidth, , gameWindow)
    voiceIndicator.GetPos(, , &indicatorWidth)
    ; The first fixed slot is reserved for voice. Camera uses slot two.
    voiceIndicator.Show("NoActivate x" (gameX + (gameWidth - indicatorWidth) // 2) " y" (gameY + 40))
}


FeatureIsEnabled(name) {
    try return IniRead(A_AppData "\GeurtsyDota2Helpers\settings.ini", "Features", name, "1") != "0"
    catch
        return true
}
