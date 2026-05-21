[CmdletBinding()]
param(
    [string]$ObsHost = "localhost",
    [int]$Port = 4455,
    [string]$Password,
    [string]$SceneName = "cb",
    [string]$WindowSourceName = "GH600 Window",
    [string]$FacecamSourceName = "Video Capture Device",
    [string]$BrowserSourceName = "GH600 Browser",
    [string]$BrowserUrl = "file:///C:/2026/gh-certifications/scripts/tiktok_scene.html",
    [string]$DisplaySourceName = "GH600 Display",
    [bool]$PreferDisplayCapture = $false
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

function Get-ObsAuthentication {
    param(
        [string]$PasswordText,
        [string]$Salt,
        [string]$Challenge
    )

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $secretBytes = [System.Text.Encoding]::UTF8.GetBytes($PasswordText + $Salt)
        $secretHash = $sha.ComputeHash($secretBytes)
        $secretBase64 = [Convert]::ToBase64String($secretHash)

        $authBytes = [System.Text.Encoding]::UTF8.GetBytes($secretBase64 + $Challenge)
        $authHash = $sha.ComputeHash($authBytes)
        return [Convert]::ToBase64String($authHash)
    }
    finally {
        $sha.Dispose()
    }
}

function Receive-ObsMessage {
    param([System.Net.WebSockets.ClientWebSocket]$WebSocket)

    $buffer = New-Object byte[] 32768
    $sb = New-Object System.Text.StringBuilder

    while ($true) {
        $segment = New-Object System.ArraySegment[byte] -ArgumentList (, $buffer)
        $result = $WebSocket.ReceiveAsync($segment, [Threading.CancellationToken]::None).GetAwaiter().GetResult()

        if ($result.MessageType -eq [System.Net.WebSockets.WebSocketMessageType]::Close) {
            throw "OBS websocket closed the connection unexpectedly."
        }

        $chunk = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $result.Count)
        [void]$sb.Append($chunk)

        if ($result.EndOfMessage) {
            break
        }
    }

    return $sb.ToString()
}

