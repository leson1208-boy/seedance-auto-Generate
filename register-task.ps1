[CmdletBinding()]
param(
    [string]$ConfigPath,
    [string]$TaskName = 'DreaminaNightly',
    [switch]$Unregister,
    [switch]$UnregisterAll,
    [switch]$List
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot 'config.json'
}

function Read-Config {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Config file not found: $Path"
    }

    return ConvertFrom-Json -InputObject (Get-Content -LiteralPath $Path -Raw -Encoding UTF8)
}

function Get-DreaminaScheduledTasks {
    try {
        return @(Get-ScheduledTask -TaskName 'Dreamina*' -ErrorAction Stop | Sort-Object -Property TaskName)
    } catch {
        $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($task) {
            return @($task)
        }
        return @()
    }
}

function Write-TaskListJson {
    $tasks = @(Get-DreaminaScheduledTasks | ForEach-Object {
        @{
            task_name = $_.TaskName
            task_path = $_.TaskPath
            state = [string]$_.State
        }
    })
    Write-Output (@{
        task_count = $tasks.Count
        tasks = $tasks
    } | ConvertTo-Json -Depth 5)
}

function Unregister-OneTask {
    param([Parameter(Mandatory = $true)][string]$Name)

    $task = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
    if (-not $task) {
        Write-Host ("Scheduled task '{0}' was not found." -f $Name)
        return
    }

    Unregister-ScheduledTask -TaskName $Name -Confirm:$false
    Write-Host ("Unregistered scheduled task '{0}'." -f $Name)
}

function Unregister-AllDreaminaTasks {
    $tasks = @(Get-DreaminaScheduledTasks)
    if ($tasks.Count -eq 0) {
        Write-Host 'No Dreamina scheduled tasks found.'
        return
    }
    foreach ($task in $tasks) {
        Unregister-ScheduledTask -TaskName $task.TaskName -TaskPath $task.TaskPath -Confirm:$false
        Write-Host ("Unregistered scheduled task '{0}'." -f $task.TaskName)
    }
    Write-Host ("Unregistered {0} Dreamina scheduled task(s)." -f $tasks.Count)
}

function Main {
    if ($List) {
        Write-TaskListJson
        return
    }

    if ($UnregisterAll) {
        Unregister-AllDreaminaTasks
        return
    }

    if ($Unregister) {
        Unregister-OneTask -Name $TaskName
        return
    }

    $config = Read-Config -Path $ConfigPath
    if (-not $config.task_time) {
        throw 'Config key task_time is required.'
    }

    $scriptPath = Join-Path $PSScriptRoot 'dreamina-nightly.ps1'
    if (-not (Test-Path -LiteralPath $scriptPath)) {
        throw "Main script not found: $scriptPath"
    }

    $resolvedConfigPath = (Resolve-Path -LiteralPath $ConfigPath).Path
    $resolvedScriptPath = (Resolve-Path -LiteralPath $scriptPath).Path
    $time = [datetime]::ParseExact([string]$config.task_time, 'HH:mm', [Globalization.CultureInfo]::InvariantCulture)
    $userId = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $arguments = @(
        '-NoProfile',
        '-ExecutionPolicy', 'Bypass',
        '-File', ('"{0}"' -f $resolvedScriptPath),
        '-ConfigPath', ('"{0}"' -f $resolvedConfigPath)
    ) -join ' '

    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arguments
    $trigger = New-ScheduledTaskTrigger -Daily -At $time
    $principal = New-ScheduledTaskPrincipal -UserId $userId -LogonType Interactive -RunLevel Limited
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null

    Write-Host ("Registered scheduled task '{0}' for {1} as {2}" -f $TaskName, $config.task_time, $userId)
}

Main
