[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function U {
    param([Parameter(Mandatory = $true)][string]$Text)
    return [regex]::Unescape($Text)
}

$script:Text = @{
    app_title = U '\u0044\u0072\u0065\u0061\u006d\u0069\u006e\u0061\u0020\u542f\u52a8\u5668'
    app_title_short = U '\u0044\u0072\u0065\u0061\u006d\u0069\u006e\u0061\u0020\u6279\u5904\u7406\u63a7\u5236\u53f0'
    subtitle = U '\u5728\u4e00\u4e2a\u7a97\u53e3\u4e2d\u5b8c\u6210\u914d\u7f6e\u3001\u767b\u5f55\u3001\u626b\u63cf\u3001\u6267\u884c\u548c\u8ba1\u5212\u4efb\u52a1\u6ce8\u518c\u3002'
    missing_files = U '\u7f3a\u5c11\u5fc5\u9700\u6587\u4ef6'
    running = U '\u8fd0\u884c\u4e2d...'
    idle = U '\u7a7a\u95f2'
    read_config_failed = U '\u8bfb\u53d6\u914d\u7f6e\u5931\u8d25\uff0c\u6539\u7528\u9ed8\u8ba4\u503c'
    validation_title = U '\u914d\u7f6e\u6821\u9a8c\u5931\u8d25'
    input_required = U '\u8f93\u5165\u76ee\u5f55\u4e0d\u80fd\u4e3a\u7a7a\u3002'
    input_missing = U '\u8f93\u5165\u76ee\u5f55\u4e0d\u5b58\u5728\u3002'
    task_time_invalid = U '\u6267\u884c\u65f6\u95f4\u5fc5\u987b\u662f\u0020\u0048\u0048\u003a\u006d\u006d\u0020\u683c\u5f0f\u3002'
    model_required = U '\u6a21\u578b\u7248\u672c\u4e0d\u80fd\u4e3a\u7a7a\u3002'
    saved = U '\u914d\u7f6e\u5df2\u4fdd\u5b58'
    scheduler_unavailable = U '\u4e0d\u53ef\u7528'
    scheduler_registered = U '\u5df2\u6ce8\u518c'
    scheduler_missing = U '\u672a\u6ce8\u518c'
    scheduler_count_fmt = U '\u5df2\u6ce8\u518c\u0020{0}\u0020\u4e2a'
    cli_installed = U '\u5df2\u5b89\u88c5'
    cli_updatable = U '\u53ef\u66f4\u65b0'
    cli_missing = U '\u672a\u5b89\u88c5'
    unknown = U '\u672a\u77e5'
    remote_prefix = U '\u8fdc\u7aef'
    logged_in = U '\u5df2\u767b\u5f55'
    not_logged_in = U '\u672a\u767b\u5f55'
    task_count_fmt = U '\u8bc6\u522b\u5230\u0020{0}\u0020\u4e2a\u4efb\u52a1\u76ee\u5f55'
    busy_title = U '\u6b63\u5728\u8fd0\u884c'
    busy_message = U '\u5f53\u524d\u8fd8\u6709\u4efb\u52a1\u5728\u8fd0\u884c\uff0c\u8bf7\u7b49\u5f85\u5b8c\u6210\u540e\u518d\u64cd\u4f5c\u3002'
    script_missing = U '\u811a\u672c\u4e0d\u5b58\u5728'
    process_start = U '\u542f\u52a8'
    process_exit = U '\u9000\u51fa\u7801'
    process_failed = U '\u542f\u52a8\u8fdb\u7a0b\u5931\u8d25'
    background_failed = U '\u540e\u53f0\u4efb\u52a1\u5931\u8d25'
    env_check = U '\u73af\u5883\u68c0\u6d4b'
    check_failed = U '\u68c0\u6d4b\u5931\u8d25'
    remote_failed = U '\u8fdc\u7aef\u7248\u672c\u67e5\u8be2\u5931\u8d25'
    open_folder = U '\u6253\u5f00\u76ee\u5f55'
    path_missing = U '\u76ee\u5f55\u4e0d\u5b58\u5728'
    group_env = U '\u73af\u5883\u72b6\u6001'
    group_config = U '\u4efb\u52a1\u914d\u7f6e'
    group_run = U '\u8fd0\u884c\u4e0e\u7ed3\u679c'
    label_cli_status = U '\u0043\u004c\u0049\u0020\u72b6\u6001'
    label_cli_version = U '\u0043\u004c\u0049\u0020\u7248\u672c'
    label_login = U '\u767b\u5f55\u72b6\u6001'
    label_scheduler = U '\u8ba1\u5212\u4efb\u52a1'
    label_run_state = U '\u8fd0\u884c\u72b6\u6001'
    btn_detect = U '\u68c0\u6d4b\u73af\u5883'
    btn_install = U '\u5b89\u88c5\u002f\u66f4\u65b0\u0020\u0043\u004c\u0049'
    btn_login = U '\u767b\u5f55'
    label_input = U '\u8f93\u5165\u76ee\u5f55'
    btn_browse = U '\u9009\u62e9\u6587\u4ef6\u5939'
    field_task_time = U '\u6267\u884c\u65f6\u95f4'
    field_poll_seconds = U '\u8f6e\u8be2\u79d2\u6570'
    field_max_hours = U '\u6700\u957f\u8f6e\u8be2'
    field_model = U '\u6a21\u578b\u7248\u672c'
    field_duration = U '\u89c6\u9891\u65f6\u957f'
    field_ratio = U '\u753b\u5e45\u6bd4\u4f8b'
    field_resolution = U '\u5206\u8fa8\u7387'
    field_login_timeout = U '\u767b\u5f55\u8d85\u65f6'
    field_log_keep = U '\u65e5\u5fd7\u4fdd\u7559'
    btn_save = U '\u4fdd\u5b58\u914d\u7f6e'
    btn_reset = U '\u6062\u590d\u9ed8\u8ba4'
    btn_scan = U '\u626b\u63cf\u4efb\u52a1'
    btn_run = U '\u7acb\u5373\u6267\u884c'
    btn_register = U '\u6ce8\u518c\u8ba1\u5212\u4efb\u52a1'
    btn_unregister = U '\u53d6\u6d88\u9009\u4e2d'
    btn_unregister_all = U '\u53d6\u6d88\u5168\u90e8'
    btn_open_done = U '\u6253\u5f00\u6210\u7247\u76ee\u5f55'
    btn_open_logs = U '\u6253\u5f00\u65e5\u5fd7'
    task_not_loaded = U '\u5c1a\u672a\u626b\u63cf\u4efb\u52a1\u76ee\u5f55'
    col_task_name = U '\u4efb\u52a1\u540d'
    col_images = U '\u56fe\u7247\u6570'
    col_prompt = U '\u63d0\u793a\u8bcd\u6587\u4ef6'
    col_task_dir = U '\u4efb\u52a1\u76ee\u5f55'
    choose_input = U '\u9009\u62e9\u4efb\u52a1\u8f93\u5165\u76ee\u5f55'
    restored = U '\u8868\u5355\u5df2\u6062\u590d\u5230\u9ed8\u8ba4\u503c'
    install_run = U '\u5b89\u88c5\u6216\u66f4\u65b0\u0020\u0043\u004c\u0049'
    install_ok = U '\u0043\u004c\u0049\u0020\u5b89\u88c5\u6216\u66f4\u65b0\u5b8c\u6210'
    install_fail = U '\u0043\u004c\u0049\u0020\u5b89\u88c5\u6216\u66f4\u65b0\u5931\u8d25'
    login_run = U '\u5373\u68a6\u767b\u5f55'
    login_ok = U '\u767b\u5f55\u5b8c\u6210'
    login_fail = U '\u767b\u5f55\u5931\u8d25'
    scan_run = U '\u626b\u63cf\u4efb\u52a1'
    scan_fail = U '\u4efb\u52a1\u626b\u63cf\u5931\u8d25'
    scan_ok_fmt = U '\u626b\u63cf\u5b8c\u6210\uff0c\u5171\u0020{0}\u0020\u4e2a\u4efb\u52a1'
    run_run = U '\u7acb\u5373\u6267\u884c'
    run_ok = U '\u6267\u884c\u5b8c\u6210'
    run_fail = U '\u6267\u884c\u5931\u8d25'
    register_run = U '\u6ce8\u518c\u8ba1\u5212\u4efb\u52a1'
    register_ok = U '\u8ba1\u5212\u4efb\u52a1\u5df2\u6ce8\u518c'
    register_fail = U '\u8ba1\u5212\u4efb\u52a1\u6ce8\u518c\u5931\u8d25'
    unregister_run = U '\u53d6\u6d88\u8ba1\u5212\u4efb\u52a1'
    unregister_ok = U '\u8ba1\u5212\u4efb\u52a1\u5df2\u53d6\u6d88'
    unregister_fail = U '\u8ba1\u5212\u4efb\u52a1\u53d6\u6d88\u5931\u8d25'
    unregister_all_run = U '\u53d6\u6d88\u5168\u90e8\u8ba1\u5212\u4efb\u52a1'
    unregister_all_ok = U '\u5168\u90e8\u8ba1\u5212\u4efb\u52a1\u5df2\u53d6\u6d88'
    unregister_all_fail = U '\u5168\u90e8\u8ba1\u5212\u4efb\u52a1\u53d6\u6d88\u5931\u8d25'
    no_scheduler_selected = U '\u8bf7\u5148\u9009\u62e9\u8981\u53d6\u6d88\u7684\u8ba1\u5212\u4efb\u52a1\u3002'
    confirm_title = U '\u786e\u8ba4\u64cd\u4f5c'
    confirm_unregister_fmt = U '\u786e\u5b9a\u8981\u53d6\u6d88\u8ba1\u5212\u4efb\u52a1\u201c{0}\u201d\u5417\uff1f'
    confirm_unregister_all = U '\u786e\u5b9a\u8981\u53d6\u6d88\u5168\u90e8\u0020\u0044\u0072\u0065\u0061\u006d\u0069\u006e\u0061\u0020\u8ba1\u5212\u4efb\u52a1\u5417\uff1f'
    launcher_ready = U '\u542f\u52a8\u5668\u5df2\u5c31\u7eea'
    use_vbs = U '\u65e5\u5e38\u4f7f\u7528\u8bf7\u53cc\u51fb\u0020\u0044\u0072\u0065\u0061\u006d\u0069\u006e\u0061\u004c\u0061\u0075\u006e\u0063\u0068\u0065\u0072\u002e\u0065\u0078\u0065'
    use_bat = U '\u6392\u67e5\u95ee\u9898\u8bf7\u53cc\u51fb\u0020\u0053\u0074\u0061\u0072\u0074\u0020\u0044\u0072\u0065\u0061\u006d\u0069\u006e\u0061\u002e\u0062\u0061\u0074'
}

function Get-DefaultUiConfig {
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

function ConvertTo-Hashtable {
    param([Parameter(ValueFromPipeline = $true)]$InputObject)

    if ($null -eq $InputObject) { return $null }
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
    if ([string]::IsNullOrWhiteSpace($raw)) { return @{} }
    return ConvertTo-Hashtable -InputObject (ConvertFrom-Json -InputObject $raw)
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)]$Data
    )

    Set-Content -LiteralPath $Path -Value ($Data | ConvertTo-Json -Depth 10) -Encoding UTF8
}

