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

function Read-TextAnyEncoding([string]$path) {
  $bytes = [System.IO.File]::ReadAllBytes($path)
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    return [System.Text.Encoding]::UTF8.GetString($bytes)
  }
  $utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
  try {
    return $utf8Strict.GetString($bytes)
  } catch {
    return [System.Text.Encoding]::GetEncoding(932).GetString($bytes)
  }
}

function Assert-Regex([string]$text, [string]$pattern, [string]$message) {
  if (-not [Regex]::IsMatch($text, $pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)) {
    Fail $message
  }
}

function Step([string]$msg) {
  Write-Host ""
  Write-Host ("== " + $msg + " ==")
}

function Print-ChecklistA() {
  Write-Host ""
  Write-Host "[Checklist A]"
  Write-Host "Purpose: prevent skipped checks. Do not mark done without execution."
  Write-Host ""
  Write-Host "1. cursor_rules submodule exists and is fetched."
  Write-Host "2. Required 6 .mdc files exist under .cursor/rules."
  Write-Host "   - venv-only-common.mdc"
  Write-Host "   - errors-debug-unittest-common.mdc"
  Write-Host "   - post-modification-common.mdc"
  Write-Host "   - gui-build-security-common.mdc"
  Write-Host "   - markdown-common.mdc"
  Write-Host "   - update-management-common.mdc"
  Write-Host "3. Markdown TOC rules for all .md files (fix then check)."
  Write-Host "4. Unit tests (pytest/unittest) when .venv and tests/ exist."
  Write-Host ""
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
Print-ChecklistA

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

Step "Check 6 mdc content (not only existence)"
foreach ($name in $requiredMdc) {
  $p = Join-Path $rulesDir $name
  $t = Read-TextAnyEncoding $p

  Assert-Regex $t '^---\s*$' ("Invalid frontmatter start: " + $name)
  if ($name -eq "markdown-common.mdc") {
    Assert-Regex $t '^globs:\s*"\*\*/\*\.md"\s*$' ("Missing markdown globs: " + $name)
    Assert-Regex $t '^alwaysApply:\s*false\s*$' ("markdown-common must be alwaysApply:false")
  } else {
    Assert-Regex $t '^alwaysApply:\s*true\s*$' ("alwaysApply:true missing: " + $name)
  }

  switch ($name) {
    "venv-only-common.mdc" {
      Assert-Regex $t '\.venv' ("venv rule missing .venv mention")
      Assert-Regex $t 'Checklist A|run: checklist A' ("venv rule missing Checklist A enforcement")
    }
    "errors-debug-unittest-common.mdc" {
      Assert-Regex $t 'pytest' ("errors rule missing pytest command")
      Assert-Regex $t 'unittest' ("errors rule missing unittest command")
      Assert-Regex $t 'Checklist A|run: checklist A' ("errors rule missing Checklist A enforcement")
    }
    "post-modification-common.mdc" {
      Assert-Regex $t 'README' ("post-modification missing README requirements")
      Assert-Regex $t 'Checklist A|run: checklist A' ("post-modification missing Checklist A enforcement")
    }
    "gui-build-security-common.mdc" {
      Assert-Regex $t '0\.0\.0\.0' ("gui/security rule missing bind restriction")
      Assert-Regex $t 'Checklist A|run: checklist A' ("gui/security missing Checklist A enforcement")
    }
    "markdown-common.mdc" {
      Assert-Regex $t 'check: markdown toc \(project\)' ("markdown rule missing check task")
      Assert-Regex $t 'fix: markdown toc \(project\)' ("markdown rule missing fix task")
      Assert-Regex $t 'Checklist A|run: checklist A' ("markdown rule missing Checklist A enforcement")
    }
    "update-management-common.mdc" {
      Assert-Regex $t 'cursor_rules' ("update-management missing cursor_rules context")
      Assert-Regex $t 'Checklist A|run: checklist A' ("update-management missing Checklist A enforcement")
    }
  }

  Write-Host ("OK content: " + $name)
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

