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

function Is-ConditionMet([string]$requiredWhen, [string]$venvPython, [string]$testsDir) {
  switch ($requiredWhen) {
    "always" { return $true }
    "venv_exists" { return (Test-Path -LiteralPath $venvPython) }
    "venv_and_tests_exist" { return ((Test-Path -LiteralPath $venvPython) -and (Test-Path -LiteralPath $testsDir)) }
    default { return $true }
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
$updateMdc = Join-Path $rulesDir "update-management-common.mdc"
$tasksTemplate = Join-Path $cursorRules "templates\\vscode_tasks.tasks.json.example"
$projectTasksPath = Join-Path $root ".vscode\\tasks.json"
$gitmodulesPath = Join-Path $root ".gitmodules"

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
$coverageTargets = @()
if ($policy.PSObject.Properties.Name -contains "coverageTargets") {
  $coverageTargets = @($policy.coverageTargets)
}
$requirementIdsMap = $null
if ($policy.PSObject.Properties.Name -contains "requirementIds") {
  $requirementIdsMap = $policy.requirementIds
}
$manualRequirementIds = @()
if ($policy.PSObject.Properties.Name -contains "manualRequirementIds") {
  $manualRequirementIds = @($policy.manualRequirementIds)
}
$runtimeChecks = @()
if ($policy.PSObject.Properties.Name -contains "runtimeChecks") {
  foreach ($rc in @($policy.runtimeChecks)) {
    if ($null -ne $rc) {
      $runtimeChecks += $rc
    }
  }
}

$venvPython = Join-Path $root ".venv\\Scripts\\python.exe"
$testsDir = Join-Path $root "tests"

if ($checkFlags.requireTestEnvironment) {
  if (-not (Test-Path -LiteralPath $venvPython)) {
    Fail "Strict mode: .venv python is required."
  }
  if (-not (Test-Path -LiteralPath $testsDir)) {
    Fail "Strict mode: tests directory is required."
  }
}

if ($requiredMdc.Count -eq 0) { Fail "Policy requiredMdc is empty" }
if ($requiredScripts.Count -eq 0) { Fail "Policy requiredScripts is empty" }
if ($requiredTaskLabels.Count -eq 0) { Fail "Policy requiredTaskLabels is empty" }
if ($checkFlags.enforceCoverageMap -and $coverageTargets.Count -eq 0) { Fail "Policy coverageTargets is empty" }
if ($checkFlags.enforceRequirementMap -and $null -eq $requirementIdsMap) { Fail "Policy requirementIds is missing" }
if ($checkFlags.enforceRequirementClassification -and $null -eq $requirementIdsMap) { Fail "Policy requirementIds is missing" }

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

if ($checkFlags.enforceCoverageMap) {
  Step "Check coverage map (mdc -> runtime checks)"
  $covered = New-Object System.Collections.Generic.HashSet[string]
  foreach ($rc in $runtimeChecks) {
    if ($rc.PSObject.Properties.Name -contains "covers") {
      foreach ($c in @($rc.covers)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$c)) {
          [void]$covered.Add([string]$c)
        }
      }
    }
  }
  foreach ($target in $coverageTargets) {
    if (-not $covered.Contains([string]$target)) {
      Fail ("Coverage gap: no runtime check covers " + $target)
    }
    Write-Host ("OK coverage: " + $target)
  }
}

if ($checkFlags.enforceRequirementMap) {
  Step "Check requirement map (requirement id -> runtime checks)"
  $allReqIds = New-Object System.Collections.Generic.HashSet[string]
  foreach ($mdcName in $requirementIdsMap.PSObject.Properties.Name) {
    foreach ($rid in @($requirementIdsMap.$mdcName)) {
      if (-not [string]::IsNullOrWhiteSpace([string]$rid)) {
        [void]$allReqIds.Add([string]$rid)
      }
    }
  }
  $coveredReqIds = New-Object System.Collections.Generic.HashSet[string]
  foreach ($rc in $runtimeChecks) {
    if ($rc.PSObject.Properties.Name -contains "coversReqs") {
      foreach ($rid in @($rc.coversReqs)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$rid)) {
          [void]$coveredReqIds.Add([string]$rid)
        }
      }
    }
  }
  foreach ($rid in $manualRequirementIds) {
    if (-not [string]::IsNullOrWhiteSpace([string]$rid)) {
      [void]$coveredReqIds.Add([string]$rid)
    }
  }
  foreach ($rid in $allReqIds) {
    if (-not $coveredReqIds.Contains($rid)) {
      Fail ("Requirement coverage gap: " + $rid)
    }
    Write-Host ("OK requirement: " + $rid)
  }
}

