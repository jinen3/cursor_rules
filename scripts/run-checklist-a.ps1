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

function Read-Json([string]$path) {
  $t = Read-TextAnyEncoding $path
  $t = $t.TrimStart([char]0xFEFF)
  return $t | ConvertFrom-Json
}

function Read-ChecklistPolicy([string]$updateMdcPath) {
  $text = Read-TextAnyEncoding $updateMdcPath
  $m = [Regex]::Match(
    $text,
    '<!-- CHECKLIST_A_POLICY_START -->\s*```json\s*(?<json>\{[\s\S]*?\})\s*```\s*<!-- CHECKLIST_A_POLICY_END -->',
    [System.Text.RegularExpressions.RegexOptions]::Singleline
  )
  if (-not $m.Success) {
    Fail "Missing CHECKLIST_A_POLICY block in update-management-common.mdc"
  }
  $jsonText = $m.Groups["json"].Value.Trim()
  try {
    return $jsonText | ConvertFrom-Json
  } catch {
    Fail "Invalid JSON in CHECKLIST_A_POLICY block"
  }
}

function Normalize-TextForSpec([string]$text) {
  $norm = $text -replace "`r`n", "`n" -replace "`r", "`n"
  $norm = $norm.TrimEnd("`n")
  return $norm + "`n"
}

function Get-Sha256Hex([string]$text) {
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $hash = $sha.ComputeHash($bytes)
  } finally {
    $sha.Dispose()
  }
  return ([System.BitConverter]::ToString($hash) -replace "-", "").ToLowerInvariant()
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
$updateMdc = Join-Path $rulesDir "update-management-common.mdc"
$tasksTemplate = Join-Path $cursorRules "templates\\vscode_tasks.tasks.json.example"

Step "Checklist A start"
Write-Host ("ProjectRoot: " + $root)
Print-ChecklistA

if (-not (Test-Path -LiteralPath $cursorRules)) {
  Fail ("Missing submodule directory: " + $cursorRules)
}

if (-not (Test-Path -LiteralPath $rulesDir)) {
  Fail ("Missing rules directory: " + $rulesDir)
}

$policy = Read-ChecklistPolicy $updateMdc
$requiredMdc = @($policy.requiredMdc)
$requiredScripts = @($policy.requiredScripts)
$requiredTaskLabels = @($policy.requiredTaskLabels)
$checkFlags = $policy.checks

if ($requiredMdc.Count -eq 0) { Fail "Policy requiredMdc is empty" }
if ($requiredScripts.Count -eq 0) { Fail "Policy requiredScripts is empty" }
if ($requiredTaskLabels.Count -eq 0) { Fail "Policy requiredTaskLabels is empty" }

Step "Check required 6 mdc files"
foreach ($name in $requiredMdc) {
  $p = Join-Path $rulesDir $name
  if (-not (Test-Path -LiteralPath $p)) {
    Fail ("Missing mdc: " + $name)
  }
  Write-Host ("OK: " + $name)
}

Step "Check required scripts from policy"
foreach ($rel in $requiredScripts) {
  $p = Join-Path $cursorRules $rel
  if (-not (Test-Path -LiteralPath $p)) {
    Fail ("Missing script: " + $rel)
  }
  Write-Host ("OK script: " + $rel)
}

Step "Check required task labels from policy"
if (-not (Test-Path -LiteralPath $tasksTemplate)) {
  Fail ("Missing tasks template: " + $tasksTemplate)
}
$tasks = Read-Json $tasksTemplate
$labels = @($tasks.tasks | ForEach-Object { $_.label })
foreach ($label in $requiredTaskLabels) {
  if (-not ($labels -contains $label)) {
    Fail ("Missing task label in template: " + $label)
  }
  Write-Host ("OK task: " + $label)
}

if ($checkFlags.enforceSpecSync) {
  Step "Check 6 mdc content (full-content hash from SPEC)"
  $specPath = Join-Path $cursorRules "spec\\checklist_a_requirements.json"
  if (-not (Test-Path -LiteralPath $specPath)) {
    Fail ("Missing spec file: " + $specPath)
  }
  $spec = Read-Json $specPath

  foreach ($name in $requiredMdc) {
    $p = Join-Path $rulesDir $name
    $t = Read-TextAnyEncoding $p

    $req = $spec.mdc.$name
    if ($null -eq $req) {
      Fail ("Missing spec entry for: " + $name)
    }

    $normalized = Normalize-TextForSpec $t
    $actual = Get-Sha256Hex $normalized
    $expected = [string]$req.sha256
    if ([string]::IsNullOrWhiteSpace($expected)) {
      Fail ("Missing spec sha256 for: " + $name)
    }
    if ($actual -ne $expected) {
      Fail ("Spec mismatch (mdc changed but spec not synced): " + $name)
    }

    Write-Host ("OK content: " + $name)
  }
}

if ($checkFlags.runMarkdownTocFixAndCheck) {
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
}

if (-not $checkFlags.runUnitTestsWhenAvailable) {
  Step "Skip tests (policy disabled)"
} elseif ($SkipTests) {
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

