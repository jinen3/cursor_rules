param(
  [Parameter(Mandatory = $false)]
  [string]$ProjectRoot = ".",

  [Parameter(Mandatory = $false)]
  [switch]$SkipTests
)

$ErrorActionPreference = "Stop"

function Resolve-AbsPath([string]$path) {
  return (Resolve-Path -LiteralPath $path).Path
}

function Step([string]$msg) {
  Write-Host ""
  Write-Host ("== " + $msg + " ==")
}

function Fail([string]$msg) {
  Write-Host ("FAIL: " + $msg)
  exit 1
}

$root = Resolve-AbsPath $ProjectRoot
$cursorRules = Join-Path $root "cursor_rules"
$rulesDir = Join-Path $cursorRules ".cursor\\rules"

Step "Checklist A start"
Write-Host ("ProjectRoot: " + $root)

if (-not (Test-Path -LiteralPath $cursorRules)) {
  Fail ("Missing submodule directory: " + $cursorRules)
}

if (-not (Test-Path -LiteralPath $rulesDir)) {
  Fail ("Missing rules directory: " + $rulesDir)
}

$requiredMdc = @(
  "venv-only-common.mdc",
  "errors-debug-unittest-common.mdc",
  "post-modification-common.mdc",
  "gui-build-security-common.mdc",
  "markdown-common.mdc",
  "update-management-common.mdc"
)

Step "Check required 6 mdc files"
foreach ($name in $requiredMdc) {
  $p = Join-Path $rulesDir $name
  if (-not (Test-Path -LiteralPath $p)) {
    Fail ("Missing mdc: " + $name)
  }
  Write-Host ("OK: " + $name)
}

Step "Check markdown TOC (auto-fix then re-check)"
$tocScript = Join-Path $cursorRules "scripts\\check-markdown-toc.ps1"
if (-not (Test-Path -LiteralPath $tocScript)) {
  Fail ("Missing script: " + $tocScript)
}

powershell -ExecutionPolicy Bypass -File $tocScript -RootPath $root -Fix
if ($LASTEXITCODE -ne 0) {
  Fail "TOC fix phase failed."
}

powershell -ExecutionPolicy Bypass -File $tocScript -RootPath $root
if ($LASTEXITCODE -ne 0) {
  Fail "TOC check phase failed after auto-fix."
}

if ($SkipTests) {
  Step "Skip tests (requested)"
} else {
  Step "Run unit tests with .venv python if available"
  $venvPython = Join-Path $root ".venv\\Scripts\\python.exe"
  $testsDir = Join-Path $root "tests"
  if ((Test-Path -LiteralPath $venvPython) -and (Test-Path -LiteralPath $testsDir)) {
    & $venvPython -m pytest -q
    if ($LASTEXITCODE -ne 0) {
      Write-Host "pytest failed. Trying unittest discovery."
      & $venvPython -m unittest discover -s tests -v
      if ($LASTEXITCODE -ne 0) {
        Fail "Both pytest and unittest failed."
      }
    }
    Write-Host "OK: Unit tests passed."
  } else {
    Write-Host "SKIP: tests not run (.venv or tests directory missing)."
  }
}

Step "Checklist A completed"
Write-Host "OK: Checklist A passed."
exit 0

