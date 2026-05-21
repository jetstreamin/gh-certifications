[CmdletBinding()]
param(
    [string]$ObsHost = "localhost",
    [int]$Port = 4455,
    [string]$Password,
    [int]$DurationSeconds = 45,
    [string]$SceneName = "cb",
    [string]$RecordDirectory = "C:/Users/Michael/Videos/TikTok/GH600"
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

    Write-Step "Applying scene and recording directory"
    if ($SceneName) {
        [void](Invoke-ObsRequest -WebSocket $ws -RequestType "SetCurrentProgramScene" -RequestData @{ sceneName = $SceneName })
    }
    if ($RecordDirectory) {
        [void](Invoke-ObsRequest -WebSocket $ws -RequestType "SetRecordDirectory" -RequestData @{ recordDirectory = $RecordDirectory })
    }
    Write-Ok "Scene and directory ready"

    Write-Step "Starting recording"
    [void](Invoke-ObsRequest -WebSocket $ws -RequestType "StartRecord")
    $active = $false
    for ($i = 0; $i -lt 5; $i++) {
        Start-Sleep -Milliseconds 300
        $recordStatus = Invoke-ObsRequest -WebSocket $ws -RequestType "GetRecordStatus"
        if ($recordStatus.outputActive) {
            $active = $true
            break
        }
    }
    if (-not $active) {
        throw "OBS did not enter active recording state. Check OBS Output settings, recording path permissions, and encoder availability."
    }
    Write-Ok "Recording started"

    Write-Step "Recording for $DurationSeconds seconds"
    Start-Sleep -Seconds $DurationSeconds

    Write-Step "Stopping recording"
    $recordStatus = Invoke-ObsRequest -WebSocket $ws -RequestType "GetRecordStatus"
    if ($recordStatus.outputActive) {
        try {
            $stopResponse = Invoke-ObsRequest -WebSocket $ws -RequestType "StopRecord"
            $outputPath = $stopResponse.outputPath
            if ($outputPath) {
                Write-Ok "Saved: $outputPath"
            }
            else {
                Write-Ok "Recording stopped"
            }
        }
        catch {
            Write-Warning "StopRecord failed; trying ToggleRecord fallback."
            [void](Invoke-ObsRequest -WebSocket $ws -RequestType "ToggleRecord")
            Write-Ok "Recording toggled off"
        }
    }
    else {
        Write-Warning "Recording was already inactive before stop request."
    }
}
finally {
    $ws.Dispose()
}
