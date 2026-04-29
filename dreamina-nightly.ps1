[CmdletBinding()]
param(
    [string]$ConfigPath,
    [string]$InputPath,
    [switch]$RunOnce,
    [switch]$CheckOnly,
    [switch]$InstallOnly,
    [switch]$LoginOnly,
    [switch]$ScanOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $PSNativeCommandUseErrorActionPreference = $false
}

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot 'config.json'
}

$script:VersionUrl = 'https://lf3-static.bytednsdoc.com/obj/eden-cn/psj_hupthlyk/ljhwZthlaukjlkulzlp/version.json'
$script:BinaryUrl = 'https://lf3-static.bytednsdoc.com/obj/eden-cn/psj_hupthlyk/ljhwZthlaukjlkulzlp/dreamina_cli_beta/dreamina_cli_windows_amd64.exe'
$script:CliInstallDir = Join-Path $env:USERPROFILE 'bin'
$script:CliPath = Join-Path $script:CliInstallDir 'dreamina.exe'
$script:CliVersionFile = Join-Path (Join-Path $env:USERPROFILE '.dreamina_cli') 'version.json'
$script:CliCredentialFile = Join-Path (Join-Path $env:USERPROFILE '.dreamina_cli') 'credential.json'
$script:SkipDirectoryNames = @('done', 'tmp', 'state', 'logs', '_dreamina_tmp')
$script:ImageExtensions = @('.png', '.jpg', '.jpeg', '.webp')
$script:State = @{}
$script:LogFile = $null
$script:MotherRoot = $null
$script:Config = $null

function Get-DefaultConfigObject {
    return @{
        input_path = 'D:\DreaminaTasks'
        poll_interval_seconds = 600
        max_poll_hours = 12
        model_version = 'seedance2.0fast'
        duration = 5
        ratio = ''
        video_resolution = ''
        login_timeout_minutes = 10
        task_time = '23:00'
        log_retention_days = 30
    }
}

function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR')][string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[{0}] [{1}] {2}" -f $timestamp, $Level, $Message
    Write-Host $line
    if ($script:LogFile) {
        Add-Content -LiteralPath $script:LogFile -Value $line -Encoding UTF8
    }
}

function Ensure-Directory {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Test-WriteAccess {
    param([Parameter(Mandatory = $true)][string]$Path)

    Ensure-Directory -Path $Path
    $probe = Join-Path $Path ("write-test-{0}.tmp" -f ([guid]::NewGuid().ToString('N')))
    try {
        Set-Content -LiteralPath $probe -Value 'ok' -Encoding ASCII
        Remove-Item -LiteralPath $probe -Force
        return $true
    } catch {
        return $false
    }
}

function ConvertTo-Hashtable {
    param([Parameter(ValueFromPipeline = $true)]$InputObject)

    if ($null -eq $InputObject) {
        return $null
    }

    if ($InputObject -is [System.Collections.IDictionary]) {
        $hash = @{}
        foreach ($key in $InputObject.Keys) {
            $hash[$key] = ConvertTo-Hashtable -InputObject $InputObject[$key]
        }
        return $hash
    }

    if (($InputObject -is [System.Collections.IEnumerable]) -and -not ($InputObject -is [string])) {
        $items = @()
        foreach ($item in $InputObject) {
            $items += ,(ConvertTo-Hashtable -InputObject $item)
        }
        return $items
    }

    if ($InputObject -is [pscustomobject]) {
        $hash = @{}
        foreach ($property in $InputObject.PSObject.Properties) {
            $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
        }
        return $hash
    }

    return $InputObject
}

function Read-JsonFile {
    param([Parameter(Mandatory = $true)][string]$Path)

    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return @{}
    }
    return ConvertTo-Hashtable -InputObject (ConvertFrom-Json -InputObject $raw)
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Data
    )

    $json = $Data | ConvertTo-Json -Depth 10
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Resolve-ExistingPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    return (Resolve-Path -LiteralPath $Path).Path
}

function Get-VersionObject {
    param([string]$VersionString)

    if ([string]::IsNullOrWhiteSpace($VersionString)) {
        return [Version]'0.0.0'
    }

    $parts = $VersionString.Split('.')
    while ($parts.Count -lt 3) {
        $parts += '0'
    }
    $normalized = ($parts[0..2] -join '.')
    try {
        return [Version]$normalized
    } catch {
        return [Version]'0.0.0'
    }
}

function Load-Config {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Config file not found: $Path"
    }

    $config = Read-JsonFile -Path $Path
    $required = @(
        'input_path',
        'poll_interval_seconds',
        'max_poll_hours',
        'model_version',
        'duration',
        'ratio',
        'video_resolution',
        'login_timeout_minutes',
        'task_time',
        'log_retention_days'
    )

    foreach ($key in $required) {
        if (-not $config.ContainsKey($key)) {
            throw "Missing config key: $key"
        }
    }

    if ($InputPath) {
        $config['input_path'] = $InputPath
    }

    return $config
}

