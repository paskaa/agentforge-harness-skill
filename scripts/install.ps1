# AgentForge Harness Engineering Windows 安装脚本
# 用法: 
#   本地安装: .\install.ps1
#   GitHub安装: .\install.ps1 -GitHub

param(
    [switch]$GitHub,
    [string]$CodexHome = "$env:USERPROFILE\.codex"
)

Write-Host "🔧 AgentForge Harness Engineering 安装器 (Windows)" -ForegroundColor Cyan
Write-Host "========================================="

$Repo = "paskaa/agentforge-harness-skill"

if ($GitHub) {
    Write-Host "📥 从 GitHub 下载..." -ForegroundColor Yellow
    $tmpDir = Join-Path $env:TEMP "agentforge-harness-$(Get-Random)"
    New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
    
    $url = "https://github.com/$Repo/archive/refs/heads/master.zip"
    $zipFile = Join-Path $tmpDir "master.zip"
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $tmpDir -Force
    $scriptDir = Join-Path $tmpDir "agentforge-harness-skill-master"
} else {
    Write-Host "📁 从本地安装..." -ForegroundColor Yellow
    $scriptDir = Split-Path -Parent $PSScriptRoot
    if (-not $scriptDir) { $scriptDir = Split-Path -Parent (Get-Location) }
}

Write-Host "安装目录: $CodexHome"

# 创建目录
New-Item -ItemType Directory -Path "$CodexHome\rules" -Force | Out-Null
New-Item -ItemType Directory -Path "$CodexHome\skills" -Force | Out-Null

# 安装铁律
Write-Host "📋 安装铁律..." -ForegroundColor Green
Copy-Item "$scriptDir\rules\IRON_LAWS.md" "$CodexHome\rules\" -Force
Write-Host "   ✅ IRON_LAWS.md"

# 安装技能
Write-Host "📦 安装技能..." -ForegroundColor Green
Get-ChildItem -Path "$scriptDir\skills" -Directory | ForEach-Object {
    $dest = "$CodexHome\skills\$($_.Name)"
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    Copy-Item $_.FullName -Destination $dest -Recurse
    Write-Host "   ✅ $($_.Name)"
}

# 清理
if ($GitHub -and $tmpDir) { Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host ""
Write-Host "🎉 安装完成！" -ForegroundColor Cyan
Write-Host ""
Write-Host "使用方法:" -ForegroundColor Yellow
Write-Host "  1. 打开 Codex CLI"
Write-Host "  2. 执行任务时铁律会自动加载"
Write-Host "  3. 查看铁律: type $CodexHome\rules\IRON_LAWS.md"
