#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1
if A_Args.Length && A_Args[1] = "--validate"
    ExitApp()

gamePID := A_Args.Length ? Integer(A_Args[1]) : ProcessExist("dota2.exe")
if !DotaIsRunning()
    ExitApp()
gameWindow := "ahk_pid " gamePID
cameraKey := "MButton"
cameraMode := "Hold"
toggled := false
captured := Map("w", false, "a", false, "s", false, "d", false)
sent := Map("w", false, "a", false, "s", false, "d", false)
arrows := Map("w", "Up", "a", "Left", "s", "Down", "d", "Right")
InstallKeybdHook()
InstallMouseHook()
OnExit(ReleaseArrows)
OnError(CameraError)
HotIf(GameFocused)
Hotkey("~*" cameraKey, ActivateCamera, "On")
HotIf()
LoadCameraSettings()
SetTimer(LoadCameraSettings, 500)
SetTimer(CheckCamera, 20)
A_IconTip := "Dota 2 WASD camera - " cameraMode " " cameraKey

#HotIf CaptureKey("w")
$*w::ArrowDown("w")
#HotIf captured["w"]
$*w up::ArrowUp("w")
#HotIf CaptureKey("a")
$*a::ArrowDown("a")
#HotIf captured["a"]
$*a up::ArrowUp("a")
#HotIf CaptureKey("s")
$*s::ArrowDown("s")
#HotIf captured["s"]
$*s up::ArrowUp("s")
#HotIf CaptureKey("d")
$*d::ArrowDown("d")
#HotIf captured["d"]
$*d up::ArrowUp("d")
#HotIf

GameFocused(*) {
    global gameWindow
    return DotaIsRunning() && WinActive(gameWindow)
}
CameraActive() {
    global cameraMode, cameraKey, toggled
    return GameFocused() && (cameraMode = "Toggle" ? toggled : GetKeyState(cameraKey, "P"))
}
CaptureKey(key) {
    global captured
    return GameFocused() && (CameraActive() || captured[key])
}
ActivateCamera(*) {
    global cameraMode, cameraKey, toggled
    waitKey := cameraKey
    if cameraMode = "Toggle" && GameFocused() {
        toggled := !toggled
        if !toggled
            ReleaseArrows()
    }
    KeyWait(waitKey)
}
ArrowDown(key) {
    global captured, sent, arrows
    Critical("On")
    captured[key] := true
    if CameraActive() {
        sent[key] := true
        SendEvent("{Blind}{" arrows[key] " down}")
    }
    Critical("Off")
}
ArrowUp(key) {
    global captured, sent, arrows
    Critical("On")
    if sent[key]
        SendEvent("{Blind}{" arrows[key] " up}")
    sent[key] := false
    captured[key] := false
    Critical("Off")
}
ReleaseArrows(*) {
    global sent, arrows
    for key, isDown in sent {
        if isDown {
            SendEvent("{Blind}{" arrows[key] " up}")
            sent[key] := false
        }
    }
}
CheckCamera() {
    global toggled, captured
    if !DotaIsRunning()
        ExitApp()
    if !GameFocused()
        toggled := false
    if !CameraActive()
        ReleaseArrows()
    for key, consumed in captured {
        if consumed && !GetKeyState(key, "P")
            ArrowUp(key)
    }
}
LoadCameraSettings() {
    global cameraKey, cameraMode, toggled
    nextKey := "MButton"
    nextMode := "Hold"
    path := A_AppData "\GeurtsyDota2Helpers\settings.ini"
    try {
        nextKey := IniRead(path, "Camera", "ActivationKey", "MButton")
        nextMode := IniRead(path, "Camera", "Mode", "Hold")
    }
    if !RegExMatch(nextKey, "i)^[a-z0-9]+$") || !GetKeyVK(nextKey) || RegExMatch(nextKey, "i)^(w|a|s|d|Up|Left|Down|Right|Wheel.*)$")
        nextKey := "MButton"
    if nextMode != "Hold" && nextMode != "Toggle"
        nextMode := "Hold"
    if StrLower(nextKey) = StrLower(cameraKey) && nextMode = cameraMode
        return
    Critical("On")
    try {
        ReleaseArrows()
        toggled := false
        HotIf(GameFocused)
        Hotkey("~*" nextKey, ActivateCamera, "On")
        if StrLower(nextKey) != StrLower(cameraKey)
            Hotkey("~*" cameraKey, "Off")
        cameraKey := nextKey
        cameraMode := nextMode
        A_IconTip := "Dota 2 WASD camera - " cameraMode " " cameraKey
    } finally {
        HotIf()
        Critical("Off")
    }
}
CameraError(*) {
    ReleaseArrows()
}
DotaIsRunning() {
    global gamePID
    try return gamePID && StrLower(ProcessGetName(gamePID)) = "dota2.exe"
    catch
        return false
}
