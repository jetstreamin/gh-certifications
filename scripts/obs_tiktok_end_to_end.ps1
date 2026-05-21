[CmdletBinding()]
param(
    [string]$SceneName = "cb",
    [string]$WindowSourceName = "GH600 Window",
    [string]$FacecamSourceName = "Video Capture Device",
    [string]$RecordDirectory = "C:/Users/Michael/Videos/TikTok/GH600",
    [int]$DurationSeconds = 45,
    [string]$Password
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$applyScript = Join-Path $scriptRoot "obs_apply_vertical_layout.ps1"
$recordScript = Join-Path $scriptRoot "obs_record_45s.ps1"

if (-not (Test-Path $applyScript)) {
    throw "Missing script: $applyScript"
}
if (-not (Test-Path $recordScript)) {
    throw "Missing script: $recordScript"
}

Write-Step "Applying vertical OBS canvas + scene transforms"
try {
    & $applyScript -SceneName $SceneName -WindowSourceName $WindowSourceName -FacecamSourceName $FacecamSourceName -Password $Password
}
catch {
    throw "Vertical layout step failed. $($_.Exception.Message)"
}

Write-Step "Running timed recording"
try {
    & $recordScript -DurationSeconds $DurationSeconds -SceneName $SceneName -RecordDirectory $RecordDirectory -Password $Password
}
catch {
    throw "Timed recording step failed. $($_.Exception.Message)"
}

Write-Host "[OK]   End-to-end TikTok recording completed." -ForegroundColor Green
