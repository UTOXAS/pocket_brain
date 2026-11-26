# Runs `patrol test` on an Android device/emulator and records the screen from app launch.
param(
    [string]$Target  = "",
    [string]$Device  = "",
    [string]$Package = "com.pocketbrain.pocket_brain",
    [double]$Scale   = 0.5,
    [int]$BitRate    = 1000000,
    [string]$OutDir  = "test_videos"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# locate adb (PATH first, then Android SDK)
$adbCmd = Get-Command adb -ErrorAction SilentlyContinue
if ($adbCmd) {
    $adb = $adbCmd.Source
} else {
    $sdk = $env:ANDROID_HOME
    if (-not $sdk) { $sdk = $env:ANDROID_SDK_ROOT }
    if (-not $sdk) { $sdk = Join-Path $env:LOCALAPPDATA "Android\Sdk" }
    $adb = Join-Path (Join-Path $sdk "platform-tools") "adb.exe"
}
if (-not (Test-Path $adb)) { throw "adb not found. Add it to PATH or set ANDROID_HOME." }

# pick the first connected device when none is given
if (-not $Device) {
    $found = @(& $adb devices | Where-Object { $_ -match '^\S+\s+device$' } | ForEach-Object { ($_ -split '\s+')[0] })
    if ($found.Count -eq 0) { throw "No Android device/emulator connected." }
    $Device = $found[0]
}

# reduced recording size (multiples of 16 for encoder compatibility)
$wm   = [regex]::Matches((& $adb -s $Device shell wm size | Out-String), '(\d+)x(\d+)')
$last = $wm[$wm.Count - 1]
$w = [math]::Max(16, [math]::Floor([int]$last.Groups[1].Value * $Scale / 16) * 16)
$h = [math]::Max(16, [math]::Floor([int]$last.Groups[2].Value * $Scale / 16) * 16)

$remote = "/sdcard/patrol_test.mp4"
& $adb -s $Device shell rm -f $remote

# patrol arguments (secrets.json is used only when it exists)
$patrolArgs = @("test", "-d", $Device)
if ($Target) { $patrolArgs += @("-t", $Target) }
if (Test-Path (Join-Path $PSScriptRoot "secrets.json")) {
    $patrolArgs += "--dart-define-from-file=secrets.json"
    Write-Host "[INFO] secrets.json found - passing it to patrol"
}

$patrolExe = (Get-Command patrol -ErrorAction Stop).Source
$patrol = Start-Process $patrolExe -ArgumentList $patrolArgs -NoNewWindow -PassThru
$null = $patrol.Handle

# wait until the app is in the foreground, then start recording
$recorder = $null
while (-not $patrol.HasExited) {
    $focus = & $adb -s $Device shell "dumpsys window | grep mCurrentFocus" 2>$null
    if ($focus -match [regex]::Escape($Package)) {
        $recorder = Start-Process $adb -ArgumentList "-s", $Device, "shell", "screenrecord",
            "--size", "$($w)x$($h)", "--bit-rate", "$BitRate", $remote -WindowStyle Hidden -PassThru
        Write-Host "`n[REC] App launched - recording started ($($w)x$($h), $BitRate bps)"
        break
    }
    Start-Sleep -Milliseconds 500
}

$patrol.WaitForExit()

# stop recording gracefully (SIGINT finalizes the MP4), then pull the file
if ($recorder) {
    & $adb -s $Device shell pkill -2 screenrecord | Out-Null
    $null = $recorder.WaitForExit(10000)

    New-Item -ItemType Directory -Force $OutDir | Out-Null
    $local = Join-Path $OutDir ("patrol_test_{0:yyyyMMdd_HHmmss}.mp4" -f (Get-Date))
    & $adb -s $Device pull $remote $local | Out-Null
    & $adb -s $Device shell rm -f $remote

    $mb = "{0:N2}" -f ((Get-Item $local).Length / 1MB)
    Write-Host "[REC] Video saved: $local ($mb MB)"
} else {
    Write-Warning "App never launched - no video recorded."
}

exit $patrol.ExitCode