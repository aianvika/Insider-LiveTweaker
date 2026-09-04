$ErrorActionPreference = "Stop"

$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as Administrator." -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "Insider LiveTweaker"
$form.Size = New-Object System.Drawing.Size(480, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Insider System Tweaks"
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$lblTitle.Location = New-Object System.Drawing.Point(20, 20)
$lblTitle.AutoSize = $true
$form.Controls.Add($lblTitle)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Select the modifications to apply to your live system."
$lblSub.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$lblSub.Location = New-Object System.Drawing.Point(22, 50)
$lblSub.AutoSize = $true
$form.Controls.Add($lblSub)

$cbWatermark = New-Object System.Windows.Forms.CheckBox
$cbWatermark.Text = "Remove Insider Watermark & Winver Text"
$cbWatermark.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$cbWatermark.Location = New-Object System.Drawing.Point(30, 85)
$cbWatermark.Size = New-Object System.Drawing.Size(400, 25)
$cbWatermark.Checked = $true
$form.Controls.Add($cbWatermark)

$cbTimebomb = New-Object System.Windows.Forms.CheckBox
$cbTimebomb.Text = "Defuse Insider Timebomb"
$cbTimebomb.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$cbTimebomb.Location = New-Object System.Drawing.Point(30, 115)
$cbTimebomb.Size = New-Object System.Drawing.Size(400, 25)
$cbTimebomb.Checked = $false
$form.Controls.Add($cbTimebomb)

$tbConsole = New-Object System.Windows.Forms.TextBox
$tbConsole.Location = New-Object System.Drawing.Point(20, 160)
$tbConsole.Size = New-Object System.Drawing.Size(425, 130)
$tbConsole.Multiline = $true
$tbConsole.ReadOnly = $true
$tbConsole.ScrollBars = "Vertical"
$tbConsole.Font = New-Object System.Drawing.Font("Consolas", 8)
$tbConsole.BackColor = [System.Drawing.Color]::Black
$tbConsole.ForeColor = [System.Drawing.Color]::LimeGreen
$form.Controls.Add($tbConsole)

$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Text = "Apply Selected Tweaks"
$btnApply.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnApply.Location = New-Object System.Drawing.Point(140, 310)
$btnApply.Size = New-Object System.Drawing.Size(200, 35)
$btnApply.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$btnApply.ForeColor = [System.Drawing.Color]::White
$btnApply.FlatStyle = "Flat"
$btnApply.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnApply)

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $tbConsole.AppendText("[$timestamp] $Message`r`n")
    $tbConsole.SelectionStart = $tbConsole.Text.Length
    $tbConsole.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

function Patch-BinaryUnicodeString {
    param(
        [string]$FilePath,
        [string]$Search,
        [string]$Replace
    )
    if ($Replace.Length -gt $Search.Length) {
        $Replace = $Replace.Substring(0, $Search.Length)
    } else {
        $Replace = $Replace.PadRight($Search.Length)
    }
    $Bytes = [System.IO.File]::ReadAllBytes($FilePath)
    $searchBytes = [System.Text.Encoding]::Unicode.GetBytes($Search)
    $replaceBytes = [System.Text.Encoding]::Unicode.GetBytes($Replace)
    $patched = $false
    for ($i = 0; $i -le ($Bytes.Length - $searchBytes.Length); $i++) {
        $match = $true
        for ($j = 0; $j -lt $searchBytes.Length; $j++) {
            if ($Bytes[$i+$j] -ne $searchBytes[$j]) {
                $match = $false
                break
            }
        }
        if ($match) {
            for ($j = 0; $j -lt $replaceBytes.Length; $j++) {
                $Bytes[$i+$j] = $replaceBytes[$j]
            }
            $patched = $true
        }
    }
    if ($patched) {
        $bakFile = "$FilePath.bak"
        if (Test-Path $bakFile) { Remove-Item $bakFile -Force -ErrorAction SilentlyContinue }
        try {
            Move-Item -Path $FilePath -Destination $bakFile -Force
            [System.IO.File]::WriteAllBytes($FilePath, $Bytes)
        } catch {
            Write-Log "Error processing file."
            return $false
        }
    }
    return $patched
}

