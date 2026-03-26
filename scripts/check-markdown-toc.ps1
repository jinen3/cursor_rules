param(
  [Parameter(Mandatory = $false)]
  [string]$RootPath = ".",

  [Parameter(Mandatory = $false)]
  [switch]$Fix,

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

$RE_TOC_LINK = '\[[^\]]+\]\(#([A-Za-z0-9-]+)\)'
$RE_HTML_ANCHOR_LINE = '^\s*<a\s+id="([A-Za-z0-9-]+)"></a>\s*$'

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

function Has-AnyHtmlAnchor([string[]]$lines) {
  foreach ($line in $lines) {
    if ($line -match $RE_HTML_ANCHOR_LINE) {
      return $true
    }
  }
  return $false
}

function Get-HeadingIndices([string[]]$lines) {
  $idx = @()
  for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '^\s{0,3}#{1,6}\s+\S') {
      $idx += $i
    }
  }
  return $idx
}

function Build-TocAndAnchors([string[]]$lines) {
  $headingIdx = Get-HeadingIndices $lines
  if ($headingIdx.Count -le 1) {
    return $lines
  }

  $tocLinks = New-Object System.Collections.Generic.List[string]
  $injected = New-Object System.Collections.Generic.List[string]

  $sec = 0
  for ($j = 0; $j -lt $lines.Length; $j++) {
    $line = $lines[$j]
    if ($line -match '^\s{0,3}#{1,6}\s+\S') {
      $sec++
      $anchor = "sec" + $sec
      $level = ([Regex]::Match($line, '^\s{0,3}(#{1,6})').Groups[1].Value).Length
      $indent = ""
      if ($level -gt 2) {
        $spaces = ($level - 2) * 2
        $indent = (" " * $spaces)
      }
      $title = ($line -replace '^\s{0,3}#{1,6}\s+', '').Trim()
      $tocLinks.Add($indent + "- [$title](#$anchor)") | Out-Null
      $injected.Add("<a id=""$anchor""></a>") | Out-Null
      $injected.Add($line) | Out-Null
    } else {
      $injected.Add($line) | Out-Null
    }
  }

  $header = New-Object System.Collections.Generic.List[string]
  $header.Add("## 目次") | Out-Null
  $header.Add("") | Out-Null
  foreach ($t in $tocLinks) { $header.Add($t) | Out-Null }
  $header.Add("") | Out-Null
  $header.Add("> To jump TOC links, install **Markdown Preview Enhanced** and open preview (Ctrl+Alt+M or right-click 'Open Preview').") | Out-Null
  $header.Add("") | Out-Null

  $start = 0
  if ($lines.Length -gt 0 -and $lines[0] -match '^\s*#\s+\S') {
    $start = 1
    if ($lines.Length -gt 1 -and $lines[1].Trim() -eq "") { $start = 2 }
  }

  $result = New-Object System.Collections.Generic.List[string]
  for ($k = 0; $k -lt $injected.Count; $k++) {
    if ($k -eq $start) {
      foreach ($h in $header) { $result.Add($h) | Out-Null }
    }
    $result.Add($injected[$k]) | Out-Null
  }
  if ($start -ge $injected.Count) {
    foreach ($h in $header) { $result.Add($h) | Out-Null }
  }
  return $result.ToArray()
}

function Get-TocLinkAnchors([string[]]$lines) {
  $anchors = New-Object System.Collections.Generic.HashSet[string]
  foreach ($line in $lines) {
    $matches = [Regex]::Matches($line, $RE_TOC_LINK)
    foreach ($m in $matches) {
      $anchors.Add($m.Groups[1].Value) | Out-Null
    }
  }
  return $anchors
}

function Get-HtmlAnchors([string[]]$lines) {
  $anchors = New-Object System.Collections.Generic.HashSet[string]
  foreach ($line in $lines) {
    $m = [Regex]::Match($line, $RE_HTML_ANCHOR_LINE)
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
$fixed = 0

foreach ($f in $mdFiles) {
  $content = Get-Content -LiteralPath $f.FullName -ErrorAction Stop
  $headings = Get-HeadingLines $content
  if ($headings.Count -le 1) {
    continue
  }

  if (-not (Has-TocSection $content)) {
    if ($Fix -and -not (Has-AnyHtmlAnchor $content)) {
      $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
      Copy-Item -LiteralPath $f.FullName -Destination ($f.FullName + ".bak." + $stamp) -Force
      $newContent = Build-TocAndAnchors $content
      [System.IO.File]::WriteAllText($f.FullName, ($newContent -join "`r`n") + "`r`n", [System.Text.Encoding]::UTF8)
      $fixed++
      continue
    }
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
if ($Fix) {
  Write-Host ("OK: " + $mdFiles.Count + " markdown files checked. Fixed: " + $fixed)
} else {
  Write-Host ("OK: " + $mdFiles.Count + " markdown files checked.")
}
exit 0

