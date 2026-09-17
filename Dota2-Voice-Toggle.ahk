#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1

if A_Args.Length && A_Args[1] = "--validate"
    ExitApp()

voiceOn := false
gamePID := A_Args.Length ? Integer(A_Args[1]) : ProcessExist("dota2.exe")
if !gamePID || !ProcessExist(gamePID)
    ExitApp()

gameWindow := "ahk_pid " gamePID
; Borderless, click-through indicator that never takes keyboard focus.
voiceIndicator := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +E0x08000000")
voiceIndicator.BackColor := "153D2A"
voiceIndicator.MarginX := 14
voiceIndicator.MarginY := 8
voiceIndicator.SetFont("s11 cFFFFFF", "Segoe UI")
voiceIndicator.AddText(, "Voice chat ON  |  G to turn off")
A_IconTip := "Dota 2 voice: OFF (G toggles)"
OnExit(ReleaseVoice)
SetTimer(CheckGame, 100)

; KeyWait prevents a held G from toggling repeatedly.
#HotIf WinActive(gameWindow)
$*g::{
    global voiceOn, voiceIndicator, gameWindow
    voiceOn := !voiceOn
    SendEvent(voiceOn ? "{Blind}{F10 down}" : "{Blind}{F10 up}")
    A_IconTip := "Dota 2 voice: " (voiceOn ? "ON" : "OFF") " (G toggles)"
    if voiceOn {
        WinGetPos(&gameX, &gameY, &gameWidth, , gameWindow)
        voiceIndicator.Show("NoActivate AutoSize Hide")
        voiceIndicator.GetPos(, , &indicatorWidth)
        voiceIndicator.Show("NoActivate x" (gameX + (gameWidth - indicatorWidth) // 2) " y" (gameY + 40))
    } else {
        voiceIndicator.Hide()
    }
    KeyWait("g")
}
#HotIf

CheckGame() {
    global gamePID, gameWindow, voiceOn
    if !ProcessExist(gamePID)
        ExitApp()
    if voiceOn && !WinActive(gameWindow)
        ReleaseVoice()
}

ReleaseVoice(*) {
    global voiceOn, voiceIndicator
    voiceIndicator.Hide()
    if voiceOn {
        SendEvent("{Blind}{F10 up}")
        voiceOn := false
        A_IconTip := "Dota 2 voice: OFF (G toggles)"
    }
}