function Quote-CommandArgument {
    param([Parameter(Mandatory = $true)][string]$Value)
    if ($Value -notmatch '[\s"]') { return $Value }
    return '"' + $Value.Replace('"', '""') + '"'
}

function ConvertTo-CommandLine {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)
    return (($Arguments | ForEach-Object { Quote-CommandArgument -Value $_ }) -join ' ')
}

function Quote-PowerShellLiteral {
    param([AllowNull()][string]$Value)
    if ($null -eq $Value) { return "''" }
    return "'" + $Value.Replace("'", "''") + "'"
}

function Extract-JsonText {
    param([Parameter(Mandatory = $true)][string]$Text)

    $trimmed = $Text.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed)) { return $null }

    $indexes = @()
    $objectIndex = $trimmed.IndexOf('{')
    $arrayIndex = $trimmed.IndexOf('[')
    if ($objectIndex -ge 0) { $indexes += $objectIndex }
    if ($arrayIndex -ge 0) { $indexes += $arrayIndex }
    if ($indexes.Count -eq 0) { return $null }
    return $trimmed.Substring(($indexes | Sort-Object | Select-Object -First 1))
}

function Read-LauncherTextFile {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return '' }
    try {
        $stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, ([IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete))
        try {
            if ($stream.Length -eq 0) { return '' }
            $bytes = New-Object byte[] $stream.Length
            [void]$stream.Read($bytes, 0, $bytes.Length)
        } finally {
            $stream.Dispose()
        }
    } catch [IO.IOException] {
        return $null
    } catch [UnauthorizedAccessException] {
        return $null
    }
    if ($bytes.Length -eq 0) { return '' }

    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        return [Text.Encoding]::Unicode.GetString($bytes)
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        return [Text.Encoding]::BigEndianUnicode.GetString($bytes)
    }
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return [Text.Encoding]::UTF8.GetString($bytes)
    }

    $sampleLength = [Math]::Min($bytes.Length, 64)
    $oddNulls = 0
    for ($i = 1; $i -lt $sampleLength; $i += 2) {
        if ($bytes[$i] -eq 0) { $oddNulls++ }
    }
    if ($oddNulls -ge [Math]::Max(2, [Math]::Floor($sampleLength / 8))) {
        return [Text.Encoding]::Unicode.GetString($bytes)
    }

    return [Text.Encoding]::UTF8.GetString($bytes)
}

function ConvertFrom-UiJsonText {
    param([Parameter(Mandatory = $true)][string]$Text)

    $trimmed = $Text.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed)) { return $null }

    $candidateIndexes = @()
    foreach ($match in [regex]::Matches($trimmed, '[\{\[]')) {
        $candidateIndexes += $match.Index
    }

    foreach ($index in ($candidateIndexes | Sort-Object -Unique)) {
        $candidate = $trimmed.Substring($index)
        try {
            return ConvertTo-Hashtable -InputObject (ConvertFrom-Json -InputObject $candidate)
        } catch {
        }
    }

    return $null
}

function Show-ErrorBox {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$Message
    )

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}

function Show-WarnBox {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$Message
    )

    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    ) | Out-Null
}

function Show-ConfirmBox {
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string]$Message
    )

    return ([System.Windows.Forms.MessageBox]::Show(
        $Message,
        $Title,
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    ) -eq [System.Windows.Forms.DialogResult]::Yes)
}

