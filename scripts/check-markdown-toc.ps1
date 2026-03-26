param(
  [Parameter(Mandatory = $false)]
  [string]$RootPath = ".",

  [Parameter(Mandatory = $false)]
  [string[]]$ExcludeDirNames = @(
    ".git",
    ".venv",
    "node_modules",
    "dist",
    "build",
    "__pycache__"
  )
)

$ErrorActionPreference = "Stop"

function Resolve-AbsPath([string]$path) {
  return (Resolve-Path -LiteralPath $path).Path
}

function Should-ExcludeFile([string]$fullPath, [string[]]$excludeDirNames) {
  foreach ($name in $excludeDirNames) {
    if ($fullPath -match ("[\\/]" + [Regex]::Escape($name) + "[\\/]")) {
      return $true
    }
  }
  return $false
}

function Get-HeadingLines([string[]]$lines) {
  $headings = @()
  for ($i = 0; $i -lt $lines.Length; $i++) {
    $line = $lines[$i]
    if ($line -match '^\s{0,3}#{1,6}\s+\S') {
      $headings += $line
    }
  }
  return $headings
}

function Has-TocSection([string[]]$lines) {
  foreach ($line in $lines) {
    if ($line -match '^\s*##\s+目次\s*$') {
      return $true
    }
  }
  return $false
}

function Get-TocLinkAnchors([string[]]$lines) {
  $anchors = New-Object System.Collections.Generic.HashSet[string]
  foreach ($line in $lines) {
    $matches = [Regex]::Matches($line, '\[[^\]]+\]\(#([A-Za-z0-9\-]+)\)')
    foreach ($m in $matches) {
      $anchors.Add($m.Groups[1].Value) | Out-Null
    }
  }
  return $anchors
}

function Get-HtmlAnchors([string[]]$lines) {
  $anchors = New-Object System.Collections.Generic.HashSet[string]
  foreach ($line in $lines) {
    $m = [Regex]::Match($line, '^\s*<a\s+id="([A-Za-z0-9\-]+)"></a>\s*$')
    if ($m.Success) {
      $anchors.Add($m.Groups[1].Value) | Out-Null
    }
  }
  return $anchors
}

$root = Resolve-AbsPath $RootPath
Write-Host ("== Markdown TOC check ==")
Write-Host ("RootPath: " + $root)

$mdFiles = Get-ChildItem -LiteralPath $root -Recurse -File -Filter "*.md" | Where-Object {
  -not (Should-ExcludeFile $_.FullName $ExcludeDirNames)
}

$problems = New-Object System.Collections.Generic.List[string]

foreach ($f in $mdFiles) {
  $content = Get-Content -LiteralPath $f.FullName -ErrorAction Stop
  $headings = Get-HeadingLines $content
  if ($headings.Count -le 1) {
    continue
  }

  if (-not (Has-TocSection $content)) {
    $problems.Add("[NO_TOC] " + $f.FullName) | Out-Null
    continue
  }

  $tocAnchors = Get-TocLinkAnchors $content
  if ($tocAnchors.Count -eq 0) {
    $problems.Add("[TOC_NO_LINKS] " + $f.FullName) | Out-Null
    continue
  }

  $htmlAnchors = Get-HtmlAnchors $content
  foreach ($a in $tocAnchors) {
    if (-not $htmlAnchors.Contains($a)) {
      $problems.Add("[MISSING_HTML_ANCHOR] " + $f.FullName + " #"+ $a) | Out-Null
    }
  }
}

if ($problems.Count -gt 0) {
  Write-Host ""
  Write-Host ("Problems: " + $problems.Count)
  foreach ($p in $problems) {
    Write-Host $p
  }
  Write-Host ""
  Write-Host "FAIL: Add '## 目次' and <a id=\"...\"> anchors."
  exit 1
}

Write-Host ""
Write-Host ("OK: " + $mdFiles.Count + " markdown files checked.")
exit 0