function Initialize-Logging {
    param([Parameter(Mandatory = $true)][string]$MotherRoot)

    $logsDir = Join-Path (Join-Path $MotherRoot 'tmp') 'logs'
    Ensure-Directory -Path $logsDir
    $script:LogFile = Join-Path $logsDir ("{0}.log" -f (Get-Date -Format 'yyyy-MM-dd'))
    if (-not (Test-Path -LiteralPath $script:LogFile)) {
        New-Item -ItemType File -Path $script:LogFile | Out-Null
    }
}

function Cleanup-OldLogs {
    param(
        [Parameter(Mandatory = $true)][string]$MotherRoot,
        [Parameter(Mandatory = $true)][int]$RetentionDays
    )

    $logsDir = Join-Path (Join-Path $MotherRoot 'tmp') 'logs'
    if (-not (Test-Path -LiteralPath $logsDir)) {
        return
    }

    $cutoff = (Get-Date).AddDays(-1 * $RetentionDays)
    Get-ChildItem -LiteralPath $logsDir -File -Filter '*.log' |
        Where-Object { $_.LastWriteTime -lt $cutoff } |
        ForEach-Object {
            Remove-Item -LiteralPath $_.FullName -Force
        }
}

function Get-MotherRoot {
    param([Parameter(Mandatory = $true)][string]$InputRoot)

    $resolved = Resolve-ExistingPath -Path $InputRoot
    if (-not (Test-Path -LiteralPath $resolved -PathType Container)) {
        throw "Input path must be a directory: $resolved"
    }

    if (Test-IsTaskDirectory -DirectoryPath $resolved) {
        return Split-Path -Path $resolved -Parent
    }

    return $resolved
}

function Extract-JsonText {
    param([Parameter(Mandatory = $true)][string]$Text)

    $trimmed = $Text.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed)) {
        return $null
    }

    $objectStart = $trimmed.IndexOf('{')
    $arrayStart = $trimmed.IndexOf('[')
    $startIndexes = @(@($objectStart, $arrayStart) | Where-Object { $_ -ge 0 } | Sort-Object)
    if ($startIndexes.Count -eq 0) {
        return $null
    }

    return $trimmed.Substring($startIndexes[0])
}

function ConvertFrom-MixedJson {
    param([AllowNull()][string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $null
    }

    $json = Extract-JsonText -Text $Text
    if (-not $json) {
        return $null
    }

    try {
        return ConvertTo-Hashtable -InputObject (ConvertFrom-Json -InputObject $json)
    } catch {
        return $null
    }
}

function Invoke-CommandCapture {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @(),
        [switch]$IgnoreExitCode
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & $FilePath @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($null -eq $exitCode) {
        $exitCode = if ($?) { 0 } else { 1 }
    }
    $lines = @()
    foreach ($item in $output) {
        $lines += $item.ToString()
    }
    $text = [string]::Join([Environment]::NewLine, $lines)

    if (-not $IgnoreExitCode -and $exitCode -ne 0) {
        throw "Command failed ($exitCode): $FilePath $($Arguments -join ' ')`n$text"
    }

    return @{
        exit_code = $exitCode
        output = $text
        json = ConvertFrom-MixedJson -Text $text
    }
}

function Invoke-DownloadFile {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$DestinationPath
    )

    Invoke-WebRequest -Uri $Url -OutFile $DestinationPath -UseBasicParsing
}

function Get-RemoteCliVersionInfo {
    $tempFile = Join-Path ([IO.Path]::GetTempPath()) ("dreamina-version-{0}.json" -f ([guid]::NewGuid().ToString('N')))
    try {
        Invoke-DownloadFile -Url $script:VersionUrl -DestinationPath $tempFile
        return Read-JsonFile -Path $tempFile
    } finally {
        if (Test-Path -LiteralPath $tempFile) {
            Remove-Item -LiteralPath $tempFile -Force
        }
    }
}

function Get-LocalCliVersionInfo {
    if (Test-Path -LiteralPath $script:CliVersionFile) {
        return Read-JsonFile -Path $script:CliVersionFile
    }

    return @{
        version = '0.0.0'
    }
}

function Ensure-PathContainsCli {
    $currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $currentEntries = @()
    if ($currentPath) {
        $currentEntries = $currentPath.Split(';') | Where-Object { $_ }
    }

    if ($currentEntries -notcontains $script:CliInstallDir) {
        $newPath = @($currentEntries + $script:CliInstallDir) | Where-Object { $_ } | Select-Object -Unique
        try {
            [Environment]::SetEnvironmentVariable('Path', ($newPath -join ';'), 'User')
            Write-Log -Message "Added CLI directory to user PATH: $script:CliInstallDir"
        } catch {
            Write-Log -Message ("Could not update user PATH, continuing with absolute CLI path: {0}" -f $_.Exception.Message) -Level 'WARN'
        }
    }

    $processEntries = $env:Path.Split(';') | Where-Object { $_ }
    if ($processEntries -notcontains $script:CliInstallDir) {
        $env:Path = $env:Path.TrimEnd(';') + ';' + $script:CliInstallDir
    }
}

