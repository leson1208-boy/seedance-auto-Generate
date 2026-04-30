[CmdletBinding()]
param(
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $PSScriptRoot 'DreaminaLauncher.exe'
}

$iconPath = Join-Path $PSScriptRoot 'DreaminaLauncher.ico'
if (-not (Test-Path -LiteralPath $iconPath)) {
    throw "Cannot find icon file: $iconPath"
}

$buildRoot = Join-Path $PSScriptRoot 'tmp_exe_build'
if (Test-Path -LiteralPath $buildRoot) {
    Remove-Item -LiteralPath $buildRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $buildRoot | Out-Null

$programPath = Join-Path $buildRoot 'Program.cs'
$cscPath = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path -LiteralPath $cscPath)) {
    $cscPath = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe'
}
if (-not (Test-Path -LiteralPath $cscPath)) {
    throw 'Cannot find csc.exe. Please install .NET Framework 4.x or use Start Dreamina.vbs instead.'
}

$automationDllCandidates = @(
    (Join-Path $PSHOME 'System.Management.Automation.dll'),
    (Join-Path $env:WINDIR 'Microsoft.NET\assembly\GAC_MSIL\System.Management.Automation\v4.0_3.0.0.0__31bf3856ad364e35\System.Management.Automation.dll')
)
$automationDll = $automationDllCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $automationDll) {
    throw 'Cannot find System.Management.Automation.dll. Please use Windows PowerShell 5.1 or Start Dreamina.vbs instead.'
}

Set-Content -LiteralPath $programPath -Encoding UTF8 -Value @'
using System;
using System.Collections.ObjectModel;
using System.IO;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Text;
using System.Threading;
using System.Windows.Forms;

internal static class Program
{
    [STAThread]
    private static int Main()
    {
        string baseDir = AppDomain.CurrentDomain.BaseDirectory;
        string scriptPath = Path.Combine(baseDir, "DreaminaLauncher.ps1");

        if (!File.Exists(scriptPath))
        {
            MessageBox.Show(
                "DreaminaLauncher.ps1 was not found. Put DreaminaLauncher.exe in the same folder as the script package.",
                "Dreamina Launcher",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
            return 1;
        }

        try
        {
            Directory.SetCurrentDirectory(baseDir);
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            using (Runspace runspace = RunspaceFactory.CreateRunspace())
            {
                runspace.ApartmentState = ApartmentState.STA;
                runspace.ThreadOptions = PSThreadOptions.UseCurrentThread;
                runspace.Open();

                using (PowerShell ps = PowerShell.Create())
                {
                    ps.Runspace = runspace;
                    string escapedScriptPath = scriptPath.Replace("'", "''");
                    ps.AddScript("Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force; & '" + escapedScriptPath + "'");
                    Collection<PSObject> output = ps.Invoke();

                    if (ps.HadErrors)
                    {
                        StringBuilder builder = new StringBuilder();
                        foreach (ErrorRecord error in ps.Streams.Error)
                        {
                            builder.AppendLine(error.ToString());
                        }
                        MessageBox.Show(
                            builder.ToString(),
                            "Dreamina Launcher runtime error",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Error);
                        return 1;
                    }
                }
            }

            return 0;
        }
        catch (Exception ex)
        {
            MessageBox.Show(
                ex.Message,
                "Dreamina Launcher startup error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
            return 1;
        }
    }
}
'@

$compilerArgs = @(
    '/nologo',
    '/target:winexe',
    '/platform:x64',
    '/utf8output',
    ('/out:{0}' -f $OutputPath),
    '/reference:System.dll',
    '/reference:System.Windows.Forms.dll',
    '/reference:System.Drawing.dll',
    ('/reference:{0}' -f $automationDll),
    ('/win32icon:{0}' -f $iconPath),
    $programPath
)

& $cscPath @compilerArgs
if ($LASTEXITCODE -ne 0) {
    throw "csc.exe failed with exit code $LASTEXITCODE"
}

Write-Host "Built: $OutputPath"
