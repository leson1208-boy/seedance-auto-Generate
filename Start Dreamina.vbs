Set shell = CreateObject("WScript.Shell")
scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File """ & scriptDir & "\DreaminaLauncher.ps1"""
shell.CurrentDirectory = scriptDir
shell.Run command, 0, False