function Install-OrUpdateCli {
    param(
        [Parameter(Mandatory = $true)]$RemoteVersionInfo,
        [switch]$ForceInstall
    )

    Ensure-Directory -Path $script:CliInstallDir
    Ensure-Directory -Path (Split-Path -Path $script:CliVersionFile -Parent)
    if (-not (Test-WriteAccess -Path $script:CliInstallDir)) {
        throw "Cannot write to CLI install directory: $script:CliInstallDir"
    }

    $tempExe = Join-Path ([IO.Path]::GetTempPath()) ("dreamina-{0}.exe" -f ([guid]::NewGuid().ToString('N')))
    $tempVersion = Join-Path ([IO.Path]::GetTempPath()) ("dreamina-version-{0}.json" -f ([guid]::NewGuid().ToString('N')))

    try {
        Invoke-DownloadFile -Url $script:BinaryUrl -DestinationPath $tempExe
        Invoke-DownloadFile -Url $script:VersionUrl -DestinationPath $tempVersion
        Move-Item -LiteralPath $tempExe -Destination $script:CliPath -Force
        Move-Item -LiteralPath $tempVersion -Destination $script:CliVersionFile -Force
        Ensure-PathContainsCli
        if ($ForceInstall) {
            Write-Log -Message ("Installed dreamina CLI version {0}" -f $RemoteVersionInfo.version)
        } else {
            Write-Log -Message ("Updated dreamina CLI to version {0}" -f $RemoteVersionInfo.version)
        }
    } finally {
        foreach ($temp in @($tempExe, $tempVersion)) {
            if (Test-Path -LiteralPath $temp) {
                Remove-Item -LiteralPath $temp -Force
            }
        }
    }
}

function Ensure-DreaminaCli {
    Write-Log -Message 'Checking Dreamina CLI dependency'

    $remoteInfo = $null
    try {
        $remoteInfo = Get-RemoteCliVersionInfo
        Write-Log -Message ("Fetched remote CLI version {0}" -f $remoteInfo.version)
    } catch {
        if (Test-Path -LiteralPath $script:CliPath) {
            Write-Log -Message ("Remote version check failed, using existing CLI: {0}" -f $_.Exception.Message) -Level 'WARN'
            Ensure-PathContainsCli
            return
        }

        throw "Failed to fetch remote CLI version and no local CLI exists. $($_.Exception.Message)"
    }

    if (-not (Test-Path -LiteralPath $script:CliPath)) {
        Install-OrUpdateCli -RemoteVersionInfo $remoteInfo -ForceInstall
        return
    }

    Ensure-PathContainsCli

    $localInfo = Get-LocalCliVersionInfo
    $localVersion = Get-VersionObject -VersionString $localInfo.version
    $remoteVersion = Get-VersionObject -VersionString $remoteInfo.version

    if ($remoteVersion -gt $localVersion) {
        try {
            Install-OrUpdateCli -RemoteVersionInfo $remoteInfo
        } catch {
            Write-Log -Message ("CLI update failed, keeping current binary: {0}" -f $_.Exception.Message) -Level 'WARN'
        }
    } else {
        Write-Log -Message ("Dreamina CLI is up to date ({0})" -f $localInfo.version)
    }
}

function Get-CliStatusInfo {
    $installed = Test-Path -LiteralPath $script:CliPath
    $localVersion = ''
    $remoteVersion = ''
    $updateAvailable = $false
    $loginValid = $false
    $remoteError = ''

    if ($installed) {
        $localInfo = Get-LocalCliVersionInfo
        if ($localInfo.ContainsKey('version')) {
            $localVersion = [string]$localInfo.version
        }
        try {
            $creditResult = Invoke-CommandCapture -FilePath $script:CliPath -Arguments @('user_credit') -IgnoreExitCode
            $loginValid = ($creditResult.exit_code -eq 0 -and $creditResult.json)
        } catch {
            $loginValid = $false
        }
    }

    try {
        $remoteInfo = Get-RemoteCliVersionInfo
        if ($remoteInfo.ContainsKey('version')) {
            $remoteVersion = [string]$remoteInfo.version
        }
        if ($installed -and $localVersion) {
            $updateAvailable = (Get-VersionObject -VersionString $remoteVersion) -gt (Get-VersionObject -VersionString $localVersion)
        }
    } catch {
        $remoteError = $_.Exception.Message
    }

    return @{
        cli_installed = $installed
        cli_path = $script:CliPath
        local_version = $localVersion
        remote_version = $remoteVersion
        update_available = $updateAvailable
        login_valid = $loginValid
        remote_error = $remoteError
    }
}

function Ensure-Login {
    param([Parameter(Mandatory = $true)][int]$TimeoutMinutes)

    Write-Log -Message 'Checking Dreamina login state'
    $result = Invoke-CommandCapture -FilePath $script:CliPath -Arguments @('user_credit') -IgnoreExitCode
    if ($result.exit_code -eq 0 -and $result.json) {
        Write-Log -Message 'Dreamina login is valid'
        return
    }

    Write-Log -Message 'Dreamina login missing or expired, starting login flow' -Level 'WARN'
    $process = Start-Process -FilePath $script:CliPath -ArgumentList @('login') -PassThru
    $timedOut = $false
    try {
        if (-not $process.WaitForExit($TimeoutMinutes * 60 * 1000)) {
            $timedOut = $true
            Stop-Process -Id $process.Id -Force
            throw "Dreamina login timed out after $TimeoutMinutes minutes."
        }
    } finally {
        if ($timedOut) {
            Write-Log -Message ("Dreamina login timed out after {0} minutes" -f $TimeoutMinutes) -Level 'ERROR'
        }
    }

    $exitCode = $process.ExitCode
    if ($null -ne $exitCode -and $exitCode -ne 0) {
        throw "Dreamina login failed with exit code $($process.ExitCode)."
    }

    $verify = Invoke-CommandCapture -FilePath $script:CliPath -Arguments @('user_credit') -IgnoreExitCode
    if ($verify.exit_code -ne 0 -or -not $verify.json) {
        throw 'Dreamina login did not produce a valid session.'
    }

    Write-Log -Message 'Dreamina login completed successfully'
}

