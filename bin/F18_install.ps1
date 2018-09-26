$F18_VER="3.1.215"


#Create a wscript.shell object
$ComObj = New-Object -ComObject WScript.Shell

#Use the createshortcut method and assign to a variable
$ShortCut = $ComObj.CreateShortcut("$Env:USERPROFILE\desktop\F18_klijent.lnk")

#Path to file shorcut will open
$ShortCut.TargetPath = "$PSHOME\powershell.exe"
#$ShortCut.TargetPath = 
#$PSHOME
$Shortcut.WorkingDirectory = "$Env:USERPROFILE\F18"

$Shortcut.Arguments = "-File $Env:USERPROFILE\F18\F18.ps1"


#Describe the shortcut
$ShortCut.Description = "F18 - knjigovodstvo za Bosance"

#Returns the fullpatth you defined for the shortcut
$ShortCut.FullName 

#How the window will behave when opened
$ShortCut.WindowStyle = 7
#1 - Activates and displays a window. If the window is minimized or maximized, the system restores it to its original size and position.
#3 - Activates the window and displays it as a maximized window.
#7 - Minimizes the window and activates the next top-level window.

#Create a hotkey shortcut for your shortcut
$ShortCut.Hotkey = "CTRL+SHIFT+F5"
#Modifiers include - ALT+, CTRL+, SHIFT+, EXT+.
#KeyName - a ... z, 0 ... 9, F1 .. F12

#Provide an icon for your shortcut
#$ShortCut.IconLocation = "$Env:USERPROFILE\desktop\favicon.ico"
#If left blank it will use the icon for the file you're calling

$ShortCut.Save()


#Create a wscript.shell object
#$ComObj = New-Object -ComObject WScript.Shell

#Use the createshortcut method and assign to a variable
#$ShortCut = $ComObj.CreateShortcut("$Env:USERPROFILE\desktop\F18_klijent.url")

#Path to URL
#$ShortCut.TargetPath = "c:\Users\hernad\F18\F18.exe"

#$ShortCut.Save()

#$url = ""
#$output = "$Env:USERPROFILE\F18\postgresql_windows_x86_dlls.zip"

Set-Location -Path "$Env:USERPROFILE\F18"

#Invoke-Expression "curl.exe -L $url > postgresql_windows_x86_dlls.zip"
#Invoke-WebRequest -MaximumRedirection 20 -Uri $url -OutFile $output

#$Url = "https://dl.bintray.com/hernad/F18/postgresql_windows_x86_dlls.zip"



$Url = "https://github.com/knowhow/F18_knowhow/raw/3/bin/win32/postgresql_windows_x86_dlls.zip"
$Path = "$Env:USERPROFILE\F18\postgresql_windows_x86_dlls.zip"

if (-not (Test-Path $Path)) { 
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $Url -OutFile $Path
    #[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    #$webClient = new-object System.Net.WebClient
    #$webClient.DownloadFile( $Url, $Path )

    Expand-Archive "$Env:USERPROFILE\F18\postgresql_windows_x86_dlls.zip" -DestinationPath "$Env:USERPROFILE\F18"

 }

 $Url = "https://github.com/knowhow/F18_knowhow/raw/3/bin/win32/wget.zip"
 $Path = "$Env:USERPROFILE\F18\wget.zip"

 if (-not (Test-Path $Path)) { 
     [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
     Invoke-WebRequest -Uri $Url -OutFile $Path
     #[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
     #$webClient = new-object System.Net.WebClient
     #$webClient.DownloadFile( $Url, $Path )
 
     Expand-Archive $Path -DestinationPath "$Env:USERPROFILE\F18"
 
}


$Url = "https://dl.bintray.com/hernad/F18/F18_windows_x86_" + $F18_VER + ".zip"
$Path = "$Env:USERPROFILE\F18\F18_" + $F18_VER + ".zip"

Write-Host "bintray: $Url"

 if (-not (Test-Path $Path)) { 
     [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
     Invoke-WebRequest -Uri $Url -OutFile $Path
     #[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
     #$webClient = new-object System.Net.WebClient
     #$webClient.DownloadFile( $Url, $Path )
 
     Expand-Archive $Path -Force -DestinationPath "$Env:USERPROFILE\F18"
 
}


$Url = "https://github.com/knowhow/F18_knowhow/raw/3/bin/F18.ps1"
$Path = "$Env:USERPROFILE\F18\F18.ps1"

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $Url -OutFile $Path

