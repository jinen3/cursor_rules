#Requires -Version 5.1
<#
.SYNOPSIS
  プロジェクト側に .vscode/tasks.json のリンクを作る（コピーしない運用）。

.DESCRIPTION
  VS Code/Cursor の Task は通常「プロジェクト側の .vscode/tasks.json」を参照する。
  共通リポジトリ（cursor_rules）側の Task 定義をそのまま使いたい場合、
  プロジェクト側に tasks.json のシンボリックリンクを作るのが現実解。

  注意: Windows は設定によりシンボリックリンク作成に管理者権限や「開発者モード」が必要な場合がある。
  その場合は「代わりに」コピーを作成する（コピー運用は共通更新が自動反映されない）。

.PARAMETER ProjectRoot
  親リポジトリ（プロジェクト）ルート。省略時はカレントディレクトリ。

.PARAMETER Force
  既存の .vscode/tasks.json がある場合に上書きする（バックアップを作成）。
#>
param(
    [string]$ProjectRoot = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = (Get-Location).Path
}
$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path

$vscodeDir = Join-Path $ProjectRoot ".vscode"
$linkPath = Join-Path $vscodeDir "tasks.json"
$targetPath = Join-Path $ProjectRoot "cursor_rules\\templates\\vscode_tasks.tasks.json.example"

if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot ".git"))) {
    throw "Git リポジトリのルートではありません: $ProjectRoot"
}

if (-not (Test-Path -LiteralPath $targetPath)) {
    throw "リンク先が見つかりません（cursor_rules サブモジュールが無い/未取得の可能性）: $targetPath"
}

if (-not (Test-Path -LiteralPath $vscodeDir)) {
    New-Item -ItemType Directory -Path $vscodeDir | Out-Null
}

if (Test-Path -LiteralPath $linkPath) {
    if (-not $Force) {
        Write-Host "既に存在します（何もしません）。上書きするなら -Force を指定: $linkPath" -ForegroundColor Yellow
        exit 0
    }
    $backup = "$linkPath.bak.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -LiteralPath $linkPath -Destination $backup -Force
    Remove-Item -LiteralPath $linkPath -Force
    Write-Host "既存をバックアップしました: $backup" -ForegroundColor DarkGray
}

try {
    New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath | Out-Null
    Write-Host "シンボリックリンクを作成しました: $linkPath -> $targetPath" -ForegroundColor Green
} catch {
    Write-Host "シンボリックリンク作成に失敗しました。代わりにコピーを作成します。" -ForegroundColor Yellow
    Write-Host "理由: $($_.Exception.Message)" -ForegroundColor DarkGray
    Copy-Item -LiteralPath $targetPath -Destination $linkPath -Force
    Write-Host "コピーを作成しました（注意: 共通更新は自動反映されません）: $linkPath" -ForegroundColor Yellow
}