function Test-IsTaskDirectory {
    param([Parameter(Mandatory = $true)][string]$DirectoryPath)

    if (-not (Test-Path -LiteralPath $DirectoryPath -PathType Container)) {
        return $false
    }

    $txtFiles = @(Get-ChildItem -LiteralPath $DirectoryPath -File | Where-Object { $_.Extension -ieq '.txt' })
    $imageFiles = @(Get-ChildItem -LiteralPath $DirectoryPath -File | Where-Object { $script:ImageExtensions -icontains $_.Extension })
    return ($txtFiles.Count -eq 1 -and $imageFiles.Count -ge 1)
}

function Get-TaskFiles {
    param([Parameter(Mandatory = $true)][string]$DirectoryPath)

    $txtFile = Get-ChildItem -LiteralPath $DirectoryPath -File | Where-Object { $_.Extension -ieq '.txt' } | Select-Object -First 1
    $imageFiles = Get-ChildItem -LiteralPath $DirectoryPath -File |
        Where-Object { $script:ImageExtensions -icontains $_.Extension } |
        Sort-Object -Property Name

    return @{
        prompt = $txtFile
        images = @($imageFiles)
    }
}

function Get-LeafTaskDirectories {
    param([Parameter(Mandatory = $true)][string]$DirectoryPath)

    $childLeafs = @()
    $children = Get-ChildItem -LiteralPath $DirectoryPath -Directory | Where-Object {
        $script:SkipDirectoryNames -inotcontains $_.Name
    }

    foreach ($child in $children) {
        $childLeafs += Get-LeafTaskDirectories -DirectoryPath $child.FullName
    }

    if ((Test-IsTaskDirectory -DirectoryPath $DirectoryPath) -and $childLeafs.Count -eq 0) {
        return @((Resolve-ExistingPath -Path $DirectoryPath))
    }

    return $childLeafs
}

function Get-TaskDirectories {
    param([Parameter(Mandatory = $true)][string]$InputRoot)

    $resolved = Resolve-ExistingPath -Path $InputRoot
    if (Test-IsTaskDirectory -DirectoryPath $resolved) {
        return @($resolved)
    }

    return @(Get-LeafTaskDirectories -DirectoryPath $resolved | Sort-Object -Unique)
}

function Get-ScanPreview {
    param(
        [Parameter(Mandatory = $true)][string]$InputRoot,
        [Parameter(Mandatory = $true)][string]$MotherRoot
    )

    $taskDirectories = @(Get-TaskDirectories -InputRoot $InputRoot)
    $tasks = @()
    foreach ($taskDirectory in $taskDirectories) {
        $taskFiles = Get-TaskFiles -DirectoryPath $taskDirectory
        $tasks += @{
            task_dir = $taskDirectory
            task_name = Split-Path -Path $taskDirectory -Leaf
            prompt_file = $taskFiles.prompt.FullName
            image_count = @($taskFiles.images).Count
        }
    }

    return @{
        input_path = $InputRoot
        mother_root = $MotherRoot
        task_count = $tasks.Count
        tasks = $tasks
    }
}

function Get-GenerationParams {
    return @{
        model_version = [string]$script:Config.model_version
        duration = [int]$script:Config.duration
        ratio = [string]$script:Config.ratio
        video_resolution = [string]$script:Config.video_resolution
    }
}

function Get-TaskFingerprint {
    param(
        [Parameter(Mandatory = $true)][string]$TaskDirectory,
        [Parameter(Mandatory = $true)]$TaskFiles
    )

    $segments = @()
    $promptPath = Resolve-ExistingPath -Path $TaskFiles.prompt.FullName
    $promptHash = (Get-FileHash -LiteralPath $promptPath -Algorithm SHA256).Hash
    $segments += "prompt|$promptPath|$promptHash"

    foreach ($image in $TaskFiles.images) {
        $imagePath = Resolve-ExistingPath -Path $image.FullName
        $imageHash = (Get-FileHash -LiteralPath $imagePath -Algorithm SHA256).Hash
        $segments += "image|$imagePath|$imageHash"
    }

    $generationParams = Get-GenerationParams
    foreach ($key in @('model_version', 'duration', 'ratio', 'video_resolution')) {
        $segments += "param|$key|$($generationParams[$key])"
    }

    $joined = [string]::Join("`n", $segments)
    $bytes = [Text.Encoding]::UTF8.GetBytes($joined)
    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        $hashBytes = $sha.ComputeHash($bytes)
    } finally {
        $sha.Dispose()
    }

    $hashString = [BitConverter]::ToString($hashBytes).Replace('-', '').ToLowerInvariant()
    return @{
        fingerprint = $hashString
        prompt_path = $promptPath
        image_paths = @($TaskFiles.images | ForEach-Object { Resolve-ExistingPath -Path $_.FullName })
        generation_params = $generationParams
    }
}

