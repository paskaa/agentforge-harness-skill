# AgentForge Harness Skill Windows 安装脚本
# 用法:
#   本地安装: .\install.ps1
#   GitHub安装: .\install.ps1 -GitHub

param(
    [switch]$GitHub,
    [string]$CodexHome = "$env:USERPROFILE\.codex"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   AgentForge Harness Skill Installer ║" -ForegroundColor Cyan
Write-Host "║   (Windows PowerShell)               ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$Repo = "paskaa/agentforge-harness-skill"

if ($GitHub) {
    Write-Host "[i] Downloading from GitHub..." -ForegroundColor Cyan
    $tmpDir = Join-Path $env:TEMP "ahs-install-$(Get-Random)"
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

    $url = "https://github.com/$Repo/archive/refs/heads/master.zip"
    $zipFile = Join-Path $tmpDir "master.zip"
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $tmpDir -Force
    $scriptDir = Join-Path $tmpDir "$Repo-master"
} else {
    Write-Host "[i] Installing from local..." -ForegroundColor Cyan
    $scriptDir = Split-Path -Parent $PSScriptRoot
    if (-not $scriptDir) { $scriptDir = Split-Path -Parent (Get-Location) }
}

Write-Host "[i] Codex home: $CodexHome" -ForegroundColor Cyan

# 创建目录
New-Item -ItemType Directory -Path "$CodexHome\skills" -Force | Out-Null
New-Item -ItemType Directory -Path "$CodexHome\plugins" -Force | Out-Null
New-Item -ItemType Directory -Path "$CodexHome\agents" -Force | Out-Null
New-Item -ItemType Directory -Path "$CodexHome\rules" -Force | Out-Null

# 安装 Skills
Write-Host ""
Write-Host "[i] Installing skills..." -ForegroundColor Cyan
$count = 0
Get-ChildItem -Path "$scriptDir\skills" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    if (Test-Path "$CodexHome\skills\$($_.Name)") {
        Write-Host "   [!] Skipped (exists): $($_.Name)" -ForegroundColor Yellow
    } else {
        Copy-Item $_.FullName -Destination "$CodexHome\skills\$($_.Name)" -Recurse
        Write-Host "   [✓] $($_.Name)" -ForegroundColor Green
        $count++
    }
}
Write-Host "   Installed $count new skills" -ForegroundColor Gray

# 安装 Plugins
Write-Host ""
Write-Host "[i] Installing plugins..." -ForegroundColor Cyan
$count = 0
Get-ChildItem -Path "$scriptDir\plugins" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    if (Test-Path "$CodexHome\plugins\$($_.Name)") {
        Write-Host "   [!] Skipped (exists): $($_.Name)" -ForegroundColor Yellow
    } else {
        Copy-Item $_.FullName -Destination "$CodexHome\plugins\$($_.Name)" -Recurse
        Write-Host "   [✓] $($_.Name)" -ForegroundColor Green
        $count++
    }
}
Write-Host "   Installed $count new plugins" -ForegroundColor Gray

# 安装 Agents
if (Test-Path "$scriptDir\agents") {
    Write-Host ""
    Write-Host "[i] Installing agents..." -ForegroundColor Cyan
    Copy-Item "$scriptDir\agents\*" "$CodexHome\agents\" -Recurse -Force
    Write-Host "   [✓] Agents installed" -ForegroundColor Green
}

# 安装 Rules
if (Test-Path "$scriptDir\rules") {
    Write-Host ""
    Write-Host "[i] Installing rules..." -ForegroundColor Cyan
    Copy-Item "$scriptDir\rules\*" "$CodexHome\rules\" -Recurse -Force
    Write-Host "   [✓] Rules installed" -ForegroundColor Green
}

# 清理
if ($GitHub -and $tmpDir) { Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host ""
Write-Host "══════════════════════════════════════" -ForegroundColor Green
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host "══════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "  Restart Codex CLI to activate." -ForegroundColor Yellow
Write-Host ""
