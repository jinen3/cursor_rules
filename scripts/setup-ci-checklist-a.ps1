#Requires -Version 5.1
<#
.SYNOPSIS
  Install Checklist A GitHub Actions workflow into a project.

.DESCRIPTION
  Copies cursor_rules workflow template into:
    <project>/.github/workflows/checklist-a.yml

  This is a project-side file (committed in the parent repo).
  After installing, enforce it via branch protection (require checks).

.PARAMETER ProjectRoot
  Parent repo root. Defaults to current directory.

.PARAMETER Force
  Overwrite existing workflow file (creates a timestamped backup).
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

if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot ".git"))) {
  throw ("Not a git repo root: {0}" -f $ProjectRoot)
}

$template = Join-Path $ProjectRoot "cursor_rules\templates\github_workflows_checklist_a.yml.example"
if (-not (Test-Path -LiteralPath $template)) {
  throw ("Template not found (missing/unfetched submodule?): {0}" -f $template)
}

$wfDir = Join-Path $ProjectRoot ".github\workflows"
$wfPath = Join-Path $wfDir "checklist-a.yml"

if (-not (Test-Path -LiteralPath $wfDir)) {
  New-Item -ItemType Directory -Path $wfDir | Out-Null
}

if (Test-Path -LiteralPath $wfPath) {
  if (-not $Force) {
    Write-Host ("Already exists (no changes). Use -Force to overwrite: {0}" -f $wfPath) -ForegroundColor Yellow
    exit 0
  }
  $backup = ("{0}.bak.{1}" -f $wfPath, (Get-Date -Format "yyyyMMdd_HHmmss"))
  Copy-Item -LiteralPath $wfPath -Destination $backup -Force
  Write-Host ("Backed up existing file: {0}" -f $backup) -ForegroundColor DarkGray
}

Copy-Item -LiteralPath $template -Destination $wfPath -Force
Write-Host ("Installed workflow: {0}" -f $wfPath) -ForegroundColor Green

Write-Host ""
Write-Host "Next steps (recommended):" -ForegroundColor Cyan
Write-Host "- Commit/push the workflow in the parent repo." -ForegroundColor Cyan
Write-Host "- If cursor_rules is a PRIVATE GitHub repo: add repo secret SUBMODULES_PAT (PAT can read parent + cursor_rules)." -ForegroundColor Cyan
Write-Host "- In GitHub branch protection, require the 'checklist-a' check before merge." -ForegroundColor Cyan

