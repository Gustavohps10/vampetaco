Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
scriptDir = objFSO.GetParentFolderName(WScript.ScriptFullName)
scriptPath = scriptDir & "\Vampetaco.ps1"
objShell.Run "powershell.exe -ExecutionPolicy Bypass -File """ & scriptPath & """", 0, False
