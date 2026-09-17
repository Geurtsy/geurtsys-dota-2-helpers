param([switch]$ValidateOnly)

$ErrorActionPreference = 'Stop'

try {
    $watcherPath = Join-Path $PSScriptRoot 'Dota2-Voice-Watcher.ahk'
    $togglePath = Join-Path $PSScriptRoot 'Dota2-Voice-Toggle.ahk'
    foreach ($path in @($watcherPath, $togglePath)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw 'Extract the entire ZIP first. Keep Setup.bat, Setup.ps1 and both .ahk files together.'
        }
    }

    $installRoots = @(
        foreach ($key in @('HKCU:\SOFTWARE\AutoHotkey', 'HKLM:\SOFTWARE\AutoHotkey', 'HKLM:\SOFTWARE\WOW6432Node\AutoHotkey')) {
            $installation = Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue
            if ($installation.InstallDir) { $installation.InstallDir }
        }
        if ($env:ProgramFiles) { Join-Path $env:ProgramFiles 'AutoHotkey' }
        if (${env:ProgramFiles(x86)}) { Join-Path ${env:ProgramFiles(x86)} 'AutoHotkey' }
        if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey' }
    )

    $ahkExe = $null
    foreach ($root in ($installRoots | Select-Object -Unique)) {
        foreach ($relative in @('v2\AutoHotkey.exe', 'v2\AutoHotkey64.exe', 'v2\AutoHotkey32.exe', 'AutoHotkey.exe')) {
            $candidate = Join-Path $root $relative
            if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                $version = (Get-Item -LiteralPath $candidate).VersionInfo
                if ($version.FileMajorPart -eq 2) {
                    $ahkExe = $candidate
                    break
                }
            }
        }
        if ($ahkExe) { break }
    }
    if (-not $ahkExe) {
        throw 'AutoHotkey v2 was not found. Install it from https://www.autohotkey.com/ and run Setup.bat again.'
    }

    # Parse both scripts before changing the startup shortcut.
    foreach ($path in @($watcherPath, $togglePath)) {
        $check = Start-Process -FilePath $ahkExe -ArgumentList @('/ErrorStdOut', ('"' + $path + '"'), '--validate') -WindowStyle Hidden -Wait -PassThru
        if ($check.ExitCode -ne 0) { throw "AutoHotkey could not validate $path (exit $($check.ExitCode))." }
    }
    if ($ValidateOnly) {
        Write-Host 'Validation passed: AutoHotkey v2 and both helper scripts are ready. No startup changes made.'
        exit 0
    }

    $startupDirectory = [Environment]::GetFolderPath('Startup')
    if (-not $startupDirectory) { throw 'Windows did not provide a Startup folder for this user.' }
    New-Item -ItemType Directory -Path $startupDirectory -Force | Out-Null
    $shortcutPath = Join-Path $startupDirectory 'Dota 2 Voice Toggle.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $ahkExe
    $shortcut.Arguments = '"' + $watcherPath + '"'
    $shortcut.WorkingDirectory = $PSScriptRoot
    $shortcut.Description = 'Geurtsy''s Dota 2 Helpers - automatic voice toggle'
    $shortcut.Save()

    # Re-running setup updates the same shortcut. The watcher replaces its own
    # existing instance through AutoHotkey's #SingleInstance Force directive.
    $watcher = Start-Process -FilePath $ahkExe -ArgumentList $shortcut.Arguments -WindowStyle Hidden -PassThru
    Start-Sleep -Milliseconds 800
    $watcher.Refresh()
    if ($watcher.HasExited) {
        throw 'The startup shortcut was saved, but the watcher exited. Try launching Dota2-Voice-Watcher.ahk directly.'
    }
    Write-Host 'Setup complete! The watcher is running and will start each time you sign in.'
    Write-Host 'Keep this folder in its current location. Set Dota 2 push-to-talk to F10; press G to toggle voice.'
    Write-Host 'To disable startup, remove Dota 2 Voice Toggle.lnk from the shell:startup folder.'
} catch {
    Write-Host ('Setup failed: ' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
