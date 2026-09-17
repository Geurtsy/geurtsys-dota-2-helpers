#Requires AutoHotkey v2.0
#SingleInstance Force

; Run automatically at Windows sign-in. Launch the voice script for each game.
if A_Args.Length && A_Args[1] = "--validate"
    ExitApp()

A_IconTip := "Dota 2 voice toggle - waiting for Dota 2"
Loop {
    gamePID := ProcessWait("dota2.exe")
    A_IconTip := "Dota 2 voice toggle - game detected"
    Run('"' A_AhkPath '" "' A_ScriptDir '\Dota2-Voice-Toggle.ahk" ' gamePID)
    ProcessWaitClose(gamePID)
    A_IconTip := "Dota 2 voice toggle - waiting for Dota 2"
    Sleep(500)
}
