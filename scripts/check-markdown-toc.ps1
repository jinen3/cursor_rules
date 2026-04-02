param(
  [Parameter(Mandatory = $false)]
  [string]$RootPath = ".",

  [Parameter(Mandatory = $false)]
  [switch]$Fix,

  [Parameter(Mandatory = $false)]
  [string[]]$ExcludeDirNames = @(
    ".git",
    "cursor_rules",
    ".venv",
    "node_modules",
    "dist",
    "build",
    "__pycache__"
  )
)

$ErrorActionPreference = "Stop"
try {
  [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
  $OutputEncoding = New-Object System.Text.UTF8Encoding($false)
} catch {
}

$RE_TOC_LINK = '\[[^\]]+\]\(#([A-Za-z0-9-]+)\)'
$RE_HTML_ANCHOR_LINE = '^\s*<a\s+id="([A-Za-z0-9-]+)"></a>\s*$'

# Avoid encoding-dependent Japanese string literals in PowerShell scripts.
# Construct "目次" via Unicode code points so it is stable even if the script file is read as CP932.
$TOC_TITLE = ([string][char]0x76EE) + ([string][char]0x6B21) # 目次
$RE_TOC_HEADER = '^\s*##\s*' + [Regex]::Escape($TOC_TITLE) + '\s*$'

function Resolve-AbsPath([string]$path) {
  return (Resolve-Path -LiteralPath $path).Path
}

function Read-TextFileLines([string]$path) {
  $bytes = [System.IO.File]::ReadAllBytes($path)

  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    $encoding = "utf8-bom"
  } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
    $text = [System.Text.Encoding]::Unicode.GetString($bytes)
    $encoding = "utf16le"
  } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
    $text = [System.Text.Encoding]::BigEndianUnicode.GetString($bytes)
    $encoding = "utf16be"
  } else {
    $utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
    try {
      $text = $utf8Strict.GetString($bytes)
      if ($text -match [char]0xFFFD) {
        throw "utf8 decoded with replacement char"
      }
      $encoding = "utf8"
    } catch {
      $cp932 = [System.Text.Encoding]::GetEncoding(932)
      $text = $cp932.GetString($bytes)
      $encoding = "cp932"
    }
  }

  $lines = $text -split "\r\n|\n|\r"
  return [PSCustomObject]@{
    Lines    = $lines
    Encoding = $encoding
  }
}

function Write-TextFileUtf8Bom([string]$path, [string[]]$lines) {
  $utf8Bom = New-Object System.Text.UTF8Encoding($true)
  $text = ($lines -join "`r`n") + "`r`n"
  [System.IO.File]::WriteAllText($path, $text, $utf8Bom)
}

