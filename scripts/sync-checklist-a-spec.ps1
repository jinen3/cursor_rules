param(
  [Parameter(Mandatory = $false)]
  [string]$RootPath = "."
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

$root = Resolve-AbsPath $RootPath
$rulesDir = Join-Path $root ".cursor\\rules"
$specDir = Join-Path $root "spec"
$specPath = Join-Path $specDir "checklist_a_requirements.json"

if (-not (Test-Path -LiteralPath $rulesDir)) {
  throw ("Missing rules directory: " + $rulesDir)
}
if (-not (Test-Path -LiteralPath $specDir)) {
  New-Item -ItemType Directory -Path $specDir | Out-Null
}

$requiredMdc = @(
  "venv-only-common.mdc",
  "errors-debug-unittest-common.mdc",
  "post-modification-common.mdc",
  "gui-build-security-common.mdc",
  "markdown-common.mdc",
  "update-management-common.mdc"
)

$mdcMap = [ordered]@{}
foreach ($name in $requiredMdc) {
  $p = Join-Path $rulesDir $name
  if (-not (Test-Path -LiteralPath $p)) {
    throw ("Missing mdc: " + $name)
  }
  $raw = Read-TextAnyEncoding $p
  $normalized = Normalize-TextForSpec $raw
  $mdcMap[$name] = [ordered]@{
    sha256 = (Get-Sha256Hex $normalized)
    bytes_utf8_normalized = ([System.Text.Encoding]::UTF8.GetByteCount($normalized))
  }
}

$out = [ordered]@{
  spec_version = 1
  source_of_truth = "mdc-files"
  normalization = "utf8 text, CRLF/LF normalized to LF, exactly one trailing LF"
  mdc = $mdcMap
}

$json = $out | ConvertTo-Json -Depth 10
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($specPath, $json + "`r`n", $utf8Bom)

Write-Host ("OK: spec updated -> " + $specPath)
exit 0