if ($checkFlags.enforceRequirementClassification) {
  Step "Check requirement classification (auto vs manual)"
  $allReqIds = New-Object System.Collections.Generic.HashSet[string]
  foreach ($mdcName in $requirementIdsMap.PSObject.Properties.Name) {
    foreach ($rid in @($requirementIdsMap.$mdcName)) {
      if (-not [string]::IsNullOrWhiteSpace([string]$rid)) {
        [void]$allReqIds.Add([string]$rid)
      }
    }
  }
  $autoReqIds = New-Object System.Collections.Generic.HashSet[string]
  foreach ($rc in $runtimeChecks) {
    if ($rc.PSObject.Properties.Name -contains "coversReqs") {
      foreach ($rid in @($rc.coversReqs)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$rid)) {
          [void]$autoReqIds.Add([string]$rid)
        }
      }
    }
  }
  $manualReqIds = New-Object System.Collections.Generic.HashSet[string]
  foreach ($rid in $manualRequirementIds) {
    if (-not [string]::IsNullOrWhiteSpace([string]$rid)) {
      [void]$manualReqIds.Add([string]$rid)
    }
  }

  foreach ($rid in $allReqIds) {
    $isAuto = $autoReqIds.Contains($rid)
    $isManual = $manualReqIds.Contains($rid)
    if (-not ($isAuto -or $isManual)) {
      Fail ("Requirement classification gap: " + $rid)
    }
    if ($isAuto -and $isManual) {
      Fail ("Requirement classified as both auto/manual: " + $rid)
    }
    if ($isManual) {
      Write-Host ("OK requirement(manual): " + $rid)
    } else {
      Write-Host ("OK requirement(auto): " + $rid)
    }
  }
}

