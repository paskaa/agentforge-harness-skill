# AgentForge Harness Skill Windows 升级脚本
# 用法:
#   本地升级: .\upgrade.ps1
#   GitHub升级: .\upgrade.ps1 -GitHub

param(
    [switch]$GitHub,
    [string]$CodexHome = "$env:USERPROFILE\.codex"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   AgentForge Harness Skill Upgrader  ║" -ForegroundColor Cyan
Write-Host "║   (Windows PowerShell)               ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$Repo = "paskaa/agentforge-harness-skill"
$TmpDir = Join-Path $env:TEMP "ahs-upgrade-$(Get-Random)"

try {
    # ── 1. 拉取最新版本 ──
    Write-Host "[i] Fetching latest from GitHub..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null

    $url = "https://github.com/$Repo/archive/refs/heads/master.zip"
    $zipFile = Join-Path $TmpDir "master.zip"
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
    Expand-Archive -Path $zipFile -DestinationPath $TmpDir -Force
    $srcDir = Join-Path $TmpDir "$Repo-master"
    Write-Host "[✓] Downloaded to $TmpDir" -ForegroundColor Green

    # 版本信息
    $verFile = Join-Path $srcDir "VERSION"
    if (Test-Path $verFile) {
        $ver = Get-Content $verFile -Raw
        Write-Host "[i] Remote version: $($ver.Trim())" -ForegroundColor Cyan
    }

    # ── 2. 确保目录存在 ──
    New-Item -ItemType Directory -Path "$CodexHome\skills" -Force | Out-Null
    New-Item -ItemType Directory -Path "$CodexHome\plugins" -Force | Out-Null
    New-Item -ItemType Directory -Path "$CodexHome\agents" -Force | Out-Null
    New-Item -ItemType Directory -Path "$CodexHome\rules" -Force | Out-Null

    # ── 3. 更新 Skills ──
    Write-Host ""
    Write-Host "[i] Updating skills..." -ForegroundColor Cyan
    $newCount = 0; $updatedCount = 0; $skippedCount = 0

    Get-ChildItem -Path "$srcDir\skills" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.Name
        $dest = "$CodexHome\skills\$name"

        if (Test-Path $dest) {
            # 已存在 — 对比是否有变化
            $srcHash = (Get-ChildItem $_.FullName -Recurse -File | Get-FileHash -Algorithm MD5 | Sort-Object Hash | ForEach-Object { $_.Hash }) -join ""
            $dstHash = (Get-ChildItem $dest -Recurse -File -ErrorAction SilentlyContinue | Get-FileHash -Algorithm MD5 | Sort-Object Hash | ForEach-Object { $_.Hash }) -join ""

            if ($srcHash -eq $dstHash) {
                $skippedCount++
            } else {
                Copy-Item $_.FullName -Destination $dest -Recurse -Force
                Write-Host "   [✓] Updated: $name" -ForegroundColor Green
                $updatedCount++
            }
        } else {
            Copy-Item $_.FullName -Destination $dest -Recurse
            Write-Host "   [✓] New: $name" -ForegroundColor Green
            $newCount++
        }
    }

    Write-Host "   Skills: $newCount new, $updatedCount updated, $skippedCount unchanged" -ForegroundColor Gray

    # ── 4. 更新 Plugins ──
    Write-Host ""
    Write-Host "[i] Updating plugins..." -ForegroundColor Cyan
    $newCount = 0; $updatedCount = 0; $skippedCount = 0

    Get-ChildItem -Path "$srcDir\plugins" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.Name
        $dest = "$CodexHome\plugins\$name"

        if (Test-Path $dest) {
            $srcHash = (Get-ChildItem $_.FullName -Recurse -File | Get-FileHash -Algorithm MD5 | Sort-Object Hash | ForEach-Object { $_.Hash }) -join ""
            $dstHash = (Get-ChildItem $dest -Recurse -File -ErrorAction SilentlyContinue | Get-FileHash -Algorithm MD5 | Sort-Object Hash | ForEach-Object { $_.Hash }) -join ""

            if ($srcHash -eq $dstHash) {
                $skippedCount++
            } else {
                Copy-Item $_.FullName -Destination $dest -Recurse -Force
                Write-Host "   [✓] Updated: $name" -ForegroundColor Green
                $updatedCount++
            }
        } else {
            Copy-Item $_.FullName -Destination $dest -Recurse
            Write-Host "   [✓] New: $name" -ForegroundColor Green
            $newCount++
        }
    }

    Write-Host "   Plugins: $newCount new, $updatedCount updated, $skippedCount unchanged" -ForegroundColor Gray

    # ── 5. 更新 Agents ──
    if (Test-Path "$srcDir\agents") {
        Write-Host ""
        Write-Host "[i] Updating agents..." -ForegroundColor Cyan
        Copy-Item "$srcDir\agents\*" "$CodexHome\agents\" -Recurse -Force
        Write-Host "   [✓] Agents updated" -ForegroundColor Green
    }

    # ── 6. 更新 Rules ──
    if (Test-Path "$srcDir\rules") {
        Write-Host ""
        Write-Host "[i] Updating rules..." -ForegroundColor Cyan
        Copy-Item "$srcDir\rules\*" "$CodexHome\rules\" -Recurse -Force
        Write-Host "   [✓] Rules updated" -ForegroundColor Green
    }

    # ── Done ──
    Write-Host ""
    Write-Host "══════════════════════════════════════" -ForegroundColor Green
    Write-Host "  Upgrade complete!" -ForegroundColor Green
    Write-Host "══════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Restart Codex CLI to activate new skills." -ForegroundColor Yellow
    Write-Host ""

} finally {
    # 清理临时目录
    if (Test-Path $TmpDir) {
        Remove-Item $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
