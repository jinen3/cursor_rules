#Requires -Version 5.1
<#
.SYNOPSIS
  プロジェクト作業開始時: cursor_rules サブモジュールを取得し、必要ならリモート最新へ更新する。

.DESCRIPTION
  - Pattern②: clone 直後は --init で中身を取る。
  - 共通を最新に近づける: --remote で cursor_rules の追跡ブランチ先端へ（親リポジトリに記録されるコミットが変わる場合あり）。

.PARAMETER ProjectRoot
  親リポジトリ（py_tool_daily_report 等）のルート。省略時はカレントディレクトリ。

.PARAMETER SubmodulePath
  サブモジュールのパス（既定: cursor_rules）。

.PARAMETER SkipRemote
  指定時は init のみ（リモート最新への更新はしない）。

.EXAMPLE
  cd D:\pyscript\tool\py_tool_daily_report
  .\path\to\dev-start-cursor-rules.ps1

.EXAMPLE
  .\dev-start-cursor-rules.ps1 -ProjectRoot "D:\pyscript\tool\py_tool_daily_report" -SkipRemote
#>
param(
    [string]$ProjectRoot = "",
    [string]$SubmodulePath = "cursor_rules",
    [switch]$SkipRemote
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = (Get-Location).Path
}
$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path

if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot ".git"))) {
    throw "Git リポジトリのルートではありません: $ProjectRoot"
}

Set-Location -LiteralPath $ProjectRoot

Write-Host "== [1/2] submodule init (fetch/init) ==" -ForegroundColor Cyan
git submodule update --init --recursive

$gitmodules = Join-Path $ProjectRoot ".gitmodules"
if (-not (Test-Path -LiteralPath $gitmodules)) {
    Write-Warning ".gitmodules not found. Run git submodule add first."
    exit 1
}

$subStatus = git submodule status $SubmodulePath 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($subStatus)) {
    Write-Warning ("Submodule not found: {0}. Check .gitmodules path." -f $SubmodulePath)
    exit 1
}

if ($SkipRemote) {
    Write-Host "SkipRemote specified: remote update is skipped." -ForegroundColor Yellow
} else {
    Write-Host "== [2/2] submodule update --remote ($SubmodulePath) ==" -ForegroundColor Cyan
    git submodule update --remote $SubmodulePath
}

Write-Host "`n== submodule status ==" -ForegroundColor Green
git submodule status

Write-Host "`nIf the parent repo shows 'cursor_rules (new commits)', commit/push the submodule pointer if you want to share it." -ForegroundColor DarkGray