if ($runtimeChecks.Count -gt 0) {
  Step "Run runtime checks from policy"
  foreach ($rc in $runtimeChecks) {
    $id = [string]$rc.id
    $type = [string]$rc.type
    $requiredWhen = [string]$rc.requiredWhen
    if ([string]::IsNullOrWhiteSpace($requiredWhen)) {
      $requiredWhen = "always"
    }

    if ([string]::IsNullOrWhiteSpace($type)) {
      Fail ("runtime check type is empty: " + $id)
    }

    if (-not (Is-ConditionMet $requiredWhen $venvPython $testsDir)) {
      Write-Host ("SKIP runtime check (" + $id + "): condition not met -> " + $requiredWhen)
      continue
    }

    switch ($type) {
      "venv_python_prefix_contains" {
        $expected = [string]$rc.expectedSubstring
        if ([string]::IsNullOrWhiteSpace($expected)) {
          Fail ("runtime check missing expectedSubstring: " + $id)
        }
        $prefix = & $venvPython -c "import sys; print(sys.prefix)"
        if ($LASTEXITCODE -ne 0) {
          Fail ("runtime check failed to execute python: " + $id)
        }
        if (-not ($prefix -match [Regex]::Escape($expected))) {
          Fail ("runtime check failed: " + $id + " (prefix does not contain " + $expected + ")")
        }
        Write-Host ("OK runtime: " + $id)
      }
      "venv_pip_path_contains" {
        $expected = [string]$rc.expectedSubstring
        if ([string]::IsNullOrWhiteSpace($expected)) {
          Fail ("runtime check missing expectedSubstring: " + $id)
        }
        $pipv = & $venvPython -m pip --version
        if ($LASTEXITCODE -ne 0) {
          Fail ("runtime check failed to execute pip: " + $id)
        }
        if (-not ($pipv -match [Regex]::Escape($expected))) {
          Fail ("runtime check failed: " + $id + " (pip path does not contain " + $expected + ")")
        }
        Write-Host ("OK runtime: " + $id)
      }
      "venv_test_runner" {
        if ($SkipTests) {
          Write-Host ("SKIP runtime check (" + $id + "): SkipTests requested")
          break
        }
        & $venvPython -m pytest -q
        if ($LASTEXITCODE -ne 0) {
          Write-Host "pytest failed. Trying unittest discovery."
          & $venvPython -m unittest discover -s tests -v
          if ($LASTEXITCODE -ne 0) {
            Fail ("runtime test check failed: " + $id)
          }
        }
        Write-Host ("OK runtime: " + $id)
      }
      "project_tasks_has_labels" {
        if (-not (Test-Path -LiteralPath $projectTasksPath)) {
          Fail ("runtime check failed: " + $id + " (.vscode/tasks.json missing)")
        }
        $projTasks = Read-Json $projectTasksPath
        $projLabels = @($projTasks.tasks | ForEach-Object { $_.label })
        foreach ($label in $requiredTaskLabels) {
          if (-not ($projLabels -contains $label)) {
            Fail ("runtime check failed: " + $id + " (missing task label: " + $label + ")")
          }
        }
        Write-Host ("OK runtime: " + $id)
      }
      "project_checklist_task_wired" {
        if (-not (Test-Path -LiteralPath $projectTasksPath)) {
          Fail ("runtime check failed: " + $id + " (.vscode/tasks.json missing)")
        }
        $projTasks = Read-Json $projectTasksPath
        $task = $projTasks.tasks | Where-Object { $_.label -eq "run: checklist A (all rules)" } | Select-Object -First 1
        if ($null -eq $task) {
          Fail ("runtime check failed: " + $id + " (task label not found)")
        }
        if ([string]$task.command -ne "powershell") {
          Fail ("runtime check failed: " + $id + " (task command is not powershell)")
        }
        $argsText = (@($task.args) -join " ")
        if (-not ($argsText -match [Regex]::Escape("cursor_rules\\scripts\\run-checklist-a.ps1"))) {
          Fail ("runtime check failed: " + $id + " (run-checklist-a.ps1 not wired)")
        }
        if (-not ($argsText -match [Regex]::Escape("-ProjectRoot"))) {
          Fail ("runtime check failed: " + $id + " (-ProjectRoot missing)")
        }
        Write-Host ("OK runtime: " + $id)
      }
      "project_checklist_task_no_skiptests" {
        if (-not (Test-Path -LiteralPath $projectTasksPath)) {
          Fail ("runtime check failed: " + $id + " (.vscode/tasks.json missing)")
        }
        $projTasks = Read-Json $projectTasksPath
        $task = $projTasks.tasks | Where-Object { $_.label -eq "run: checklist A (all rules)" } | Select-Object -First 1
        if ($null -eq $task) {
          Fail ("runtime check failed: " + $id + " (task label not found)")
        }
        $argsText = (@($task.args) -join " ")
        if ($argsText -match [Regex]::Escape("-SkipTests")) {
          Fail ("runtime check failed: " + $id + " (-SkipTests must not be in run task)")
        }
        Write-Host ("OK runtime: " + $id)
      }
      "project_has_cursor_rules_submodule_entry" {
        if (-not (Test-Path -LiteralPath $gitmodulesPath)) {
          Fail ("runtime check failed: " + $id + " (.gitmodules missing)")
        }
        $gitmodulesText = Read-TextAnyEncoding $gitmodulesPath
        if (-not ($gitmodulesText -match 'path\s*=\s*cursor_rules')) {
          Fail ("runtime check failed: " + $id + " (.gitmodules has no cursor_rules path)")
        }
        $subStatus = git -C $root submodule status cursor_rules
        if ($LASTEXITCODE -ne 0) {
          Fail ("runtime check failed: " + $id + " (git submodule status failed)")
        }
        Write-Host ("OK runtime: " + $id)
      }
      "sync_spec_script_runs" {
        $syncScript = Join-Path $cursorRules "scripts\\sync-checklist-a-spec.ps1"
        if (-not (Test-Path -LiteralPath $syncScript)) {
          Fail ("runtime check failed: " + $id + " (sync script missing)")
        }
        powershell -NoProfile -ExecutionPolicy Bypass -File $syncScript -RootPath $cursorRules | Out-Null
        if ($LASTEXITCODE -ne 0) {
          Fail ("runtime check failed: " + $id + " (sync script execution failed)")
        }
        Write-Host ("OK runtime: " + $id)
      }
      "toc_check_script_runs" {
        $tocScript = Join-Path $cursorRules "scripts\\check-markdown-toc.ps1"
        if (-not (Test-Path -LiteralPath $tocScript)) {
          Fail ("runtime check failed: " + $id + " (TOC script missing)")
        }
        powershell -NoProfile -ExecutionPolicy Bypass -File $tocScript -RootPath $root | Out-Null
        if ($LASTEXITCODE -ne 0) {
          Fail ("runtime check failed: " + $id + " (TOC check script failed)")
        }
        Write-Host ("OK runtime: " + $id)
      }
      "project_docs_minimum_present" {
        $readmeMd = Join-Path $root "README.md"
        $readmeTxt = Join-Path $root "readme.txt"
        $hasReadme = (Test-Path -LiteralPath $readmeMd) -or (Test-Path -LiteralPath $readmeTxt)
        if (-not $hasReadme) {
          Fail ("runtime check failed: " + $id + " (README.md/readme.txt not found)")
        }
        $textbookFiles = Get-ChildItem -LiteralPath $root -File -Filter "textbook_*_project.md" -ErrorAction SilentlyContinue
        $legacyStudyFiles = @(
          (Join-Path $root "01_overview.md"),
          (Join-Path $root "02_error_handling.md"),
          (Join-Path $root "03_detailed_guide.md"),
          (Join-Path $root "DEBUG_GUIDE.md")
        )
        $hasLegacyStudy = $false
        foreach ($p in $legacyStudyFiles) {
          if (Test-Path -LiteralPath $p) {
            $hasLegacyStudy = $true
            break
          }
        }
        $hasTextbook = ($null -ne $textbookFiles) -and ($textbookFiles.Count -ge 1)
        if (-not ($hasTextbook -or $hasLegacyStudy)) {
          Fail ("runtime check failed: " + $id + " (no project study docs found)")
        }
        Write-Host ("OK runtime: " + $id)
      }
      "project_no_open_bind" {
        $hits = Get-ChildItem -LiteralPath $root -Recurse -File -Include *.py,*.ps1,*.json,*.yml,*.yaml -ErrorAction SilentlyContinue |
          Where-Object { $_.FullName -notmatch [Regex]::Escape("\cursor_rules\") } |
          Select-String -Pattern '0\.0\.0\.0' -SimpleMatch:$false -List
        if ($null -ne $hits -and $hits.Count -gt 0) {
          Fail ("runtime check failed: " + $id + " (found 0.0.0.0 bind in project files)")
        }
        Write-Host ("OK runtime: " + $id)
      }
      "project_tasks_use_cursor_rules_scripts" {
        if (-not (Test-Path -LiteralPath $projectTasksPath)) {
          Fail ("runtime check failed: " + $id + " (.vscode/tasks.json missing)")
        }
        $rawTasksJson = Read-TextAnyEncoding $projectTasksPath
        $requiredRefs = @(
          "cursor_rules\\\\scripts\\\\run-checklist-a.ps1",
          "cursor_rules\\\\scripts\\\\check-markdown-toc.ps1",
          "cursor_rules\\\\scripts\\\\dev-start-cursor-rules.ps1"
        )
        foreach ($ref in $requiredRefs) {
          if (-not ($rawTasksJson -match [Regex]::Escape($ref))) {
            Fail ("runtime check failed: " + $id + " (missing script reference: " + $ref + ")")
          }
        }
        Write-Host ("OK runtime: " + $id)
      }
      "submodule_at_origin_main" {
        $head = (git -C $cursorRules rev-parse HEAD).Trim()
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($head)) {
          Fail ("runtime check failed: " + $id + " (cannot read submodule HEAD)")
        }
        git -C $cursorRules fetch origin main --quiet
        if ($LASTEXITCODE -ne 0) {
          Fail ("runtime check failed: " + $id + " (cannot fetch origin/main)")
        }
        $originHead = (git -C $cursorRules rev-parse origin/main).Trim()
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($originHead)) {
          Fail ("runtime check failed: " + $id + " (cannot read origin/main)")
        }
        if ($head -ne $originHead) {
          Fail ("runtime check failed: " + $id + " (submodule is not at origin/main HEAD)")
        }
        Write-Host ("OK runtime: " + $id)
      }
      "submodule_clean_worktree" {
        $subRaw = git -C $cursorRules status --porcelain
        if ($LASTEXITCODE -ne 0) {
          Fail ("runtime check failed: " + $id + " (cannot read submodule status)")
        }
        $subStatus = ""
        if ($null -ne $subRaw) {
          $subStatus = ($subRaw | Out-String).Trim()
        }
        if (-not [string]::IsNullOrWhiteSpace($subStatus)) {
          Fail ("runtime check failed: " + $id + " (submodule has local changes)")
        }
        Write-Host ("OK runtime: " + $id)
      }
      "no_project_rule_copies" {
        $projectRulesDir = Join-Path $root ".cursor\\rules"
        if (Test-Path -LiteralPath $projectRulesDir) {
          foreach ($name in $requiredMdc) {
            $copyPath = Join-Path $projectRulesDir $name
            if (Test-Path -LiteralPath $copyPath) {
              Fail ("runtime check failed: " + $id + " (copied common mdc found: " + $copyPath + ")")
            }
          }
        }
        Write-Host ("OK runtime: " + $id)
      }
      default {
        Fail ("Unknown runtime check type: " + $type)
      }
    }
  }
}

if (-not $checkFlags.runUnitTestsWhenAvailable) {
  Step "Skip tests (policy disabled)"
} elseif ($SkipTests) {
  if ($checkFlags.requireTestEnvironment) {
    Fail "Strict mode: -SkipTests is not allowed."
  }
  Step "Skip tests (requested)"
} else {
  Step "Run unit tests with .venv python if available"
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

