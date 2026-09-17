#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1

if A_Args.Length && A_Args[1] = "--validate"
    ExitApp()

boostKey := 'MButton'
previousDown := false
InstallKeybdHook()
InstallMouseHook()
originalSpeed := 0
boosted := false
gamePID := A_Args.Length ? Integer(A_Args[1]) : ProcessExist("dota2.exe")
if !DotaIsRunning()
    ExitApp()
gameWindow := "ahk_pid " gamePID
A_IconTip := "Dota 2 mouse boost - hold your configured key"
A_TrayMenu.Insert("1&", "Settings...", OpenSettings)
OnExit(RestoreSpeed)
OnError(HandleError)
LoadBoostKey()
SetTimer(LoadBoostKey, 500)
SetTimer(CheckGame, 20)

; Observe the configurable physical key without swallowing its normal input.
CheckGame() {
    global gamePID, gameWindow, boosted, boostKey, previousDown
    if !DotaIsRunning()
        ExitApp()
    down := GetKeyState(boostKey, "P")
    focused := WinActive(gameWindow)
    if boosted && (!focused || !down)
        RestoreSpeed()
    if down && !previousDown && focused {
        ApplyBoost()
    }
    previousDown := down
}

ApplyBoost() {
    global originalSpeed, boosted
    Critical("On")
    try {
        originalSpeed := ReadSpeed()
        boosted := true
        WriteSpeed(BoostSpeed(originalSpeed, ReadMultiplier()))
        A_IconTip := "Dota 2 mouse boost - ON"
    } finally {
        Critical("Off")
    }
}

LoadBoostKey() {
    global boostKey, previousDown
    nextKey := "MButton"
    try nextKey := IniRead(A_AppData "\GeurtsyDota2Helpers\settings.ini", "Mouse", "BoostKey", "MButton")
    if !RegExMatch(nextKey, "i)^[a-z0-9]+$") || !GetKeyVK(nextKey) || RegExMatch(nextKey, "i)^Wheel")
        nextKey := "MButton"
    if StrLower(nextKey) != StrLower(boostKey) {
        RestoreSpeed()
        boostKey := nextKey
        previousDown := GetKeyState(boostKey, "P")
    }
}
ReadSpeed() {
    speed := 0
    if !DllCall("SystemParametersInfoW", "UInt", 0x70, "UInt", 0, "Int*", &speed, "UInt", 0)
        throw OSError()
    return speed
}

WriteSpeed(speed) {
    ; Flags=0: change the current session, without saving to the user profile.
    if !DllCall("SystemParametersInfoW", "UInt", 0x71, "UInt", 0, "Ptr", speed, "UInt", 0)
        throw OSError()
}

BoostSpeed(speed, multiplier := 2) {
    ; Windows pointer-speed steps are nonlinear. These nominal gains apply
    ; with Enhance pointer precision OFF; acceleration changes the result.
    gains := [0.03125, 0.0625, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1,
              1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5]
    target := gains[speed] * multiplier
    best := speed
    for index, gain in gains {
        if Abs(gain - target) < Abs(gains[best] - target)
            best := index
    }
    return best
}

ReadMultiplier() {
    try {
        value := IniRead(A_AppData "\GeurtsyDota2Helpers\settings.ini", "Mouse", "Multiplier", "2.0")
        if IsNumber(value) && value >= 1 && value <= 4
            return Number(value)
    }
    return 2.0
}

OpenSettings(*) {
    Run('"' A_AhkPath '" "' A_ScriptDir '\Dota2-Mouse-Settings.ahk"')
}

RestoreSpeed(*) {
    global boosted, originalSpeed
    Critical("On")
    try {
        if boosted {
            WriteSpeed(originalSpeed)
            boosted := false
            A_IconTip := "Dota 2 mouse boost - hold your configured key"
        }
    } finally {
        Critical("Off")
    }
}

HandleError(*) {
    RestoreSpeed()
    ; Let AutoHotkey display the original error after restoring the speed.
}

; Verify the process identity as well as its PID. A manually supplied PID
; must never allow these helpers to attach to an unrelated application.
DotaIsRunning() {
    global gamePID
    try {
        return gamePID && StrLower(ProcessGetName(gamePID)) = "dota2.exe"
    } catch {
        return false
    }
}


