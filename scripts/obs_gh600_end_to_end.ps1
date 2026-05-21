[CmdletBinding()]
param(
    [string]$ObsPath,
    [string]$OutputRoot = "$HOME\Videos\TikTok\GH600",
    [string]$RepoRoot = "C:\2026\gh-certifications",
    [string]$ProfileName = "GH600-Vertical",
    [string]$CollectionName = "GH600-Vertical-45s",
    [switch]$AutoStartRecording
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK]   $Message" -ForegroundColor Green
}

function Write-WarnMsg {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Resolve-ObsPath {
    param([string]$UserPath)

    if ($UserPath -and (Test-Path $UserPath)) {
        return (Resolve-Path $UserPath).Path
    }

    $candidates = @(
        "$env:ProgramFiles\obs-studio\bin\64bit\obs64.exe",
        "$env:ProgramFiles(x86)\obs-studio\bin\64bit\obs64.exe",
        "$env:LOCALAPPDATA\Programs\obs-studio\bin\64bit\obs64.exe"
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $cmd = Get-Command obs64.exe -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    return $null
}

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Write-TextFile {
    param(
        [string]$Path,
        [string]$Content
    )

    $dir = Split-Path -Parent $Path
    Ensure-Dir -Path $dir
    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

Write-Step "Resolving OBS executable"
$resolvedObs = Resolve-ObsPath -UserPath $ObsPath
if (-not $resolvedObs) {
    throw "OBS executable was not found. Install OBS or pass -ObsPath with the full path to obs64.exe."
}
Write-Ok "OBS found at: $resolvedObs"

$obsExeDir = Split-Path -Parent $resolvedObs
$obsRootDir = Resolve-Path (Join-Path $obsExeDir "..\..")
$obsLocale = Join-Path $obsRootDir "data\obs-studio\locale\en-US.ini"
if (-not (Test-Path $obsLocale)) {
    Write-WarnMsg "OBS locale file not found at expected path: $obsLocale"
    Write-WarnMsg "If OBS shows locale errors, reinstall OBS from obsproject.com and avoid launching obs64.exe from copied folders."
}

Write-Step "Preparing output and guide folders"
Ensure-Dir -Path $OutputRoot
$assetRoot = Join-Path $OutputRoot "assets"
$notesRoot = Join-Path $OutputRoot "notes"
Ensure-Dir -Path $assetRoot
Ensure-Dir -Path $notesRoot
Write-Ok "Recording root ready: $OutputRoot"

Write-Step "Writing runbook files"
$voiceover = @"
I take GH-600 on Thursday, and this is the exact study setup I built.
Everything is in one GitHub hub: domain-aligned study guides, deep-dive references, and practice questions with explanations.
Then I use a native timed mock exam and a training game to stress-test retention under pressure.
I also included custom-agent guardrails, memory patterns, and CodeQL workflows, so I am studying real production patterns, not just flash cards.
I will post my result after Thursday, but this is the exact system I am running right now.
Comment GH600 if you want the same study sequence.
"@

$runOfShow = @"
00-03s  Hook on facecam
03-10s  Repo landing page and coverage totals
10-18s  Domain-aligned guide and deep-dive guides
18-25s  Native mock exam and training game
25-33s  Custom-agent guardrails and governance docs
33-40s  CodeQL docs path
40-45s  Facecam CTA: Comment GH600
"@

$onscreenText = @"
Stop scrolling if you are prepping for GH-600
GH-600 exam: Thursday
My actual prep stack
Timed mock plus training game
Production-safe patterns
Result update after exam
Comment GH600 for my study flow
"@

$caption = @"
Taking GH-600 this Thursday. This is my exact prep workflow: domain guides, timed mock, training game, guardrails, and CodeQL.
I will post my result after the exam. Comment GH600 for my study order.

#GH600 #GitHubCopilot #AgenticAI #GitHubCertification #CodeQL #SoftwareEngineering #TechTok #StudyWithMe
"@

$obsChecklist = @"
OBS Vertical Setup Checklist

1) Settings > Video
- Base Canvas: 1080x1920
- Output Scaled: 1080x1920
- FPS: 30

2) Settings > Output > Recording
- Format: MKV
- Encoder: NVENC or x264
- Rate control: CBR
- Bitrate: 10000
- Keyframe interval: 2

3) Scene: GH600-Vertical-45s
- Source: Display Capture (Screen)
- Source: Video Capture Device (Facecam)
- Source: Text (TopText)
- Source: Text (BottomCTA)