function Ensure-LauncherFiles {
    $missing = @()
    foreach ($path in @($script:NightlyScriptPath, $script:RegisterScriptPath)) {
        if (-not (Test-Path -LiteralPath $path)) {
            $missing += $path
        }
    }
    if ($missing.Count -gt 0) {
        throw ("{0}:`n{1}" -f $script:Text.missing_files, ($missing -join [Environment]::NewLine))
    }
    if (-not (Test-Path -LiteralPath $script:ConfigPath)) {
        Write-JsonFile -Path $script:ConfigPath -Data (Get-DefaultUiConfig)
    }
}

function Append-Log {
    param([Parameter(Mandatory = $true)][string]$Message)
    $timestamp = Get-Date -Format 'HH:mm:ss'
    $line = "[{0}] {1}" -f $timestamp, $Message
    $script:Controls.LogBox.AppendText($line + [Environment]::NewLine)
    $script:Controls.LogBox.SelectionStart = $script:Controls.LogBox.TextLength
    $script:Controls.LogBox.ScrollToCaret()
}

function Set-StatusLabel {
    param(
        [Parameter(Mandatory = $true)]$Label,
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][System.Drawing.Color]$Color
    )

    $Label.Text = $Text
    $Label.ForeColor = $Color
}

function Set-BusyState {
    param(
        [Parameter(Mandatory = $true)][bool]$Busy,
        [string]$Caption = '',
        [switch]$KeepUtilityButtonsEnabled
    )

    $script:IsBusy = $Busy
    foreach ($buttonName in @(
        'DetectButton', 'InstallButton', 'LoginButton', 'BrowseButton',
        'SaveButton', 'ResetButton', 'ScanButton', 'RunButton',
        'RegisterButton', 'UnregisterButton', 'UnregisterAllButton',
        'OpenDoneButton', 'OpenLogsButton'
    )) {
        if ($script:Controls.ContainsKey($buttonName)) {
            $script:Controls[$buttonName].Enabled = -not $Busy
        }
    }
    if ($Busy -and $KeepUtilityButtonsEnabled) {
        foreach ($buttonName in @('OpenDoneButton', 'OpenLogsButton')) {
            if ($script:Controls.ContainsKey($buttonName)) {
                $script:Controls[$buttonName].Enabled = $true
            }
        }
    }

    if ($Busy) {
        $script:Controls.Form.UseWaitCursor = $false
        [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::Default
        $script:Controls.RunStateValue.Text = if ($Caption) { $Caption } else { $script:Text.running }
        $script:Controls.RunStateValue.ForeColor = [System.Drawing.Color]::FromArgb(168, 95, 0)
    } else {
        $script:Controls.Form.UseWaitCursor = $false
        [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::Default
        $script:Controls.RunStateValue.Text = $script:Text.idle
        $script:Controls.RunStateValue.ForeColor = [System.Drawing.Color]::FromArgb(42, 104, 66)
    }
}

function Load-UiConfig {
    if (-not (Test-Path -LiteralPath $script:ConfigPath)) {
        return Get-DefaultUiConfig
    }

    try {
        $config = Read-JsonFile -Path $script:ConfigPath
        foreach ($key in (Get-DefaultUiConfig).Keys) {
            if (-not $config.ContainsKey($key)) {
                $config[$key] = (Get-DefaultUiConfig)[$key]
            }
        }
        return $config
    } catch {
        Append-Log -Message ("{0}: {1}" -f $script:Text.read_config_failed, $_.Exception.Message)
        return Get-DefaultUiConfig
    }
}

function Apply-ConfigToForm {
    param([Parameter(Mandatory = $true)]$Config)

    $script:Controls.InputPathTextBox.Text = [string]$Config.input_path
    $script:Controls.TaskTimeTextBox.Text = [string]$Config.task_time
    $script:Controls.PollIntervalTextBox.Text = [string]$Config.poll_interval_seconds
    $script:Controls.MaxPollTextBox.Text = [string]$Config.max_poll_hours
    if ($script:Controls.ModelVersionTextBox -is [System.Windows.Forms.ComboBox]) {
        $configuredModel = [string]$Config.model_version
        if (-not [string]::IsNullOrWhiteSpace($configuredModel) -and -not $script:Controls.ModelVersionTextBox.Items.Contains($configuredModel)) {
            [void]$script:Controls.ModelVersionTextBox.Items.Add($configuredModel)
        }
    }
    $script:Controls.ModelVersionTextBox.Text = [string]$Config.model_version
    $script:Controls.DurationTextBox.Text = [string]$Config.duration
    $script:Controls.RatioTextBox.Text = [string]$Config.ratio
    $script:Controls.ResolutionTextBox.Text = [string]$Config.video_resolution
    $script:Controls.LoginTimeoutTextBox.Text = [string]$Config.login_timeout_minutes
    $script:Controls.LogRetentionTextBox.Text = [string]$Config.log_retention_days
}

function Get-UiConfigFromForm {
    $modelControl = $script:Controls.ModelVersionTextBox
    $modelVersion = $modelControl.Text.Trim()
    if ($modelControl -is [System.Windows.Forms.ComboBox] -and $modelControl.SelectedItem) {
        $modelVersion = ([string]$modelControl.SelectedItem).Trim()
    }

    return @{
        input_path = $script:Controls.InputPathTextBox.Text.Trim()
        poll_interval_seconds = $script:Controls.PollIntervalTextBox.Text.Trim()
        max_poll_hours = $script:Controls.MaxPollTextBox.Text.Trim()
        model_version = $modelVersion
        duration = $script:Controls.DurationTextBox.Text.Trim()
        ratio = $script:Controls.RatioTextBox.Text.Trim()
        video_resolution = $script:Controls.ResolutionTextBox.Text.Trim()
        login_timeout_minutes = $script:Controls.LoginTimeoutTextBox.Text.Trim()
        task_time = $script:Controls.TaskTimeTextBox.Text.Trim()
        log_retention_days = $script:Controls.LogRetentionTextBox.Text.Trim()
    }
}

function ConvertTo-ValidatedConfig {
    $config = Get-UiConfigFromForm
    $fieldNames = @{
        poll_interval_seconds = $script:Text.field_poll_seconds
        max_poll_hours = $script:Text.field_max_hours
        duration = $script:Text.field_duration
        login_timeout_minutes = $script:Text.field_login_timeout
        log_retention_days = $script:Text.field_log_keep
    }

    if ([string]::IsNullOrWhiteSpace($config.input_path)) {
        throw $script:Text.input_required
    }
    if (-not (Test-Path -LiteralPath $config.input_path -PathType Container)) {
        throw $script:Text.input_missing
    }
    if ($config.task_time -notmatch '^(?:[01]\d|2[0-3]):[0-5]\d$') {
        throw $script:Text.task_time_invalid
    }
    foreach ($key in @('poll_interval_seconds', 'max_poll_hours', 'duration', 'login_timeout_minutes', 'log_retention_days')) {
        $value = [string]$config[$key]
        if ($value -notmatch '^\d+$' -or [int]$value -le 0) {
            throw ("{0} {1}" -f $fieldNames[$key], (U '\u5fc5\u987b\u662f\u6b63\u6574\u6570\u3002'))
        }
        $config[$key] = [int]$value
    }
    if ([string]::IsNullOrWhiteSpace($config.model_version)) {
        throw $script:Text.model_required
    }

    return $config
}

function Save-UiConfig {
    try {
        $config = ConvertTo-ValidatedConfig
        Write-JsonFile -Path $script:ConfigPath -Data $config
        Append-Log -Message $script:Text.saved
        return $true
    } catch {
        Show-WarnBox -Title $script:Text.validation_title -Message $_.Exception.Message
        return $false
    }
}

function Test-IsTaskDirectoryLocal {
    param([Parameter(Mandatory = $true)][string]$DirectoryPath)

    if (-not (Test-Path -LiteralPath $DirectoryPath -PathType Container)) {
        return $false
    }

    $txtFiles = @(Get-ChildItem -LiteralPath $DirectoryPath -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -ieq '.txt' })
    $imageFiles = @(Get-ChildItem -LiteralPath $DirectoryPath -File -ErrorAction SilentlyContinue | Where-Object {
        @('.png', '.jpg', '.jpeg', '.webp') -icontains $_.Extension
    })
    return ($txtFiles.Count -eq 1 -and $imageFiles.Count -ge 1)
}

function Get-MotherRootForPath {
    param([Parameter(Mandatory = $true)][string]$InputPath)

    $resolved = (Resolve-Path -LiteralPath $InputPath).Path
    if (Test-IsTaskDirectoryLocal -DirectoryPath $resolved) {
        return Split-Path -Path $resolved -Parent
    }
    return $resolved
}

function Refresh-SchedulerStatus {
    $taskCommand = Get-Command -Name Get-ScheduledTask -ErrorAction SilentlyContinue
    if (-not $taskCommand) {
        Set-StatusLabel -Label $script:Controls.SchedulerStatusValue -Text $script:Text.scheduler_unavailable -Color ([System.Drawing.Color]::FromArgb(138, 55, 55))
        return
    }

    try {
        try {
            $tasks = @(Get-ScheduledTask -TaskName 'Dreamina*' -ErrorAction Stop | Sort-Object -Property TaskName)
        } catch {
            $defaultTask = Get-ScheduledTask -TaskName $script:TaskName -ErrorAction SilentlyContinue
            if ($defaultTask) {
                $tasks = @($defaultTask)
            } else {
                $tasks = @()
            }
        }
        if ($script:Controls.ContainsKey('SchedulerComboBox')) {
            $combo = $script:Controls.SchedulerComboBox
            $selected = [string]$combo.Text
            $combo.Items.Clear()
            foreach ($taskItem in $tasks) {
                [void]$combo.Items.Add($taskItem.TaskName)
            }
            if ($selected -and ($tasks | Where-Object { $_.TaskName -eq $selected })) {
                $combo.Text = $selected
            } elseif ($tasks | Where-Object { $_.TaskName -eq $script:TaskName }) {
                $combo.Text = $script:TaskName
            } elseif ($combo.Items.Count -gt 0) {
                $combo.SelectedIndex = 0
            } else {
                $combo.Text = $script:TaskName
            }
        }

        if ($tasks.Count -gt 0) {
            Set-StatusLabel -Label $script:Controls.SchedulerStatusValue -Text ($script:Text.scheduler_count_fmt -f $tasks.Count) -Color ([System.Drawing.Color]::FromArgb(42, 104, 66))
        } else {
            Set-StatusLabel -Label $script:Controls.SchedulerStatusValue -Text $script:Text.scheduler_missing -Color ([System.Drawing.Color]::FromArgb(138, 55, 55))
        }
    } catch {
        Set-StatusLabel -Label $script:Controls.SchedulerStatusValue -Text $script:Text.scheduler_missing -Color ([System.Drawing.Color]::FromArgb(138, 55, 55))
    }
}

function Refresh-CliStatus {
    param([Parameter(Mandatory = $true)]$StatusInfo)

    if ([bool]$StatusInfo.cli_installed) {
        $statusText = $script:Text.cli_installed
        $statusColor = [System.Drawing.Color]::FromArgb(42, 104, 66)
        if ([bool]$StatusInfo.update_available) {
            $statusText = $script:Text.cli_updatable
            $statusColor = [System.Drawing.Color]::FromArgb(168, 95, 0)
        }
        Set-StatusLabel -Label $script:Controls.CliStatusValue -Text $statusText -Color $statusColor

        $versionText = [string]$StatusInfo.local_version
        if (-not [string]::IsNullOrWhiteSpace([string]$StatusInfo.remote_version)) {
            $versionText = "{0} / {1} {2}" -f $StatusInfo.local_version, $script:Text.remote_prefix, $StatusInfo.remote_version
        }
        $script:Controls.CliVersionValue.Text = if ($versionText) { $versionText } else { $script:Text.unknown }
    } else {
        Set-StatusLabel -Label $script:Controls.CliStatusValue -Text $script:Text.cli_missing -Color ([System.Drawing.Color]::FromArgb(138, 55, 55))
        $script:Controls.CliVersionValue.Text = if ($StatusInfo.remote_version) { "{0} {1}" -f $script:Text.remote_prefix, $StatusInfo.remote_version } else { $script:Text.unknown }
    }
}

function Refresh-LoginStatus {
    param([Parameter(Mandatory = $true)]$StatusInfo)

    if ([bool]$StatusInfo.login_valid) {
        Set-StatusLabel -Label $script:Controls.LoginStatusValue -Text $script:Text.logged_in -Color ([System.Drawing.Color]::FromArgb(42, 104, 66))
    } else {
        Set-StatusLabel -Label $script:Controls.LoginStatusValue -Text $script:Text.not_logged_in -Color ([System.Drawing.Color]::FromArgb(138, 55, 55))
    }
}

function Refresh-TaskPreview {
    param([Parameter(Mandatory = $true)]$ScanResult)

    $grid = $script:Controls.TaskGrid
    $grid.Rows.Clear()
    foreach ($task in @($ScanResult.tasks)) {
        [void]$grid.Rows.Add(@(
            [string]$task.task_name,
            [string]$task.image_count,
            [string]$task.prompt_file,
            [string]$task.task_dir
        ))
    }
    $script:Controls.TaskSummaryValue.Text = $script:Text.task_count_fmt -f [int]$ScanResult.task_count
}

function Invoke-BackgroundCommand {
    param(
        [Parameter(Mandatory = $true)][string]$DisplayName,
        [Parameter(Mandatory = $true)][string]$ScriptPath,
        [string[]]$ScriptArguments = @(),
        [scriptblock]$OnComplete,
        [switch]$ExpectJson,
        [switch]$Quiet,
        [switch]$LongRunning
    )

    if ($script:IsBusy) {
        Show-WarnBox -Title $script:Text.busy_title -Message $script:Text.busy_message
        return
    }

    if (-not (Test-Path -LiteralPath $ScriptPath)) {
        Append-Log -Message ("{0}: {1}" -f $script:Text.script_missing, $ScriptPath)
        return
    }

    $commandArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $ScriptPath) + $ScriptArguments
    $stdoutPath = Join-Path ([IO.Path]::GetTempPath()) ("dreamina-launcher-{0}-out.log" -f ([guid]::NewGuid().ToString('N')))
    $stderrPath = Join-Path ([IO.Path]::GetTempPath()) ("dreamina-launcher-{0}-err.log" -f ([guid]::NewGuid().ToString('N')))
    $exitCodePath = Join-Path ([IO.Path]::GetTempPath()) ("dreamina-launcher-{0}-exit.txt" -f ([guid]::NewGuid().ToString('N')))
    $wrapperPath = Join-Path ([IO.Path]::GetTempPath()) ("dreamina-launcher-{0}.ps1" -f ([guid]::NewGuid().ToString('N')))

    try {
        Set-BusyState -Busy $true -Caption $DisplayName -KeepUtilityButtonsEnabled:$LongRunning
        if (-not $Quiet) {
            Append-Log -Message ("[{0}] {1}: powershell.exe {2}" -f $DisplayName, $script:Text.process_start, (ConvertTo-CommandLine -Arguments $commandArgs))
        }

        $wrapperLines = @(
            '$ErrorActionPreference = ''Stop''',
            ('$target = {0}' -f (Quote-PowerShellLiteral -Value $ScriptPath)),
            ('$targetArgs = @({0})' -f (($ScriptArguments | ForEach-Object { Quote-PowerShellLiteral -Value $_ }) -join ', ')),
            ('$exitCodePath = {0}' -f (Quote-PowerShellLiteral -Value $exitCodePath)),
            '$code = 0',
            'try {',
            '    $pwshArgs = @(''-NoProfile'', ''-ExecutionPolicy'', ''Bypass'', ''-WindowStyle'', ''Hidden'', ''-File'', $target) + $targetArgs',
            '    & powershell.exe @pwshArgs',
            '    if ($null -ne $LASTEXITCODE) { $code = [int]$LASTEXITCODE } elseif ($?) { $code = 0 } else { $code = 1 }',
            '} catch {',
            '    [Console]::Error.WriteLine($_.Exception.Message)',
            '    $code = 1',
            '}',
            'try { Set-Content -LiteralPath $exitCodePath -Value ([string]$code) -Encoding ASCII } catch { }',
            'exit $code'
        )
        Set-Content -LiteralPath $wrapperPath -Value ($wrapperLines -join [Environment]::NewLine) -Encoding UTF8
        $processArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', $wrapperPath)

        $process = Start-Process -FilePath 'powershell.exe' `
            -ArgumentList (ConvertTo-CommandLine -Arguments $processArgs) `
            -WorkingDirectory $script:RootPath `
            -WindowStyle Hidden `
            -RedirectStandardOutput $stdoutPath `
            -RedirectStandardError $stderrPath `
            -PassThru

        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 300

        $script:BackgroundState = @{
            Process = $process
            Timer = $timer
            StdOutPath = $stdoutPath
            StdErrPath = $stderrPath
            ExitCodePath = $exitCodePath
            WrapperPath = $wrapperPath
            LastOutLength = 0
            LastErrLength = 0
            Output = ''
            Error = ''
            OnComplete = $OnComplete
            ExpectJson = [bool]$ExpectJson
            Quiet = [bool]$Quiet
            DisplayName = $DisplayName
        }

        $timer.Add_Tick({
            try {
                if ($null -eq $script:BackgroundState) { return }

                if (Test-Path -LiteralPath $script:BackgroundState.StdOutPath) {
                    $currentOut = Read-LauncherTextFile -Path $script:BackgroundState.StdOutPath
                    if ($null -eq $currentOut) { $currentOut = $script:BackgroundState.Output }
                    if ($currentOut.Length -gt $script:BackgroundState.LastOutLength) {
                        $delta = $currentOut.Substring($script:BackgroundState.LastOutLength)
                        $script:BackgroundState.LastOutLength = $currentOut.Length
                        $script:BackgroundState.Output = $currentOut
                        if (-not $script:BackgroundState.Quiet) {
                            foreach ($line in ($delta -split "\r?\n")) {
                                if (-not [string]::IsNullOrWhiteSpace($line)) {
                                    Append-Log -Message $line
                                }
                            }
                        }
                    }
                }

                if (Test-Path -LiteralPath $script:BackgroundState.StdErrPath) {
                    $currentErr = Read-LauncherTextFile -Path $script:BackgroundState.StdErrPath
                    if ($null -eq $currentErr) { $currentErr = $script:BackgroundState.Error }
                    if ($currentErr.Length -gt $script:BackgroundState.LastErrLength) {
                        $delta = $currentErr.Substring($script:BackgroundState.LastErrLength)
                        $script:BackgroundState.LastErrLength = $currentErr.Length
                        $script:BackgroundState.Error = $currentErr
                        if (-not $script:BackgroundState.Quiet) {
                            foreach ($line in ($delta -split "\r?\n")) {
                                if (-not [string]::IsNullOrWhiteSpace($line)) {
                                    Append-Log -Message $line
                                }
                            }
                        }
                    }
                }

                if ($script:BackgroundState.Process.HasExited) {
                    $script:BackgroundState.Process.WaitForExit()
                    $script:BackgroundState.Process.Refresh()
                    $finalOut = Read-LauncherTextFile -Path $script:BackgroundState.StdOutPath
                    if ($null -ne $finalOut) {
                        $script:BackgroundState.Output = $finalOut
                    }
                    $finalErr = Read-LauncherTextFile -Path $script:BackgroundState.StdErrPath
                    if ($null -ne $finalErr) {
                        $script:BackgroundState.Error = $finalErr
                    }
                    $combined = if ($script:BackgroundState.Output -and $script:BackgroundState.Error) {
                        $script:BackgroundState.Output.TrimEnd() + [Environment]::NewLine + $script:BackgroundState.Error.TrimEnd()
                    } elseif ($script:BackgroundState.Error) {
                        $script:BackgroundState.Error.TrimEnd()
                    } else {
                        $script:BackgroundState.Output.TrimEnd()
                    }

                    $parsedJson = $null
                    if ($script:BackgroundState.ExpectJson -and $combined) {
                        $parsedJson = ConvertFrom-UiJsonText -Text $combined
                    }

                    $exitCode = $script:BackgroundState.Process.ExitCode
                    if ($null -eq $exitCode -and (Test-Path -LiteralPath $script:BackgroundState.ExitCodePath)) {
                        $exitCodeText = Read-LauncherTextFile -Path $script:BackgroundState.ExitCodePath
                        if (-not [string]::IsNullOrWhiteSpace($exitCodeText)) {
                            $exitCode = [int]$exitCodeText.Trim()
                        }
                    }
                    $completion = $script:BackgroundState.OnComplete
                    $quietMode = $script:BackgroundState.Quiet
                    $displayName2 = $script:BackgroundState.DisplayName

                    $script:BackgroundState.Timer.Stop()
                    $script:BackgroundState.Timer.Dispose()
                    $script:BackgroundState.Process.Dispose()
                    foreach ($tempPath in @($script:BackgroundState.StdOutPath, $script:BackgroundState.StdErrPath, $script:BackgroundState.ExitCodePath, $script:BackgroundState.WrapperPath)) {
                        if (Test-Path -LiteralPath $tempPath) {
                            Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
                        }
                    }
                    $script:BackgroundState = $null

                    Set-BusyState -Busy $false
                    if (-not $quietMode) {
                        Append-Log -Message ("[{0}] {1}: {2}" -f $displayName2, $script:Text.process_exit, $exitCode)
                    }
                    if ($completion) {
                        & $completion $exitCode $combined $parsedJson
                    }
                }
            } catch {
                if ($null -ne $script:BackgroundState) {
                    if ($null -ne $script:BackgroundState.Timer) {
                        $script:BackgroundState.Timer.Stop()
                        $script:BackgroundState.Timer.Dispose()
                    }
                    if ($null -ne $script:BackgroundState.Process) {
                        $script:BackgroundState.Process.Dispose()
                    }
                    foreach ($tempPath in @($script:BackgroundState.StdOutPath, $script:BackgroundState.StdErrPath, $script:BackgroundState.ExitCodePath, $script:BackgroundState.WrapperPath)) {
                        if ($tempPath -and (Test-Path -LiteralPath $tempPath)) {
                            Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
                        }
                    }
                }
                $script:BackgroundState = $null
                Set-BusyState -Busy $false
                Append-Log -Message ("{0}: {1}" -f $script:Text.background_failed, $_.Exception.Message)
            }
        })

        $timer.Start()
    } catch {
        $script:BackgroundState = $null
        Set-BusyState -Busy $false
        Append-Log -Message ("{0}: {1}" -f $script:Text.process_failed, $_.Exception.Message)
        foreach ($tempPath in @($stdoutPath, $stderrPath, $exitCodePath, $wrapperPath)) {
            if (Test-Path -LiteralPath $tempPath) {
                Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

function Refresh-EnvironmentStatus {
    Invoke-BackgroundCommand -DisplayName $script:Text.env_check -ScriptPath $script:NightlyScriptPath -ScriptArguments @('-CheckOnly', '-ConfigPath', $script:ConfigPath) -ExpectJson -Quiet -OnComplete {
        param($exitCode, $output, $json)
        if ($exitCode -ne 0 -or -not $json) {
            Set-StatusLabel -Label $script:Controls.CliStatusValue -Text $script:Text.check_failed -Color ([System.Drawing.Color]::FromArgb(138, 55, 55))
            Set-StatusLabel -Label $script:Controls.LoginStatusValue -Text $script:Text.unknown -Color ([System.Drawing.Color]::FromArgb(138, 55, 55))
            Append-Log -Message $script:Text.check_failed
            if (-not [string]::IsNullOrWhiteSpace($output)) {
                Append-Log -Message $output
            }
            return
        }

        Refresh-CliStatus -StatusInfo $json
        Refresh-LoginStatus -StatusInfo $json
        if ($json.remote_error) {
            Append-Log -Message ("{0}: {1}" -f $script:Text.remote_failed, $json.remote_error)
        }
    }
}

function Open-ExplorerPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    Start-Process -FilePath 'explorer.exe' -ArgumentList @($Path) | Out-Null
}

$script:RootPath = $PSScriptRoot
$script:ConfigPath = Join-Path $script:RootPath 'config.json'
$script:NightlyScriptPath = Join-Path $script:RootPath 'dreamina-nightly.ps1'
$script:RegisterScriptPath = Join-Path $script:RootPath 'register-task.ps1'
$script:TaskName = 'DreaminaNightly'
$script:IsBusy = $false
$script:Controls = @{}
$script:BackgroundState = $null
$script:ModelVersions = @(
    'seedance2.0fast',
    'seedance2.0',
    'seedance2.0fast_vip',
    'seedance2.0_vip'
)

function New-Label {
    param([string]$Text,[int]$X,[int]$Y,[int]$Width = 120)
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.Location = New-Object System.Drawing.Point($X, $Y)
    $label.Size = New-Object System.Drawing.Size($Width, 24)
    $label.Font = New-Object System.Drawing.Font('Segoe UI', 9)
    return $label
}

function New-TextBox {
    param([int]$X,[int]$Y,[int]$Width = 220)
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point($X, $Y)
    $textBox.Size = New-Object System.Drawing.Size($Width, 26)
    $textBox.Font = New-Object System.Drawing.Font('Segoe UI', 9)
    return $textBox
}

function New-ComboBox {
    param([int]$X,[int]$Y,[int]$Width = 220,[switch]$AllowText)
    $combo = New-Object System.Windows.Forms.ComboBox
    $combo.Location = New-Object System.Drawing.Point($X, $Y)
    $combo.Size = New-Object System.Drawing.Size($Width, 26)
    $combo.Font = New-Object System.Drawing.Font('Segoe UI', 9)
    if ($AllowText) {
        $combo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
    } else {
        $combo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    }
    return $combo
}

function New-Button {
    param([string]$Text,[int]$X,[int]$Y,[int]$Width = 110)
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Location = New-Object System.Drawing.Point($X, $Y)
    $button.Size = New-Object System.Drawing.Size($Width, 32)
    $button.Font = New-Object System.Drawing.Font('Segoe UI', 9)
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 241)
    return $button
}

$form = New-Object System.Windows.Forms.Form
$form.Text = $script:Text.app_title
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.Size = New-Object System.Drawing.Size(1180, 860)
$form.MinimumSize = New-Object System.Drawing.Size(1180, 860)
$form.BackColor = [System.Drawing.Color]::FromArgb(250, 248, 243)
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$script:Controls.Form = $form

$titleLabel = New-Label -Text $script:Text.app_title_short -X 24 -Y 18 -Width 360
$titleLabel.Font = New-Object System.Drawing.Font('Georgia', 16, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($titleLabel)

$subtitleLabel = New-Label -Text $script:Text.subtitle -X 24 -Y 50 -Width 680
$subtitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(95, 95, 95)
$form.Controls.Add($subtitleLabel)

$contactLabel = New-Label -Text 'V:jhy0246' -X 1010 -Y 28 -Width 120
$contactLabel.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
$contactLabel.ForeColor = [System.Drawing.Color]::FromArgb(88, 88, 88)
$form.Controls.Add($contactLabel)

$envGroup = New-Object System.Windows.Forms.GroupBox
$envGroup.Text = $script:Text.group_env
$envGroup.Location = New-Object System.Drawing.Point(24, 86)
$envGroup.Size = New-Object System.Drawing.Size(1120, 120)
$envGroup.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$form.Controls.Add($envGroup)

$envGroup.Controls.Add((New-Label -Text $script:Text.label_cli_status -X 22 -Y 34 -Width 90))
$cliStatusValue = New-Label -Text $script:Text.unknown -X 110 -Y 34 -Width 140
$envGroup.Controls.Add($cliStatusValue)
$script:Controls.CliStatusValue = $cliStatusValue

$envGroup.Controls.Add((New-Label -Text $script:Text.label_cli_version -X 268 -Y 34 -Width 90))
$cliVersionValue = New-Label -Text $script:Text.unknown -X 358 -Y 34 -Width 260
$envGroup.Controls.Add($cliVersionValue)
$script:Controls.CliVersionValue = $cliVersionValue

$envGroup.Controls.Add((New-Label -Text $script:Text.label_login -X 22 -Y 68 -Width 90))
$loginStatusValue = New-Label -Text $script:Text.unknown -X 110 -Y 68 -Width 160
$envGroup.Controls.Add($loginStatusValue)
$script:Controls.LoginStatusValue = $loginStatusValue

$envGroup.Controls.Add((New-Label -Text $script:Text.label_scheduler -X 268 -Y 68 -Width 90))
$schedulerStatusValue = New-Label -Text $script:Text.unknown -X 358 -Y 68 -Width 260
$envGroup.Controls.Add($schedulerStatusValue)
$script:Controls.SchedulerStatusValue = $schedulerStatusValue

$envGroup.Controls.Add((New-Label -Text $script:Text.label_run_state -X 640 -Y 50 -Width 80))
$runStateValue = New-Label -Text $script:Text.idle -X 716 -Y 50 -Width 120
$runStateValue.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10)
$envGroup.Controls.Add($runStateValue)
$script:Controls.RunStateValue = $runStateValue

$detectButton = New-Button -Text $script:Text.btn_detect -X 830 -Y 28 -Width 96
$installButton = New-Button -Text $script:Text.btn_install -X 934 -Y 28 -Width 120
$installButton.BackColor = [System.Drawing.Color]::FromArgb(230, 220, 196)
$loginButton = New-Button -Text $script:Text.btn_login -X 1060 -Y 28 -Width 44
$loginButton.BackColor = [System.Drawing.Color]::FromArgb(235, 226, 210)
$envGroup.Controls.AddRange(@($detectButton, $installButton, $loginButton))
$script:Controls.DetectButton = $detectButton
$script:Controls.InstallButton = $installButton
$script:Controls.LoginButton = $loginButton

$configGroup = New-Object System.Windows.Forms.GroupBox
$configGroup.Text = $script:Text.group_config
$configGroup.Location = New-Object System.Drawing.Point(24, 222)
$configGroup.Size = New-Object System.Drawing.Size(1120, 212)
$configGroup.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$form.Controls.Add($configGroup)

$configGroup.Controls.Add((New-Label -Text $script:Text.label_input -X 22 -Y 36 -Width 74))
$inputPathTextBox = New-TextBox -X 100 -Y 32 -Width 770
$browseButton = New-Button -Text $script:Text.btn_browse -X 886 -Y 30 -Width 100
$configGroup.Controls.AddRange(@($inputPathTextBox, $browseButton))
$script:Controls.InputPathTextBox = $inputPathTextBox
$script:Controls.BrowseButton = $browseButton

$fieldDefs = @(
    @{ Label = $script:Text.field_task_time; Name = 'TaskTimeTextBox'; X = 22; Y = 82; Width = 74; ValueX = 100; ValueWidth = 120 },
    @{ Label = $script:Text.field_poll_seconds; Name = 'PollIntervalTextBox'; X = 250; Y = 82; Width = 80; ValueX = 330; ValueWidth = 120 },
    @{ Label = $script:Text.field_max_hours; Name = 'MaxPollTextBox'; X = 478; Y = 82; Width = 74; ValueX = 558; ValueWidth = 120 },
    @{ Label = $script:Text.field_model; Name = 'ModelVersionTextBox'; X = 706; Y = 82; Width = 80; ValueX = 786; ValueWidth = 200 },
    @{ Label = $script:Text.field_duration; Name = 'DurationTextBox'; X = 22; Y = 132; Width = 74; ValueX = 100; ValueWidth = 120 },
    @{ Label = $script:Text.field_ratio; Name = 'RatioTextBox'; X = 250; Y = 132; Width = 80; ValueX = 330; ValueWidth = 120 },
    @{ Label = $script:Text.field_resolution; Name = 'ResolutionTextBox'; X = 478; Y = 132; Width = 74; ValueX = 558; ValueWidth = 120 },
    @{ Label = $script:Text.field_login_timeout; Name = 'LoginTimeoutTextBox'; X = 706; Y = 132; Width = 80; ValueX = 786; ValueWidth = 90 },
    @{ Label = $script:Text.field_log_keep; Name = 'LogRetentionTextBox'; X = 900; Y = 132; Width = 70; ValueX = 974; ValueWidth = 60 }
)

foreach ($field in $fieldDefs) {
    $configGroup.Controls.Add((New-Label -Text $field.Label -X $field.X -Y $field.Y -Width $field.Width))
    if ($field.Name -eq 'ModelVersionTextBox') {
        $modelComboBox = New-ComboBox -X $field.ValueX -Y ($field.Y - 4) -Width $field.ValueWidth
        foreach ($modelVersion in $script:ModelVersions) {
            [void]$modelComboBox.Items.Add($modelVersion)
        }
        $configGroup.Controls.Add($modelComboBox)
        $script:Controls[$field.Name] = $modelComboBox
    } else {
        $textBox = New-TextBox -X $field.ValueX -Y ($field.Y - 4) -Width $field.ValueWidth
        $configGroup.Controls.Add($textBox)
        $script:Controls[$field.Name] = $textBox
    }
}

$saveButton = New-Button -Text $script:Text.btn_save -X 886 -Y 174 -Width 100
$resetButton = New-Button -Text $script:Text.btn_reset -X 992 -Y 174 -Width 96
$configGroup.Controls.AddRange(@($saveButton, $resetButton))
$script:Controls.SaveButton = $saveButton
$script:Controls.ResetButton = $resetButton

$runtimeGroup = New-Object System.Windows.Forms.GroupBox
$runtimeGroup.Text = $script:Text.group_run
$runtimeGroup.Location = New-Object System.Drawing.Point(24, 450)
$runtimeGroup.Size = New-Object System.Drawing.Size(1120, 360)
$runtimeGroup.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 9)
$form.Controls.Add($runtimeGroup)

$scanButton = New-Button -Text $script:Text.btn_scan -X 22 -Y 30 -Width 96
$runButton = New-Button -Text $script:Text.btn_run -X 126 -Y 30 -Width 86
$runButton.BackColor = [System.Drawing.Color]::FromArgb(223, 211, 182)
$registerButton = New-Button -Text $script:Text.btn_register -X 220 -Y 30 -Width 118
$unregisterButton = New-Button -Text $script:Text.btn_unregister -X 346 -Y 30 -Width 96
$unregisterAllButton = New-Button -Text $script:Text.btn_unregister_all -X 450 -Y 30 -Width 96
$openDoneButton = New-Button -Text $script:Text.btn_open_done -X 554 -Y 30 -Width 118
$openLogsButton = New-Button -Text $script:Text.btn_open_logs -X 680 -Y 30 -Width 86
$runtimeGroup.Controls.AddRange(@($scanButton, $runButton, $registerButton, $unregisterButton, $unregisterAllButton, $openDoneButton, $openLogsButton))
$script:Controls.ScanButton = $scanButton
$script:Controls.RunButton = $runButton
$script:Controls.RegisterButton = $registerButton
$script:Controls.UnregisterButton = $unregisterButton
$script:Controls.UnregisterAllButton = $unregisterAllButton
$script:Controls.OpenDoneButton = $openDoneButton
$script:Controls.OpenLogsButton = $openLogsButton

$runtimeGroup.Controls.Add((New-Label -Text $script:Text.label_scheduler -X 22 -Y 74 -Width 74))
$schedulerComboBox = New-ComboBox -X 100 -Y 70 -Width 260 -AllowText
$runtimeGroup.Controls.Add($schedulerComboBox)
$script:Controls.SchedulerComboBox = $schedulerComboBox

$taskSummaryValue = New-Label -Text $script:Text.task_not_loaded -X 382 -Y 74 -Width 420
$runtimeGroup.Controls.Add($taskSummaryValue)
$script:Controls.TaskSummaryValue = $taskSummaryValue

$taskGrid = New-Object System.Windows.Forms.DataGridView
$taskGrid.Location = New-Object System.Drawing.Point(22, 110)
$taskGrid.Size = New-Object System.Drawing.Size(1068, 132)
$taskGrid.ReadOnly = $true
$taskGrid.AllowUserToAddRows = $false
$taskGrid.AllowUserToDeleteRows = $false
$taskGrid.RowHeadersVisible = $false
$taskGrid.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
$taskGrid.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
[void]$taskGrid.Columns.Add('TaskName', $script:Text.col_task_name)
[void]$taskGrid.Columns.Add('ImageCount', $script:Text.col_images)
[void]$taskGrid.Columns.Add('PromptFile', $script:Text.col_prompt)
[void]$taskGrid.Columns.Add('TaskDir', $script:Text.col_task_dir)
$runtimeGroup.Controls.Add($taskGrid)
$script:Controls.TaskGrid = $taskGrid

$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Location = New-Object System.Drawing.Point(22, 254)
$logBox.Size = New-Object System.Drawing.Size(1068, 86)
$logBox.ReadOnly = $true
$logBox.WordWrap = $false
$logBox.Font = New-Object System.Drawing.Font('Consolas', 9)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(252, 251, 247)
$runtimeGroup.Controls.Add($logBox)
$script:Controls.LogBox = $logBox

$browseButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = $script:Text.choose_input
    if (Test-Path -LiteralPath $script:Controls.InputPathTextBox.Text -PathType Container) {
        $dialog.SelectedPath = $script:Controls.InputPathTextBox.Text
    }
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:Controls.InputPathTextBox.Text = $dialog.SelectedPath
    }
    $dialog.Dispose()
})