function Send-ObsJson {
    param(
        [System.Net.WebSockets.ClientWebSocket]$WebSocket,
        [hashtable]$Payload
    )

    $json = $Payload | ConvertTo-Json -Depth 20 -Compress
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $segment = New-Object System.ArraySegment[byte] -ArgumentList (, $bytes)
    [void]$WebSocket.SendAsync($segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
}

function Invoke-ObsRequest {
    param(
        [System.Net.WebSockets.ClientWebSocket]$WebSocket,
        [string]$RequestType,
        [hashtable]$RequestData = @{}
    )

    $requestId = [Guid]::NewGuid().ToString("N")
    Send-ObsJson -WebSocket $WebSocket -Payload @{
        op = 6
        d  = @{
            requestType = $RequestType
            requestId   = $requestId
            requestData = $RequestData
        }
    }

    while ($true) {
        $raw = Receive-ObsMessage -WebSocket $WebSocket
        $msg = $raw | ConvertFrom-Json

        if ($msg.op -eq 7 -and $msg.d.requestId -eq $requestId) {
            if (-not $msg.d.requestStatus.result) {
                $comment = $msg.d.requestStatus.comment
                throw "OBS request failed: $RequestType. $comment"
            }
            return $msg.d.responseData
        }
    }
}

function Get-SceneItemIdSafely {
    param(
        [System.Net.WebSockets.ClientWebSocket]$WebSocket,
        [string]$Scene,
        [string]$Source
    )

    try {
        $idResponse = Invoke-ObsRequest -WebSocket $WebSocket -RequestType "GetSceneItemId" -RequestData @{
            sceneName  = $Scene
            sourceName = $Source
        }
        return [int]$idResponse.sceneItemId
    }
    catch {
        return $null
    }
}

function Get-CoverTransform {
    param(
        [double]$SourceWidth,
        [double]$SourceHeight,
        [double]$TargetWidth,
        [double]$TargetHeight
    )

    if ($SourceWidth -le 0 -or $SourceHeight -le 0) {
        throw "Invalid source dimensions for cover transform."
    }

    $scale = [Math]::Max($TargetWidth / $SourceWidth, $TargetHeight / $SourceHeight)
    $scaledWidth = $SourceWidth * $scale
    $scaledHeight = $SourceHeight * $scale

    return @{
        scaleX = $scale
        scaleY = $scale
        posX = ($TargetWidth - $scaledWidth) / 2
        posY = ($TargetHeight - $scaledHeight) / 2
    }
}

function Set-WindowCaptureCompatibility {
    param(
        [System.Net.WebSockets.ClientWebSocket]$WebSocket,
        [string]$InputName
    )

    $attempts = @(
        @{ method = "bitblt" },
        @{ capture_method = "bitblt" },
        @{ method = "auto" },
        @{ capture_method = "auto" }
    )

    foreach ($settings in $attempts) {
        try {
            [void](Invoke-ObsRequest -WebSocket $WebSocket -RequestType "SetInputSettings" -RequestData @{
                inputName = $InputName
                inputSettings = $settings
                overlay = $true
            })
            Write-Ok ("Applied window-capture compatibility settings to {0}: {1}" -f $InputName, (($settings.Keys | ForEach-Object { "$_=$($settings[$_])" }) -join ", "))
            return
        }
        catch {
            continue
        }
    }

    Write-WarnMsg "Could not force window capture method; OBS kept existing capture mode."
}

function Set-WindowCaptureTarget {
    param(
        [System.Net.WebSockets.ClientWebSocket]$WebSocket,
        [string]$InputName
    )

    try {
        $itemsResponse = Invoke-ObsRequest -WebSocket $WebSocket -RequestType "GetInputPropertiesListPropertyItems" -RequestData @{
            inputName = $InputName
            propertyName = "window"
        }
    }
    catch {
        Write-WarnMsg "Could not query window list for input '$InputName'."
        return
    }

    $items = @($itemsResponse.propertyItems)
    if ($items.Count -eq 0) {
        Write-WarnMsg "OBS returned no capture windows for '$InputName'."
        return
    }

    $preferred = $items | Where-Object {
        $_.itemValue -match "chrome\.exe" -and $_.itemName -match "GitHub Certifications"
    } | Select-Object -First 1

    if (-not $preferred) {
        $preferred = $items | Where-Object {
            $_.itemValue -match "chrome\.exe"
        } | Select-Object -First 1
    }

    if (-not $preferred) {
        $preferred = $items | Select-Object -First 1
    }

    [void](Invoke-ObsRequest -WebSocket $WebSocket -RequestType "SetInputSettings" -RequestData @{
        inputName = $InputName
        inputSettings = @{ window = $preferred.itemValue }
        overlay = $true
    })

    Write-Ok ("Target window for {0}: {1}" -f $InputName, $preferred.itemName)
}

function Ensure-VisualSource {
    param(
        [System.Net.WebSockets.ClientWebSocket]$WebSocket,
        [string]$Scene,
        [string]$SourceName,
        [string]$Kind,
        [hashtable]$Settings
    )

    $exists = $false
    try {
        [void](Invoke-ObsRequest -WebSocket $WebSocket -RequestType "GetInputSettings" -RequestData @{ inputName = $SourceName })
        $exists = $true
    }
    catch {
        $exists = $false
    }

    if (-not $exists) {
        [void](Invoke-ObsRequest -WebSocket $WebSocket -RequestType "CreateInput" -RequestData @{
            sceneName = $Scene
            inputName = $SourceName
            inputKind = $Kind
            inputSettings = $Settings
            sceneItemEnabled = $true
        })
        Write-Ok ("Created source: {0} ({1})" -f $SourceName, $Kind)
    }

    [void](Invoke-ObsRequest -WebSocket $WebSocket -RequestType "SetInputSettings" -RequestData @{
        inputName = $SourceName
        inputSettings = $Settings
        overlay = $true
    })

    $itemId = Get-SceneItemIdSafely -WebSocket $WebSocket -Scene $Scene -Source $SourceName
    if ($null -eq $itemId) {
        $createResp = Invoke-ObsRequest -WebSocket $WebSocket -RequestType "CreateInput" -RequestData @{
            sceneName = $Scene
            inputName = $SourceName
            inputKind = $Kind
            inputSettings = $Settings
            sceneItemEnabled = $true
        }
        $itemId = [int]$createResp.sceneItemId
    }

    $current = Invoke-ObsRequest -WebSocket $WebSocket -RequestType "GetSceneItemTransform" -RequestData @{
        sceneName = $Scene
        sceneItemId = $itemId
    }
    $srcW = [double]$current.sceneItemTransform.sourceWidth
    $srcH = [double]$current.sceneItemTransform.sourceHeight

    if ($srcW -gt 0 -and $srcH -gt 0) {
        $cover = Get-CoverTransform -SourceWidth $srcW -SourceHeight $srcH -TargetWidth 1080 -TargetHeight 1920

        [void](Invoke-ObsRequest -WebSocket $WebSocket -RequestType "SetSceneItemTransform" -RequestData @{
            sceneName = $Scene
            sceneItemId = $itemId
            sceneItemTransform = @{
                positionX = $cover.posX
                positionY = $cover.posY
                rotation = 0
                scaleX = $cover.scaleX
                scaleY = $cover.scaleY
                alignment = 0
                boundsType = "OBS_BOUNDS_NONE"
                boundsAlignment = 0
                boundsWidth = 1
                boundsHeight = 1
                cropTop = 0
                cropBottom = 0
                cropLeft = 0
                cropRight = 0
            }
        })

        Write-Ok ("Applied cover transform to {0} (src {1}x{2}; scale {3}; pos {4},{5})" -f $SourceName, [int]$srcW, [int]$srcH, [Math]::Round($cover.scaleX, 4), [int]$cover.posX, [int]$cover.posY)
    }
    else {
        [void](Invoke-ObsRequest -WebSocket $WebSocket -RequestType "SetSceneItemTransform" -RequestData @{
            sceneName = $Scene
            sceneItemId = $itemId
            sceneItemTransform = @{
                positionX = 0
                positionY = 0
                rotation = 0
                scaleX = 1
                scaleY = 1
                alignment = 0
                boundsType = "OBS_BOUNDS_SCALE_OUTER"
                boundsAlignment = 0
                boundsWidth = 1080
                boundsHeight = 1920
                cropTop = 0
                cropBottom = 0
                cropLeft = 0
                cropRight = 0
            }
        })
        Write-WarnMsg ("Applied fallback bounds transform to {0} because source dimensions were unavailable." -f $SourceName)
    }

    return $itemId
}

Write-Step "Connecting to OBS websocket at ws://$ObsHost`:$Port"
$ws = [System.Net.WebSockets.ClientWebSocket]::new()
$uri = [Uri]::new("ws://$ObsHost`:$Port")
[void]$ws.ConnectAsync($uri, [Threading.CancellationToken]::None).GetAwaiter().GetResult()

try {
    $helloRaw = Receive-ObsMessage -WebSocket $ws
    $hello = $helloRaw | ConvertFrom-Json
    if ($hello.op -ne 0) {
        throw "Unexpected OBS handshake response."
    }

    $identifyData = @{ rpcVersion = 1 }
    if ($hello.d.authentication) {
        if (-not $Password) {
            throw "OBS authentication is enabled. Re-run with -Password."
        }
        $identifyData.authentication = Get-ObsAuthentication -PasswordText $Password -Salt $hello.d.authentication.salt -Challenge $hello.d.authentication.challenge
    }

    Send-ObsJson -WebSocket $ws -Payload @{ op = 1; d = $identifyData }

    while ($true) {
        $identifiedRaw = Receive-ObsMessage -WebSocket $ws
        $identified = $identifiedRaw | ConvertFrom-Json
        if ($identified.op -eq 2) {
            break
        }
    }
    Write-Ok "Connected and identified"

    Write-Step "Setting vertical video format (1080x1920 @ 30fps)"
    [void](Invoke-ObsRequest -WebSocket $ws -RequestType "SetVideoSettings" -RequestData @{
        baseWidth    = 1080
        baseHeight   = 1920
        outputWidth  = 1080
        outputHeight = 1920
        fpsNumerator = 30
        fpsDenominator = 1
    })
    $video = Invoke-ObsRequest -WebSocket $ws -RequestType "GetVideoSettings"
    Write-Ok ("Video now: {0}x{1} -> {2}x{3} @ {4}/{5} fps" -f $video.baseWidth, $video.baseHeight, $video.outputWidth, $video.outputHeight, $video.fpsNumerator, $video.fpsDenominator)

    Write-Step "Ensuring target scene exists and is active"
    $sceneList = Invoke-ObsRequest -WebSocket $ws -RequestType "GetSceneList"
    $sceneNames = @($sceneList.scenes | ForEach-Object { $_.sceneName })
    if ($sceneNames -notcontains $SceneName) {
        [void](Invoke-ObsRequest -WebSocket $ws -RequestType "CreateScene" -RequestData @{ sceneName = $SceneName })
        Write-Ok "Created scene: $SceneName"
    }
    [void](Invoke-ObsRequest -WebSocket $ws -RequestType "SetCurrentProgramScene" -RequestData @{ sceneName = $SceneName })
    Write-Ok "Current scene: $SceneName"

    Write-Step "Applying source layout transforms"

    $activeSourceName = $null
    if ($PreferDisplayCapture) {
        try {
            [void](Ensure-VisualSource -WebSocket $ws -Scene $SceneName -SourceName $DisplaySourceName -Kind "monitor_capture" -Settings @{
                monitor = 0
                capture_cursor = $true
            })
            $activeSourceName = $DisplaySourceName
            Write-Ok "Display source ready: $DisplaySourceName"
        }
        catch {
            Write-WarnMsg ("Display capture source setup failed, falling back to browser source. " + $_.Exception.Message)
        }
    }

    if (-not $activeSourceName) {
        [void](Ensure-VisualSource -WebSocket $ws -Scene $SceneName -SourceName $BrowserSourceName -Kind "browser_source" -Settings @{
            url = $BrowserUrl
            width = 2160
            height = 3840
            shutdown = $false
            reroute_audio = $false
        })
        $activeSourceName = $BrowserSourceName
        Write-Ok "Browser source ready: $BrowserSourceName"
    }

    foreach ($toHide in @($WindowSourceName, $BrowserSourceName, $DisplaySourceName)) {
        if ($toHide -ne $activeSourceName) {
            $itemId = Get-SceneItemIdSafely -WebSocket $ws -Scene $SceneName -Source $toHide
            if ($null -ne $itemId) {
                [void](Invoke-ObsRequest -WebSocket $ws -RequestType "SetSceneItemEnabled" -RequestData @{
                    sceneName = $SceneName
                    sceneItemId = $itemId
                    sceneItemEnabled = $false
                })
                Write-Ok "Disabled source in scene: $toHide"
            }
        }
        else {
            $itemId = Get-SceneItemIdSafely -WebSocket $ws -Scene $SceneName -Source $toHide
            if ($null -ne $itemId) {
                [void](Invoke-ObsRequest -WebSocket $ws -RequestType "SetSceneItemEnabled" -RequestData @{
                    sceneName = $SceneName
                    sceneItemId = $itemId
                    sceneItemEnabled = $true
                })
            }
        }
    }

    $faceItemId = Get-SceneItemIdSafely -WebSocket $ws -Scene $SceneName -Source $FacecamSourceName
    if ($null -ne $faceItemId) {
        [void](Invoke-ObsRequest -WebSocket $ws -RequestType "SetSceneItemTransform" -RequestData @{
            sceneName = $SceneName
            sceneItemId = $faceItemId
            sceneItemTransform = @{
                positionX = 740
                positionY = 1420
                rotation = 0
                scaleX = 1
                scaleY = 1
                alignment = 5
                boundsType = "OBS_BOUNDS_SCALE_INNER"
                boundsAlignment = 5
                boundsWidth = 320
                boundsHeight = 320
            }
        })
        Write-Ok "Applied facecam transform to $FacecamSourceName"
    }
    else {
        Write-WarnMsg "Could not find source '$FacecamSourceName' in scene '$SceneName'."
    }

    Write-Host ""
    Write-Host "Vertical layout applied." -ForegroundColor Magenta
    Write-Host "Run your timed record command next:" -ForegroundColor Magenta
    Write-Host "powershell -ExecutionPolicy Bypass -File C:\2026\gh-certifications\scripts\obs_record_45s.ps1 -DurationSeconds 45 -SceneName $SceneName" -ForegroundColor Magenta
}
finally {
    $ws.Dispose()
}
