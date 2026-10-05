#Requires -Version 7
# Prove this bucket's manifests install and work. CI runs it on every push;
# zenvik's release workflow runs it on freshly rendered manifests before
# pushing them here. Needs Scoop on Windows.
#
#   ./check.ps1
#
# Every native or Scoop command's exit code is checked: Scoop is a script,
# and a failed install doesn't always raise a PowerShell error.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$script:step = 'setup'
function Step([string]$name) { $script:step = $name; Write-Host "==> $name" }
function Run {
    & $args[0] @($args | Select-Object -Skip 1)
    if ($LASTEXITCODE -ne 0) { throw "$($args -join ' ') exited with $LASTEXITCODE" }
}
trap {
    Write-Host "check.ps1: failed at: $script:step"
    Write-Host $_
    exit 1
}

Step 'add the extras bucket'
$buckets = @(scoop bucket list | ForEach-Object { $_.Name })
if ($buckets -notcontains 'extras') { Run scoop bucket add extras }

Step 'read the manifests'
$m = @{}
foreach ($n in 'zenvik', 'zenvik-gui') {
    $j = Get-Content (Join-Path $PSScriptRoot "bucket/$n.json") -Raw | ConvertFrom-Json
    $a = $j.architecture.'64bit'
    foreach ($v in $j.version, $a.url, $a.hash, $a.extract_dir) {
        if (-not $v) { throw "$n.json lacks version, url, hash or extract_dir" }
    }
    $m[$n] = $j
}
if ($m['zenvik'].version -ne $m['zenvik-gui'].version) { throw 'the two manifests have different versions' }
$ver = $m['zenvik'].version

Step 'install zenvik'
Run scoop install (Join-Path $PSScriptRoot 'bucket/zenvik.json')
Step 'zenvik --version'
$out = (Run zenvik --version) -join "`n"
if ($out -notlike "zenvik v$ver*") { throw "zenvik --version printed: $out" }
Step 'mkvmerge from the Extras dependency'
$out = (Run mkvmerge --version) -join "`n"
if ($out -notlike 'mkvmerge v*') { throw "mkvmerge --version printed: $out" }

Step 'install zenvik-gui'
Run scoop install (Join-Path $PSScriptRoot 'bucket/zenvik-gui.json')
$dir = ((Run scoop prefix zenvik-gui) | Select-Object -Last 1).Trim()
Step "the app's files in $dir"
if (-not (Test-Path (Join-Path $dir 'zenvik-gui.exe'))) { throw "no zenvik-gui.exe in $dir" }
$out = (Run (Join-Path $dir 'mkvmerge.exe') --version) -join "`n"
if ($out -notlike 'mkvmerge v*') { throw "the bundled mkvmerge.exe printed: $out" }

Step 'uninstall both'
Run scoop uninstall zenvik-gui
Run scoop uninstall zenvik
Write-Host 'check.ps1: all checks passed'