$saveButton.Add_Click({ [void](Save-UiConfig) })

$resetButton.Add_Click({
    Apply-ConfigToForm -Config (Get-DefaultUiConfig)
    Append-Log -Message $script:Text.restored
})

$detectButton.Add_Click({
    Refresh-SchedulerStatus
    Refresh-EnvironmentStatus
})

$installButton.Add_Click({
    Invoke-BackgroundCommand -DisplayName $script:Text.install_run -ScriptPath $script:NightlyScriptPath -ScriptArguments @('-InstallOnly', '-ConfigPath', $script:ConfigPath) -OnComplete {
        param($exitCode, $output, $json)
        if ($exitCode -eq 0) { Append-Log -Message $script:Text.install_ok } else { Append-Log -Message $script:Text.install_fail }
        Refresh-EnvironmentStatus
    }
})

$loginButton.Add_Click({
    Invoke-BackgroundCommand -DisplayName $script:Text.login_run -ScriptPath $script:NightlyScriptPath -ScriptArguments @('-LoginOnly', '-ConfigPath', $script:ConfigPath) -OnComplete {
        param($exitCode, $output, $json)
        if ($exitCode -eq 0) { Append-Log -Message $script:Text.login_ok } else { Append-Log -Message $script:Text.login_fail }
        Refresh-EnvironmentStatus
    }
})