function Get-StatePaths {
    param([Parameter(Mandatory = $true)][string]$MotherRoot)

    $stateDir = Join-Path (Join-Path $MotherRoot 'tmp') 'state'
    Ensure-Directory -Path $stateDir
    return @{
        state_dir = $stateDir
        state_file = Join-Path $stateDir 'tasks.json'
        legacy_state_file = Join-Path (Join-Path $MotherRoot 'state') 'tasks.json'
    }
}

function Load-State {
    param([Parameter(Mandatory = $true)][string]$MotherRoot)

    $paths = Get-StatePaths -MotherRoot $MotherRoot
    if (-not (Test-Path -LiteralPath $paths.state_file) -and (Test-Path -LiteralPath $paths.legacy_state_file)) {
        Copy-Item -LiteralPath $paths.legacy_state_file -Destination $paths.state_file -Force
    }
    if (-not (Test-Path -LiteralPath $paths.state_file)) {
        return @{}
    }

    return Read-JsonFile -Path $paths.state_file
}

function Save-State {
    param([Parameter(Mandatory = $true)][string]$MotherRoot)

    $paths = Get-StatePaths -MotherRoot $MotherRoot
    Write-JsonFile -Path $paths.state_file -Data $script:State
}

function New-StateRecord {
    param(
        [Parameter(Mandatory = $true)][string]$TaskDirectory,
        [Parameter(Mandatory = $true)]$TaskFiles,
        [Parameter(Mandatory = $true)]$FingerprintInfo,
        [Parameter(Mandatory = $true)][string]$MotherRoot
    )

    return @{
        task_dir = $TaskDirectory
        parent_dir = $MotherRoot
        prompt_file = $FingerprintInfo.prompt_path
        image_files = $FingerprintInfo.image_paths
        generation_params = $FingerprintInfo.generation_params
        fingerprint = $FingerprintInfo.fingerprint
        status = 'pending'
        submit_id = ''
        attempt_count = 0
        retry_count = 0
        last_submit_time = ''
        last_query_time = ''
        fail_reason = ''
        downloaded_files = @()
    }
}

function Invoke-DreaminaJson {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)

    $result = Invoke-CommandCapture -FilePath $script:CliPath -Arguments $Arguments -IgnoreExitCode
    if ($result.exit_code -ne 0) {
        throw "Dreamina command failed: dreamina $($Arguments -join ' ')`n$result.output"
    }
    if (-not $result.json) {
        throw "Dreamina command did not return JSON: dreamina $($Arguments -join ' ')`n$result.output"
    }
    return $result.json
}

function Submit-Task {
    param(
        [Parameter(Mandatory = $true)][string]$TaskDirectory,
        [Parameter(Mandatory = $true)]$Record,
        [Parameter(Mandatory = $true)]$TaskFiles
    )

    $promptText = Get-Content -LiteralPath $TaskFiles.prompt.FullName -Raw -Encoding UTF8
    $arguments = @('multimodal2video')
    foreach ($image in $TaskFiles.images) {
        $arguments += @('--image', $image.FullName)
    }
    $arguments += @('--prompt', $promptText)
    $arguments += @('--duration', [string]$script:Config.duration)
    $arguments += @('--model_version', [string]$script:Config.model_version)
    if (-not [string]::IsNullOrWhiteSpace([string]$script:Config.ratio)) {
        $arguments += @('--ratio', [string]$script:Config.ratio)
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$script:Config.video_resolution)) {
        $arguments += @('--video_resolution', [string]$script:Config.video_resolution)
    }
    $arguments += @('--poll', '0')

    $Record.attempt_count = [int]$Record.attempt_count + 1
    $Record.last_submit_time = (Get-Date).ToString('s')
    Write-Log -Message ("Submitting task: {0}" -f $TaskDirectory)
    Write-Log -Message ("Generation settings: model={0}, duration={1}, ratio={2}, resolution={3}" -f $script:Config.model_version, $script:Config.duration, $script:Config.ratio, $script:Config.video_resolution)

    $response = Invoke-DreaminaJson -Arguments $arguments
    if (-not $response.ContainsKey('submit_id') -or [string]::IsNullOrWhiteSpace([string]$response.submit_id)) {
        throw 'Dreamina submit response missing submit_id.'
    }

    $Record.submit_id = [string]$response.submit_id
    $Record.status = if ($response.ContainsKey('gen_status')) { [string]$response.gen_status } else { 'submitted' }
    if ([string]::IsNullOrWhiteSpace($Record.status)) {
        $Record.status = 'submitted'
    }
    $Record.fail_reason = ''
    Write-Log -Message ("Task submitted: {0} -> {1}" -f $TaskDirectory, $Record.submit_id)
}

