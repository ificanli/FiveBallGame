$ErrorActionPreference = 'Stop'
$godot = 'C:\Users\luxinyu\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.1-stable_win64.exe'
$project = Split-Path -Parent $MyInvocation.MyCommand.Path
$log = Join-Path $project 'godot-launch-error.log'

try {
    if (-not (Test-Path -LiteralPath $godot)) {
        throw "Godot 4.7.1 not found: $godot"
    }
    $process = Start-Process -FilePath $godot -ArgumentList @('--editor', '--path', $project) -WorkingDirectory $project -PassThru
    Start-Sleep -Milliseconds 800
    if ($process.HasExited) {
        throw "Godot exited immediately with code $($process.ExitCode)."
    }
} catch {
    $_ | Out-String | Set-Content -LiteralPath $log -Encoding UTF8
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("Godot 启动失败。错误已写入：`n$log`n`n$($_.Exception.Message)", '五球满贯') | Out-Null
    exit 1
}