$scanButton.Add_Click({
    if (-not (Save-UiConfig)) { return }
    Invoke-BackgroundCommand -DisplayName $script:Text.scan_run -ScriptPath $script:NightlyScriptPath -ScriptArguments @('-ScanOnly', '-ConfigPath', $script:ConfigPath) -ExpectJson -OnComplete {
        param($exitCode, $output, $json)
        if ($exitCode -ne 0 -or -not $json) {
            Append-Log -Message $script:Text.scan_fail
            if (-not [string]::IsNullOrWhiteSpace($output)) {
                Append-Log -Message $output
            }
            return
        }
        Refresh-TaskPreview -ScanResult $json
        Append-Log -Message ($script:Text.scan_ok_fmt -f [int]$json.task_count)
    }
})

$runButton.Add_Click({
    if (-not (Save-UiConfig)) { return }
    Invoke-BackgroundCommand -DisplayName $script:Text.run_run -ScriptPath $script:NightlyScriptPath -ScriptArguments @('-RunOnce', '-ConfigPath', $script:ConfigPath) -LongRunning -OnComplete {
        param($exitCode, $output, $json)
        if ($exitCode -eq 0) { Append-Log -Message $script:Text.run_ok } else { Append-Log -Message $script:Text.run_fail }
        Refresh-SchedulerStatus
    }
})