function Invoke-SubmitWithRetry {
    param(
        [Parameter(Mandatory = $true)][string]$TaskDirectory,
        [Parameter(Mandatory = $true)]$Record,
        [Parameter(Mandatory = $true)]$TaskFiles
    )

    try {
        Submit-Task -TaskDirectory $TaskDirectory -Record $Record -TaskFiles $TaskFiles
        return
    } catch {
        Write-Log -Message ("Task submit failed: {0}" -f $_.Exception.Message) -Level 'WARN'
        if ([int]$Record.retry_count -ge 1) {
            $Record.status = 'fail'
            $Record.fail_reason = $_.Exception.Message
            throw
        }
    }

    $Record.retry_count = [int]$Record.retry_count + 1
    Write-Log -Message ("Retrying task submission once: {0}" -f $TaskDirectory) -Level 'WARN'
    try {
        Submit-Task -TaskDirectory $TaskDirectory -Record $Record -TaskFiles $TaskFiles
    } catch {
        $Record.status = 'fail'
        $Record.fail_reason = $_.Exception.Message
        throw
    }
}

function Get-UniqueDestinationPath {
    param(
        [Parameter(Mandatory = $true)][string]$DestinationDirectory,
        [Parameter(Mandatory = $true)][string]$BaseName,
        [Parameter(Mandatory = $true)][string]$Extension,
        [Parameter(Mandatory = $true)][string]$SubmitId
    )

    $candidate = Join-Path $DestinationDirectory ($BaseName + $Extension)
    if (-not (Test-Path -LiteralPath $candidate)) {
        return $candidate
    }

    $candidate = Join-Path $DestinationDirectory ("{0}-{1}{2}" -f $BaseName, $SubmitId, $Extension)
    if (-not (Test-Path -LiteralPath $candidate)) {
        return $candidate
    }

    $index = 2
    while ($true) {
        $candidate = Join-Path $DestinationDirectory ("{0}-{1}-{2}{3}" -f $BaseName, $SubmitId, $index, $Extension)
        if (-not (Test-Path -LiteralPath $candidate)) {
            return $candidate
        }
        $index += 1
    }
}

function Download-TaskResult {
    param(
        [Parameter(Mandatory = $true)][string]$TaskDirectory,
        [Parameter(Mandatory = $true)]$Record,
        [Parameter(Mandatory = $true)][string]$MotherRoot
    )

    $tempRoot = Join-Path (Join-Path $MotherRoot 'tmp') '_dreamina_tmp'
    Ensure-Directory -Path $tempRoot
    $downloadDir = Join-Path $tempRoot $Record.submit_id
    Ensure-Directory -Path $downloadDir

    $response = Invoke-DreaminaJson -Arguments @('query_result', "--submit_id=$($Record.submit_id)", "--download_dir=$downloadDir")
    if (-not $response.ContainsKey('result_json')) {
        throw 'Dreamina query_result response missing result_json.'
    }

    $videos = @()
    if ($response.result_json.ContainsKey('videos')) {
        $videos = @($response.result_json.videos)
    }
    if ($videos.Count -eq 0) {
        throw 'Dreamina query_result returned no videos for a successful task.'
    }

    $dateDir = Join-Path (Join-Path $MotherRoot 'done') (Get-Date -Format 'yyyy-MM-dd')
    $taskDoneDir = Join-Path $dateDir (Split-Path -Path $TaskDirectory -Leaf)
    Ensure-Directory -Path $taskDoneDir

    $downloaded = @()
    $index = 1
    foreach ($video in $videos) {
        $sourcePath = [string]$video.path
        if (-not (Test-Path -LiteralPath $sourcePath)) {
            throw "Downloaded video not found: $sourcePath"
        }

        $extension = [IO.Path]::GetExtension($sourcePath)
        if ([string]::IsNullOrWhiteSpace($extension)) {
            $extension = '.mp4'
        }
        $baseName = "{0}_video_{1}" -f (Split-Path -Path $TaskDirectory -Leaf), $index
        $destination = Get-UniqueDestinationPath -DestinationDirectory $taskDoneDir -BaseName $baseName -Extension $extension -SubmitId $Record.submit_id
        Move-Item -LiteralPath $sourcePath -Destination $destination -Force
        $downloaded += $destination
        $index += 1
    }

    $Record.downloaded_files = $downloaded
    Write-Log -Message ("Downloaded {0} video(s) for task {1}" -f $downloaded.Count, $TaskDirectory)
}

function Query-TaskStatus {
    param([Parameter(Mandatory = $true)]$Record)

    $response = Invoke-DreaminaJson -Arguments @('query_result', "--submit_id=$($Record.submit_id)")
    if ($response.ContainsKey('gen_status')) {
        $Record.status = [string]$response.gen_status
    }
    if ($response.ContainsKey('fail_reason')) {
        $Record.fail_reason = [string]$response.fail_reason
    }
    $Record.last_query_time = (Get-Date).ToString('s')
    return $response
}