$btnApply.Add_Click({
    $btnApply.Enabled = $false
    $tbConsole.Clear()
    
    if (-not $cbWatermark.Checked -and -not $cbTimebomb.Checked) {
        Write-Log "No options selected."
        $btnApply.Enabled = $true
        return
    }

    try {
        if ($cbWatermark.Checked) {
            Write-Log "Processing Watermark..."
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoRestartShell" -Value 0
            Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            
            $adminGroup = (New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")).Translate([System.Security.Principal.NTAccount]).Value
            
            $shellLangs = Get-ChildItem -Path "C:\Windows\System32" -Directory -Filter "en-*" -ErrorAction SilentlyContinue
            foreach ($langDir in $shellLangs) {
                $muiFile = Join-Path $langDir.FullName "shell32.dll.mui"
                if (Test-Path $muiFile) {
                    try {
                        & takeown.exe /f $muiFile /a 2>&1 | Out-Null
                        & icacls.exe $muiFile /grant "$($adminGroup):(F)" 2>&1 | Out-Null
                        
                        $didPatch = $false
                        if (Patch-BinaryUnicodeString -FilePath $muiFile -Search "Evaluation copy." -Replace " ") { $didPatch = $true }
                        if (Patch-BinaryUnicodeString -FilePath $muiFile -Search "%ws Build %ws" -Replace " ") { $didPatch = $true }
                        if (Patch-BinaryUnicodeString -FilePath $muiFile -Search "For testing purposes only." -Replace " ") { $didPatch = $true }
                        if ($didPatch) { Write-Log "Successfully applied patch." }
                    } catch { Write-Log "An error occurred." }
                }
                
                $winverMuiFile = Join-Path $langDir.FullName "winver.exe.mui"
                if (Test-Path $winverMuiFile) {
                    try {
                        & takeown.exe /f $winverMuiFile /a 2>&1 | Out-Null
                        & icacls.exe $winverMuiFile /grant "$($adminGroup):(F)" 2>&1 | Out-Null
                        
                        if (Patch-BinaryUnicodeString -FilePath $winverMuiFile -Search "Evaluation copy. Expires " -Replace " ") {
                            Write-Log "Successfully applied patch."
                        }
                    } catch { Write-Log "An error occurred." }
                }
            }

            $basebrdLangs = Get-ChildItem -Path "C:\Windows\Branding\Basebrd" -Directory -Filter "en-*" -ErrorAction SilentlyContinue
            foreach ($langDir in $basebrdLangs) {
                $muiFile = Join-Path $langDir.FullName "basebrd.dll.mui"
                if (Test-Path $muiFile) {
                    try {
                        & takeown.exe /f $muiFile /a 2>&1 | Out-Null
                        & icacls.exe $muiFile /grant "$($adminGroup):(F)" 2>&1 | Out-Null
                        
                        $muiBytes = [System.IO.File]::ReadAllBytes($muiFile)
                        $muiText = [System.Text.Encoding]::Unicode.GetString($muiBytes)
                        if ($muiText.Contains("Insider Preview") -or $muiText.Contains("Windows 11 Home")) {
                            $patched = $muiText.Replace("Insider Preview", "               ").Replace("Windows 11 Home", "               ")
                            $patchedBytes = [System.Text.Encoding]::Unicode.GetBytes($patched)
                            if ($patchedBytes.Length -eq $muiBytes.Length) {
                                $bakFile = "$muiFile.bak"
                                if (Test-Path $bakFile) { Remove-Item $bakFile -Force -ErrorAction SilentlyContinue }
                                Move-Item -Path $muiFile -Destination $bakFile -Force
                                [System.IO.File]::WriteAllBytes($muiFile, $patchedBytes)
                                Write-Log "Successfully applied patch."
                            }
                        }
                    } catch { Write-Log "An error occurred." }
                }
            }

            try {
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "PaintDesktopVersion" -Value 0 -ErrorAction SilentlyContinue
            } catch {}

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoRestartShell" -Value 1
            Write-Log "Finalizing..."
            Start-Process explorer.exe
        }

        if ($cbTimebomb.Checked) {
            Write-Log "Processing Timebomb..."
            $PkeySource = Join-Path $PSScriptRoot "pkeyconfig.xrm-ms"
            
            if (-not (Test-Path $PkeySource)) {
                Write-Log "Required files missing."
            } else {
                Stop-Service -Name sppsvc -Force -ErrorAction SilentlyContinue
                Stop-Process -Name sppsvc -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 2

                $PkeyTarget = "C:\Windows\System32\spp\tokens\pkeyconfig\pkeyconfig.xrm-ms"
                $adminGroup = (New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")).Translate([System.Security.Principal.NTAccount]).Value
                
                & takeown.exe /f $PkeyTarget /a 2>&1 | Out-Null
                & icacls.exe $PkeyTarget /grant "$($adminGroup):(F)" 2>&1 | Out-Null

                try {
                    $targetObj = Get-Item $PkeyTarget -ErrorAction SilentlyContinue
                    if ($targetObj -and $targetObj.IsReadOnly) { $targetObj.IsReadOnly = $false }
                    Copy-Item -Path $PkeySource -Destination $PkeyTarget -Force
                    Write-Log "Policy applied."
                    
                    Start-Service -Name sppsvc -ErrorAction SilentlyContinue
                    & slmgr.vbs /rilc
                    Write-Log "Verification complete."
                } catch {
                    Write-Log "An error occurred."
                }
            }
        }
        
        Write-Log "Done! You can now close the window."

    } catch {
        Write-Log "Error."
    } finally {
        $btnApply.Enabled = $true
    }
})

$form.ShowDialog() | Out-Null