function Should-ExcludeFile([string]$fullPath, [string]$rootPath, [string[]]$excludeDirNames) {
  # Exclusions should be based on path *inside* RootPath.
  # Using the absolute path can accidentally exclude everything when RootPath itself matches
  # an excluded dir name (e.g. repo folder name is "cursor_rules").
  $rel = $fullPath
  try {
    $rp = $rootPath.TrimEnd('\', '/')
    $fp = $fullPath
    if ($fp.Length -ge $rp.Length -and $fp.Substring(0, $rp.Length).ToLowerInvariant() -eq $rp.ToLowerInvariant()) {
      $rel = $fp.Substring($rp.Length).TrimStart('\', '/')
    }
  } catch {
    $rel = $fullPath
  }
  $relNorm = ($rel -replace '\\', '/')

  foreach ($name in $excludeDirNames) {
    $n = ($name -replace '\\', '/').Trim('/')
    if ([string]::IsNullOrWhiteSpace($n)) { continue }
    if ($relNorm -match ("(^|/)" + [Regex]::Escape($n) + "(/|$)")) {
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
    $clean = $line -replace [char]0xFEFF, ''
    if ($clean -match $RE_TOC_HEADER) {
      return $true
    }
  }
  return $false
}

function Has-GarbledTocSection([string[]]$lines) {
  # Common mojibake variants observed when "目次" is decoded with the wrong encoding.
  # We treat them as TOC headers that should be rebuilt.
  $patterns = @(
    '^\s*##\s*逶ｮ谺｡\s*$'
  )
  foreach ($line in $lines) {
    $clean = $line -replace [char]0xFEFF, ''
    foreach ($p in $patterns) {
      if ($clean -match $p) { return $true }
    }
  }
  return $false
}

function Get-FirstNonEmptyLine([string[]]$lines) {
  foreach ($line in $lines) {
    $clean = ($line -replace [char]0xFEFF, '').TrimEnd()
    if ($clean.Trim() -ne "") { return $clean }
  }
  return ""
}

function Count-TocHeaders([string]$text) {
  if ([string]::IsNullOrEmpty($text)) { return 0 }
  $m1 = [Regex]::Matches($text, '(?m)' + $RE_TOC_HEADER).Count
  $m2 = [Regex]::Matches($text, '(?m)^\s*##\s*逶ｮ谺｡\s*$').Count
  return ($m1 + $m2)
}

function Strip-ExistingTocBlock([string[]]$lines) {
  # Remove an existing TOC block (including garbled headers) to allow rebuilding.
  # We stop stripping when we reach the first real content marker (title heading or first <a id=...>).
  $out = New-Object System.Collections.Generic.List[string]
  $i = 0
  $stripping = $false
  while ($i -lt $lines.Length) {
    $clean = ($lines[$i] -replace [char]0xFEFF, '')
    if (-not $stripping) {
      if ($clean -match $RE_TOC_HEADER -or $clean -match '^\s*##\s*逶ｮ谺｡\s*$') {
        $stripping = $true
        $i++
        continue
      }
      $out.Add($clean) | Out-Null
      $i++
      continue
    }

    # stripping mode
    if ($clean -match '^\s*#\s+\S' -or $clean -match $RE_HTML_ANCHOR_LINE) {
      $stripping = $false
      $out.Add($clean) | Out-Null
      $i++
      continue
    }
    $i++
  }
  return $out.ToArray()
}

function Strip-LeadingAutoTocBlocks([string[]]$lines) {
  # Remove one or more auto-generated TOC blocks at the top of the file.
  # This fixes cases where a garbled TOC remains and a second TOC gets appended.
  #
  # We treat a block as "auto TOC" when:
  # - it starts with a level-2 heading (## ...)
  # - within the next ~40 lines we see list links to #secN and the jump hint
  # We stop stripping when we reach the first real content marker (# title or first <a id=...>).
  $i = 0
  $cleaned = $lines

  while ($true) {
    if ($cleaned.Length -lt 5) { break }
    $first = ($cleaned[0] -replace [char]0xFEFF, '')
    if (-not ($first -match '^\s*##\s+\S')) { break }

    $hasListLink = $false
    $hasJumpHint = $false
    $limit = [Math]::Min(40, $cleaned.Length)
    for ($k = 0; $k -lt $limit; $k++) {
      $l = ($cleaned[$k] -replace [char]0xFEFF, '')
      if ($l -match '^\s*-\s+\[[^\]]+\]\(#sec\d+\)') { $hasListLink = $true }
      if ($l -match 'To jump TOC links') { $hasJumpHint = $true }
    }
    if (-not ($hasListLink -and $hasJumpHint)) { break }

    # Strip until real content marker.
    $out = New-Object System.Collections.Generic.List[string]
    $stripping = $true
    for ($j = 0; $j -lt $cleaned.Length; $j++) {
      $c = ($cleaned[$j] -replace [char]0xFEFF, '')
      if ($stripping) {
        if ($c -match '^\s*#\s+\S' -or $c -match $RE_HTML_ANCHOR_LINE) {
          $stripping = $false
          $out.Add($c) | Out-Null
        }
        continue
      }
      $out.Add($c) | Out-Null
    }
    $next = $out.ToArray()
    if ($next.Length -eq $cleaned.Length) { break }
    $cleaned = $next
  }

  return $cleaned
}

function Strip-LeadingContentBeforeFirstTitle([string[]]$lines) {
  # If a file begins with an auto TOC (or any garbage) before the first H1 title,
  # drop everything up to the first "# Title" line (keeping a preceding <a id=...> when present).
  $titleIdx = -1
  for ($i = 0; $i -lt $lines.Length; $i++) {
    $c = ($lines[$i] -replace [char]0xFEFF, '')
    if ($c -match '^\s*#\s+\S') { $titleIdx = $i; break }
  }
  if ($titleIdx -lt 0) { return $lines }
  $start = $titleIdx
  if ($titleIdx -ge 1) {
    $prev = ($lines[$titleIdx - 1] -replace [char]0xFEFF, '')
    if ($prev -match $RE_HTML_ANCHOR_LINE) { $start = $titleIdx - 1 }
  }
  return $lines[$start..($lines.Length - 1)]
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
    $clean = $lines[$i] -replace [char]0xFEFF, ''
    if ($clean -match '^\s{0,3}#{1,6}\s+\S') {
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
    $clean = $line -replace [char]0xFEFF, ''
    if ($clean -match $RE_HTML_ANCHOR_LINE) {
      # Preserve existing anchors (we may reuse them for the next heading).
      $injected.Add($clean) | Out-Null
      continue
    }

    if ($clean -match '^\s{0,3}#{1,6}\s+\S') {
      $sec++
      $anchor = "sec" + $sec
      # If an anchor line already exists immediately before this heading, reuse it.
      if ($injected.Count -ge 1) {
        $prev = $injected[$injected.Count - 1]
        $mPrev = [Regex]::Match($prev, $RE_HTML_ANCHOR_LINE)
        if ($mPrev.Success) {
          $anchor = $mPrev.Groups[1].Value
        }
      }
      $level = ([Regex]::Match($clean, '^\s{0,3}(#{1,6})').Groups[1].Value).Length
      $indent = ""
      if ($level -gt 2) {
        $spaces = ($level - 2) * 2
        $indent = (" " * $spaces)
      }
      $title = ($clean -replace '^\s{0,3}#{1,6}\s+', '').Trim()
      $tocLinks.Add($indent + "- [$title](#$anchor)") | Out-Null
      # Inject anchor only when missing.
      if (-not ($injected.Count -ge 1 -and [Regex]::Match($injected[$injected.Count - 1], $RE_HTML_ANCHOR_LINE).Success)) {
        $injected.Add("<a id=""$anchor""></a>") | Out-Null
      }
      $injected.Add($clean) | Out-Null
    } else {
      $injected.Add($clean) | Out-Null
    }
  }

  $header = New-Object System.Collections.Generic.List[string]
  $header.Add("## " + $TOC_TITLE) | Out-Null
  $header.Add("") | Out-Null
  foreach ($t in $tocLinks) { $header.Add($t) | Out-Null }
  $header.Add("") | Out-Null
  $header.Add("> To jump TOC links, install **Markdown Preview Enhanced** and open preview (Ctrl+Alt+M or right-click 'Open Preview').") | Out-Null
  $header.Add("") | Out-Null

  $start = 0
  if ($lines.Length -gt 0 -and (($lines[0] -replace [char]0xFEFF, '') -match '^\s*#\s+\S')) {
    $start = 1
    if ($lines.Length -gt 1 -and (($lines[1] -replace [char]0xFEFF, '').Trim() -eq "")) { $start = 2 }
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
  -not (Should-ExcludeFile $_.FullName $root $ExcludeDirNames)
}

$problems = New-Object System.Collections.Generic.List[string]
$fixed = 0

foreach ($f in $mdFiles) {
  $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
  $read = Read-TextFileLines $f.FullName
  $content = $read.Lines

  # In -Fix mode, prefer a simple approach:
  # if the file starts with a TOC heading (even garbled), or TOC appears multiple times,
  # delete the leading TOC blocks and rebuild a single clean TOC.
  # This avoids "TOC appended without removing the old one".
  $needsForceRebuild = $false
  $cp932ForScan = $null
  $cp932TextForScan = ""
  $utf8TextForScan = ""
  if ($Fix) {
    try {
      $cp932ForScan = [System.Text.Encoding]::GetEncoding(932)
      $cp932TextForScan = $cp932ForScan.GetString($bytes)
    } catch { $cp932TextForScan = "" }
    try {
      $utf8StrictForScan = New-Object System.Text.UTF8Encoding($false, $true)
      $utf8TextForScan = $utf8StrictForScan.GetString($bytes)
    } catch { $utf8TextForScan = "" }

    $firstLine = Get-FirstNonEmptyLine $content
    if ($firstLine -match $RE_TOC_HEADER -or $firstLine -match '^\s*##\s*逶ｮ谺｡\s*$') { $needsForceRebuild = $true }

    $tocCount = [Math]::Max((Count-TocHeaders $cp932TextForScan), (Count-TocHeaders $utf8TextForScan))
    if ($tocCount -ge 2) { $needsForceRebuild = $true }
  }

  # Force-repair mojibake TOC: if CP932-decoded text contains the garbled "目次" header,
  # rebuild TOC and normalize to UTF-8 BOM. This avoids environment-dependent decoding differences.
  if ($Fix) {
    $cp932 = [System.Text.Encoding]::GetEncoding(932)
    $cp932Text = $cp932.GetString($bytes)
    $utf8TextForScan = ""
    try {
      $utf8StrictForScan = New-Object System.Text.UTF8Encoding($false, $true)
      $utf8TextForScan = $utf8StrictForScan.GetString($bytes)
    } catch {
      $utf8TextForScan = ""
    }

    # Mixed-encoding markdown is common: parts saved as CP932 and later edited as UTF-8.
    # Scan BOTH decodings; if either view contains a mojibake TOC header, force rebuild.
    if ($needsForceRebuild -or $cp932Text -match '(?m)^\s*##\s*逶ｮ谺｡\s*$' -or $utf8TextForScan -match '(?m)^\s*##\s*逶ｮ谺｡\s*$') {
      $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
      Copy-Item -LiteralPath $f.FullName -Destination ($f.FullName + ".bak." + $stamp) -Force

      $baseLines = $content
      try {
        $utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
        $utf8Text = $utf8Strict.GetString($bytes)
        if ($utf8Text -notmatch [char]0xFFFD) {
          $baseLines = $utf8Text -split "\r\n|\n|\r"
        }
      } catch {
      }

      $baseLines = Strip-ExistingTocBlock $baseLines
      $baseLines = Strip-LeadingAutoTocBlocks $baseLines
      $baseLines = Strip-LeadingContentBeforeFirstTitle $baseLines
      $newContent = Build-TocAndAnchors $baseLines
      Write-TextFileUtf8Bom $f.FullName $newContent
      $fixed++
      continue
    }
  }

  # If TOC looks missing, try the other common encoding once (UTF-8 <-> CP932).
  if (-not (Has-TocSection $content)) {
    if ($read.Encoding -eq "cp932") {
      try {
        $utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
        $alt = $utf8Strict.GetString($bytes)
        if ($alt -notmatch [char]0xFFFD) {
          $altLines = $alt -split "\r\n|\n|\r"
          if (Has-TocSection $altLines) { $content = $altLines }
        }
      } catch {
      }
    } else {
      $cp932 = [System.Text.Encoding]::GetEncoding(932)
      $alt = $cp932.GetString($bytes)
      $altLines = $alt -split "\r\n|\n|\r"
      if (Has-TocSection $altLines) { $content = $altLines }
    }
  }

  $headings = Get-HeadingLines $content
  if ($headings.Count -le 1) {
    continue
  }

  $hasToc = Has-TocSection $content
  $hasGarbledToc = Has-GarbledTocSection $content
  $needsUtf8BomNormalize = $Fix -and ($read.Encoding -ne "utf8-bom")

  if (-not $hasToc -or $hasGarbledToc -or $needsUtf8BomNormalize) {
    if ($Fix) {
      $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
      Copy-Item -LiteralPath $f.FullName -Destination ($f.FullName + ".bak." + $stamp) -Force
      $base = $content
      if (-not $hasToc -or $hasGarbledToc) {
        $base = Strip-ExistingTocBlock $content
        $base = Strip-LeadingAutoTocBlocks $base
        $base = Build-TocAndAnchors $base
      }
      $newContent = $base
      Write-TextFileUtf8Bom $f.FullName $newContent
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
  Write-Host ("FAIL: Add '## " + $TOC_TITLE + "' and <a id=""...""> anchors.")
  exit 1
}

Write-Host ""
if ($Fix) {
  Write-Host ("OK: " + $mdFiles.Count + " markdown files checked. Fixed: " + $fixed)
} else {
  Write-Host ("OK: " + $mdFiles.Count + " markdown files checked.")
}
exit 0