function Reset-RecordForFingerprintChange {
    param(
        [Parameter(Mandatory = $true)]$Record,
        [Parameter(Mandatory = $true)]$FingerprintInfo
    )

    $Record.prompt_file = $FingerprintInfo.prompt_path
    $Record.image_files = $FingerprintInfo.image_paths
    $Record.generation_params = $FingerprintInfo.generation_params
    $Record.fingerprint = $FingerprintInfo.fingerprint
    $Record.status = 'pending'
    $Record.submit_id = ''
    $Record.attempt_count = 0
    $Record.retry_count = 0
    $Record.last_submit_time = ''
    $Record.last_query_time = ''
    $Record.fail_reason = ''
    $Record.downloaded_files = @()
}

function Get-OrCreateRecord {
    param(
        [Parameter(Mandatory = $true)][string]$TaskDirectory,
        [Parameter(Mandatory = $true)]$TaskFiles,
        [Parameter(Mandatory = $true)]$FingerprintInfo,
        [Parameter(Mandatory = $true)][string]$MotherRoot
    )

    if (-not $script:State.ContainsKey($TaskDirectory)) {
        $script:State[$TaskDirectory] = New-StateRecord -TaskDirectory $TaskDirectory -TaskFiles $TaskFiles -FingerprintInfo $FingerprintInfo -MotherRoot $MotherRoot
        return $script:State[$TaskDirectory]
    }

    $record = $script:State[$TaskDirectory]
    if ([string]$record.fingerprint -ne [string]$FingerprintInfo.fingerprint) {
        Write-Log -Message ("Task input or generation settings changed, resetting state: {0}" -f $TaskDirectory)
        Reset-RecordForFingerprintChange -Record $record -FingerprintInfo $FingerprintInfo
    }

    return $record
}

function Process-Task {
    param(
        [Parameter(Mandatory = $true)][string]$TaskDirectory,
        [Parameter(Mandatory = $true)][string]$MotherRoot
    )

    $taskFiles = Get-TaskFiles -DirectoryPath $TaskDirectory
    $fingerprintInfo = Get-TaskFingerprint -TaskDirectory $TaskDirectory -TaskFiles $taskFiles
    $record = Get-OrCreateRecord -TaskDirectory $TaskDirectory -TaskFiles $taskFiles -FingerprintInfo $fingerprintInfo -MotherRoot $MotherRoot

    if ([string]$record.status -eq 'success') {
        Write-Log -Message ("Skipping successful task: {0}" -f $TaskDirectory)
        return
    }

    if ([string]$record.status -eq 'fail' -and [string]$record.fingerprint -eq [string]$fingerprintInfo.fingerprint) {
        Write-Log -Message ("Skipping failed task without content change: {0}" -f $TaskDirectory)
        return
    }

    if ([string]::IsNullOrWhiteSpace([string]$record.submit_id) -or [string]$record.status -eq 'pending') {
        Invoke-SubmitWithRetry -TaskDirectory $TaskDirectory -Record $record -TaskFiles $taskFiles
        if ([string]$record.status -eq 'success' -and @($record.downloaded_files).Count -eq 0) {
            Download-TaskResult -TaskDirectory $TaskDirectory -Record $record -MotherRoot $MotherRoot
        }
        Save-State -MotherRoot $MotherRoot
    } else {
        Write-Log -Message ("Resuming existing task {0} ({1})" -f $TaskDirectory, $record.submit_id)
    }
}

function Process-QueryLoop {
    param(
        [Parameter(Mandatory = $true)][string]$MotherRoot,
        [Parameter(Mandatory = $true)][datetime]$Deadline
    )

    while ($true) {
        $activeTasks = @($script:State.GetEnumerator() | Where-Object {
            (
                @('submitted', 'querying') -contains [string]$_.Value.status -or
                (
                    [string]$_.Value.status -eq 'success' -and
                    @($_.Value.downloaded_files).Count -eq 0
                )
            ) -and -not [string]::IsNullOrWhiteSpace([string]$_.Value.submit_id)
        })

        if ($activeTasks.Count -eq 0) {
            Write-Log -Message 'No active tasks left to poll'
            return
        }

        foreach ($entry in $activeTasks) {
            $taskDirectory = [string]$entry.Key
            $record = $entry.Value
            Write-Log -Message ("Polling task {0} ({1})" -f $taskDirectory, $record.submit_id)

            try {
                $response = Query-TaskStatus -Record $record
                $status = [string]$record.status
                Write-Log -Message ("Task status: {0} -> {1}" -f $taskDirectory, $status)

                if ($status -eq 'success') {
                    Download-TaskResult -TaskDirectory $taskDirectory -Record $record -MotherRoot $MotherRoot
                } elseif ($status -eq 'fail') {
                    if ([int]$record.retry_count -lt 1) {
                        Write-Log -Message ("Task failed once, retrying submit: {0}" -f $taskDirectory) -Level 'WARN'
                        $taskFiles = Get-TaskFiles -DirectoryPath $taskDirectory
                        $record.retry_count = [int]$record.retry_count + 1
                        Submit-Task -TaskDirectory $taskDirectory -Record $record -TaskFiles $taskFiles
                    } else {
                        Write-Log -Message ("Task failed permanently: {0} - {1}" -f $taskDirectory, $record.fail_reason) -Level 'ERROR'
                    }
                } else {
                    $record.status = 'querying'
                }
            } catch {
                $record.fail_reason = $_.Exception.Message
                Write-Log -Message ("Polling error for task {0}: {1}" -f $taskDirectory, $_.Exception.Message) -Level 'WARN'
            }

            Save-State -MotherRoot $MotherRoot
        }

        if ((Get-Date) -ge $Deadline) {
            Write-Log -Message 'Polling deadline reached, remaining tasks will continue on the next run' -Level 'WARN'
            return
        }

        Write-Log -Message ("Sleeping {0} seconds before next polling cycle" -f [int]$script:Config.poll_interval_seconds)
        Start-Sleep -Seconds ([int]$script:Config.poll_interval_seconds)
    }
}

