#Requires -Version 5.1
<#
.SYNOPSIS
  Create project .vscode/tasks.json as a symlink (preferred) or copy (fallback).

.DESCRIPTION
  VS Code / Cursor reads tasks from: <project>/.vscode/tasks.json
  This script links it to: <project>/cursor_rules/templates/vscode_tasks.tasks.json.example

  On Windows, creating symlinks may require Admin or Developer Mode.
  If symlink creation fails, this script falls back to copying the file and
  writes a marker file: <project>/.vscode/tasks_copy.txt

  NOTE: PowerShell ExecutionPolicy does NOT grant symlink permission.
  If symlink creation is blocked, enable Windows Developer Mode or run as Admin.

.PARAMETER ProjectRoot
  Project (parent repo) root. Defaults to current directory.

.PARAMETER Force
  Overwrite existing .vscode/tasks.json (creates a timestamped backup).
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
    throw ("Not a git repo root: {0}" -f $ProjectRoot)
}

if (-not (Test-Path -LiteralPath $targetPath)) {
    throw ("Target not found (missing/unfetched submodule?): {0}" -f $targetPath)
}

if (-not (Test-Path -LiteralPath $vscodeDir)) {
    New-Item -ItemType Directory -Path $vscodeDir | Out-Null
}

if (Test-Path -LiteralPath $linkPath) {
    if (-not $Force) {
        Write-Host ("Already exists (no changes). Use -Force to overwrite: {0}" -f $linkPath) -ForegroundColor Yellow
        exit 0
    }
    $backup = ("{0}.bak.{1}" -f $linkPath, (Get-Date -Format "yyyyMMdd_HHmmss"))
    $item = Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue
    $isLink = $false
    if ($null -ne $item) {
        try { $isLink = [bool]$item.LinkType } catch { $isLink = $false }
    }

    if ($isLink) {
        # Copy-Item may fail by dereferencing a broken/unresolvable symlink (e.g. in CI checkout).
        Write-Host ("Existing tasks.json is a symlink; skipping backup: {0}" -f $linkPath) -ForegroundColor DarkGray
    } else {
        try {
            Copy-Item -LiteralPath $linkPath -Destination $backup -Force
            Write-Host ("Backed up existing file: {0}" -f $backup) -ForegroundColor DarkGray
        } catch {
            Write-Host ("Backup failed (will overwrite anyway): {0}" -f $_.Exception.Message) -ForegroundColor DarkGray
        }
    }

    Remove-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue
}

try {
    New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath | Out-Null
    Write-Host ("Symlink created: {0} -> {1}" -f $linkPath, $targetPath) -ForegroundColor Green
} catch {
    Write-Host "Symlink creation failed. Falling back to COPY." -ForegroundColor Yellow
    Write-Host ("Reason: {0}" -f $_.Exception.Message) -ForegroundColor DarkGray
    Write-Host "Hint: enable Windows Developer Mode or run PowerShell as Admin for symlinks." -ForegroundColor DarkGray

    Copy-Item -LiteralPath $targetPath -Destination $linkPath -Force
    Write-Host ("Copied: {0}" -f $linkPath) -ForegroundColor Yellow

    $markerPath = Join-Path $vscodeDir "tasks_copy.txt"
    $timestamp = (Get-Date).ToString("s")
    $markerBody = @"
This project uses a COPIED tasks.json (not a symlink).
Copied from: $targetPath
Copied to:   $linkPath
Copied at:   $timestamp
"@
    Set-Content -LiteralPath $markerPath -Value $markerBody -Encoding UTF8
    Write-Host ("Marker file created: {0}" -f $markerPath) -ForegroundColor Yellow
}