4) Audio Filters on Mic
- Noise Suppression: RNNoise
- Compressor: Threshold -18, Ratio 4:1, Attack 6ms, Release 60ms
- Limiter: -3dB

5) Hotkeys
- Start Recording: Ctrl+Shift+R
- Stop Recording: Ctrl+Shift+S
- Mute Mic: Ctrl+M
"@

Write-TextFile -Path (Join-Path $notesRoot "voiceover.txt") -Content $voiceover
Write-TextFile -Path (Join-Path $notesRoot "run_of_show.txt") -Content $runOfShow
Write-TextFile -Path (Join-Path $notesRoot "onscreen_text.txt") -Content $onscreenText
Write-TextFile -Path (Join-Path $notesRoot "caption_and_hashtags.txt") -Content $caption
Write-TextFile -Path (Join-Path $notesRoot "obs_setup_checklist.txt") -Content $obsChecklist
Write-Ok "Runbook files generated in: $notesRoot"

Write-Step "Checking OBS profile and collection availability"
$obsBase = Join-Path $env:APPDATA "obs-studio\basic"
$profileDir = Join-Path $obsBase "profiles\$ProfileName"
$collectionFile = Join-Path $obsBase "scenes\$CollectionName.json"

$profileExists = Test-Path $profileDir
$collectionExists = Test-Path $collectionFile

if ($profileExists -and $collectionExists) {
    Write-Ok "Profile and scene collection found. OBS will launch using them."
}
else {
    if (-not $profileExists) {
        Write-WarnMsg "Profile not found: $ProfileName"
    }
    if (-not $collectionExists) {
        Write-WarnMsg "Scene collection not found: $CollectionName"
    }
    Write-WarnMsg "OBS will still launch. Create the profile and scene once using notes\obs_setup_checklist.txt."
}

Write-Step "Opening repository docs in browser for recording"
$pages = @(
    (Join-Path $RepoRoot "README.md"),
    (Join-Path $RepoRoot "docs\index.md"),
    (Join-Path $RepoRoot "docs\gh-600-domain-aligned-study.md"),
    (Join-Path $RepoRoot "docs\gh-600-native-mock-exam.html"),
    (Join-Path $RepoRoot "docs\gh-600-training-game.html"),
    (Join-Path $RepoRoot "docs\custom-agents-admin-guide.md"),
    (Join-Path $RepoRoot "docs\codeql\01-database-preparation.md"),
    (Join-Path $RepoRoot "docs\codeql\02-run-queries.md")
)

foreach ($p in $pages) {
    if (Test-Path $p) {
        Start-Process $p | Out-Null
    }
}
Write-Ok "Docs opened"

Write-Step "Launching OBS"
$args = @()
if ($profileExists) {
    $args += "--profile"
    $args += $ProfileName
}
if ($collectionExists) {
    $args += "--collection"
    $args += $CollectionName
}
if ($AutoStartRecording) {
    $args += "--startrecording"
}

if ($args.Count -gt 0) {
    Start-Process -FilePath $resolvedObs -WorkingDirectory $obsExeDir -ArgumentList $args | Out-Null
}
else {
    Start-Process -FilePath $resolvedObs -WorkingDirectory $obsExeDir | Out-Null
}
Write-Ok "OBS launched"

Write-Host ""
Write-Host "Next:" -ForegroundColor Magenta
Write-Host "1) If first run, follow $notesRoot\obs_setup_checklist.txt" -ForegroundColor Magenta
Write-Host "2) Read from $notesRoot\voiceover.txt" -ForegroundColor Magenta
Write-Host "3) Record 45 seconds and remux MKV to MP4 in OBS" -ForegroundColor Magenta