$registerButton.Add_Click({
    if (-not (Save-UiConfig)) { return }
    Invoke-BackgroundCommand -DisplayName $script:Text.register_run -ScriptPath $script:RegisterScriptPath -ScriptArguments @('-ConfigPath', $script:ConfigPath) -OnComplete {
        param($exitCode, $output, $json)
        if ($exitCode -eq 0) { Append-Log -Message $script:Text.register_ok } else { Append-Log -Message $script:Text.register_fail }
        Refresh-SchedulerStatus
    }
})

$unregisterButton.Add_Click({
    $selectedTask = [string]$script:Controls.SchedulerComboBox.Text
    if ([string]::IsNullOrWhiteSpace($selectedTask)) {
        Show-WarnBox -Title $script:Text.unregister_run -Message $script:Text.no_scheduler_selected
        return
    }
    if (-not (Show-ConfirmBox -Title $script:Text.confirm_title -Message ($script:Text.confirm_unregister_fmt -f $selectedTask))) {
        return
    }

    Invoke-BackgroundCommand -DisplayName $script:Text.unregister_run -ScriptPath $script:RegisterScriptPath -ScriptArguments @('-Unregister', '-TaskName', $selectedTask, '-ConfigPath', $script:ConfigPath) -OnComplete {
        param($exitCode, $output, $json)
        if ($exitCode -eq 0) { Append-Log -Message $script:Text.unregister_ok } else { Append-Log -Message $script:Text.unregister_fail }
        Refresh-SchedulerStatus
    }
})