function Validate-Environment {
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
        throw 'This script only supports Windows.'
    }

    if (-not $PSVersionTable.PSVersion) {
        throw 'PowerShell runtime not detected.'
    }
}

function Initialize-InputContext {
    param(
        [Parameter(Mandatory = $true)]$Config,
        [switch]$NoLogging
    )

    $inputRoot = Resolve-ExistingPath -Path $Config.input_path
    $script:MotherRoot = Get-MotherRoot -InputRoot $inputRoot
    if (-not $NoLogging) {
        Initialize-Logging -MotherRoot $script:MotherRoot
        Cleanup-OldLogs -MotherRoot $script:MotherRoot -RetentionDays ([int]$Config.log_retention_days)
        if (-not (Test-WriteAccess -Path $script:MotherRoot)) {
            throw "Cannot write to mother root: $script:MotherRoot"
        }
    }

    return @{
        input_root = $inputRoot
        mother_root = $script:MotherRoot
    }
}

function Write-JsonResult {
    param([Parameter(Mandatory = $true)]$Data)

    Write-Output ($Data | ConvertTo-Json -Depth 10)
}

function Main {
    Validate-Environment

    if ($CheckOnly) {
        Write-JsonResult -Data (Get-CliStatusInfo)
        return
    }

    if ($InstallOnly) {
        Ensure-DreaminaCli
        return
    }

    if ($LoginOnly) {
        $loginTimeout = [int](Get-DefaultConfigObject).login_timeout_minutes
        if (Test-Path -LiteralPath $ConfigPath) {
            try {
                $script:Config = Load-Config -Path $ConfigPath
                $loginTimeout = [int]$script:Config.login_timeout_minutes
            } catch {
                $script:Config = $null
            }
        }
        Ensure-DreaminaCli
        Ensure-Login -TimeoutMinutes $loginTimeout
        return
    }

    $script:Config = Load-Config -Path $ConfigPath
    if ($ScanOnly) {
        $context = Initialize-InputContext -Config $script:Config -NoLogging
        $inputRoot = [string]$context.input_root
        Write-JsonResult -Data (Get-ScanPreview -InputRoot $inputRoot -MotherRoot $script:MotherRoot)
        return
    }

    $context = Initialize-InputContext -Config $script:Config
    $inputRoot = [string]$context.input_root

    Write-Log -Message ("Starting Dreamina nightly run with input path: {0}" -f $inputRoot)
    if ($RunOnce) {
        Write-Log -Message 'RunOnce mode enabled'
    }

    Ensure-DreaminaCli
    Ensure-Login -TimeoutMinutes ([int]$script:Config.login_timeout_minutes)

    $script:State = Load-State -MotherRoot $script:MotherRoot
    $taskDirectories = @(Get-TaskDirectories -InputRoot $inputRoot)
    Write-Log -Message ("Discovered {0} task directory(s)" -f $taskDirectories.Count)

    foreach ($taskDirectory in $taskDirectories) {
        try {
            Process-Task -TaskDirectory $taskDirectory -MotherRoot $script:MotherRoot
        } catch {
            Write-Log -Message ("Task processing failed for {0}: {1}" -f $taskDirectory, $_.Exception.Message) -Level 'ERROR'
            if (-not $script:State.ContainsKey($taskDirectory)) {
                $script:State[$taskDirectory] = @{
                    task_dir = $taskDirectory
                    parent_dir = $script:MotherRoot
                    prompt_file = ''
                    image_files = @()
                    fingerprint = ''
                    status = 'fail'
                    submit_id = ''
                    attempt_count = 0
                    retry_count = 1
                    last_submit_time = ''
                    last_query_time = ''
                    fail_reason = $_.Exception.Message
                    downloaded_files = @()
                }
            } else {
                $script:State[$taskDirectory].status = 'fail'
                $script:State[$taskDirectory].fail_reason = $_.Exception.Message
            }
            Save-State -MotherRoot $script:MotherRoot
        }
    }

    $deadline = (Get-Date).AddHours([double]$script:Config.max_poll_hours)
    Process-QueryLoop -MotherRoot $script:MotherRoot -Deadline $deadline
    Save-State -MotherRoot $script:MotherRoot
    Write-Log -Message 'Dreamina nightly run completed'
}

try {
    Main
} catch {
    if (-not $script:LogFile -and $script:MotherRoot) {
        Initialize-Logging -MotherRoot $script:MotherRoot
    }
    Write-Log -Message $_.Exception.Message -Level 'ERROR'
    exit 1
}