$unregisterAllButton.Add_Click({
    if (-not (Show-ConfirmBox -Title $script:Text.confirm_title -Message $script:Text.confirm_unregister_all)) {
        return
    }

    Invoke-BackgroundCommand -DisplayName $script:Text.unregister_all_run -ScriptPath $script:RegisterScriptPath -ScriptArguments @('-UnregisterAll', '-ConfigPath', $script:ConfigPath) -OnComplete {
        param($exitCode, $output, $json)
        if ($exitCode -eq 0) { Append-Log -Message $script:Text.unregister_all_ok } else { Append-Log -Message $script:Text.unregister_all_fail }
        Refresh-SchedulerStatus
    }
})

$openDoneButton.Add_Click({
    try {
        $config = ConvertTo-ValidatedConfig
        $motherRoot = Get-MotherRootForPath -InputPath $config.input_path
        Open-ExplorerPath -Path (Join-Path $motherRoot 'done')
    } catch {
        Show-WarnBox -Title $script:Text.open_folder -Message $_.Exception.Message
    }
})

$openLogsButton.Add_Click({
    try {
        $config = ConvertTo-ValidatedConfig
        $motherRoot = Get-MotherRootForPath -InputPath $config.input_path
        Open-ExplorerPath -Path (Join-Path (Join-Path $motherRoot 'tmp') 'logs')
    } catch {
        Show-WarnBox -Title $script:Text.open_folder -Message $_.Exception.Message
    }
})

$form.Add_Shown({
    Apply-ConfigToForm -Config (Load-UiConfig)
    Append-Log -Message $script:Text.launcher_ready
    Append-Log -Message $script:Text.use_vbs
    Append-Log -Message $script:Text.use_bat
    Refresh-SchedulerStatus
    Refresh-EnvironmentStatus
})

try {
    Ensure-LauncherFiles
    [void]$form.ShowDialog()
} catch {
    Show-ErrorBox -Title $script:Text.app_title -Message $_.Exception.Message
    exit 1
}
