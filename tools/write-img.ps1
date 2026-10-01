<#
.SYNOPSIS
  Writes a raw disk image (e.g. psxitarch-usb.img) to a USB drive, byte for byte.
  A compressed psxitarch-usb.img.xz is also accepted; it is decompressed on the fly
  with 7-Zip (7z.exe must be installed or on PATH).

.DESCRIPTION
  Windows cannot pass a removable USB drive into WSL, so the image is built as a file
  first (see build-img.sh) and then written raw with this script.

  WARNING: EVERYTHING on the selected disk is erased.

  Safety checks:
    - must run as Administrator
    - target must be a USB disk that is not the boot or system disk
    - target must be at least as big as the image
    - you must type the disk number again to confirm (skip with -Force only if you are sure)

.EXAMPLE
  Get-Disk        # find the number of your USB drive first
  .\write-img.ps1 -ImagePath D:\ps4\psxitarch-usb.img -DiskNumber 1
  .\write-img.ps1 -ImagePath D:\ps4\psxitarch-usb.img.xz -DiskNumber 1
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$ImagePath,
  [Parameter(Mandatory = $true)][int]$DiskNumber,
  [switch]$Force
)
$ErrorActionPreference = 'Stop'

$id = [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw 'Run this script from an elevated (Administrator) PowerShell.'
}

$Img = (Resolve-Path -LiteralPath $ImagePath).Path
$xz = $Img -match '\.xz$'
$proc = $null
if ($xz) {
  $sz = Get-Command 7z.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1
  if (-not $sz) { $sz = @("$env:ProgramFiles\7-Zip\7z.exe", "${env:ProgramFiles(x86)}\7-Zip\7z.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1 }
  if (-not $sz) { throw 'For .xz images install 7-Zip, or extract the .img first and pass that instead.' }
  $info = & $sz l -slt $Img
  $line = $info | Where-Object { $_ -match '^Size = \d+' } | Select-Object -Last 1
  if (-not $line) { throw 'Could not read the uncompressed size from the .xz file.' }
  $len = [int64]($line -replace '^Size = ', '')
} else {
  $len = (Get-Item -LiteralPath $Img).Length
}
if ($len -le 1MB) { throw "Image looks too small: $len bytes" }

$d = Get-Disk -Number $DiskNumber
$d | Format-List Number, FriendlyName, SerialNumber, BusType, Size, PartitionStyle, IsBoot, IsSystem

if ($d.BusType -ne 'USB') { throw "ABORT: disk $DiskNumber is not a USB disk (BusType=$($d.BusType))" }
if ($d.IsBoot -or $d.IsSystem) { throw "ABORT: disk $DiskNumber is a boot/system disk" }
if ($d.Size -lt $len) { throw "ABORT: disk is smaller ($($d.Size) bytes) than the image ($len bytes)" }

Write-Host ''
Write-Host ("Image : {0} ({1:N2} GB)" -f $Img, ($len / 1GB))
Write-Host ("Target: disk {0} - {1} ({2:N1} GB)" -f $DiskNumber, $d.FriendlyName, ($d.Size / 1GB))
Write-Host 'ALL DATA ON THIS DISK WILL BE ERASED.' -ForegroundColor Red
if (-not $Force) {
  $ans = Read-Host "Type the disk number ($DiskNumber) to continue, anything else to cancel"
  if ($ans -ne "$DiskNumber") { Write-Host 'Cancelled.'; exit 1 }
}

$in = $null; $out = $null
try {
  if (Get-Partition -DiskNumber $DiskNumber -ErrorAction SilentlyContinue) {
    Clear-Disk -Number $DiskNumber -RemoveData -RemoveOEM -Confirm:$false
  }
  if ($xz) {
    $psi = New-Object Diagnostics.ProcessStartInfo($sz, "e -so -bd `"$Img`"")
    $psi.UseShellExecute = $false; $psi.RedirectStandardOutput = $true; $psi.CreateNoWindow = $true
    $proc = [Diagnostics.Process]::Start($psi)
    $in = $proc.StandardOutput.BaseStream
  } else {
    $in = [IO.File]::OpenRead($Img)
  }
  $out = New-Object IO.FileStream("\\.\PHYSICALDRIVE$DiskNumber", [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::ReadWrite)
  $buf  = New-Object byte[] (4MB)
  $head = New-Object byte[] (1MB)
  function ReadFull($s, $b) { $r = 0; while ($r -lt $b.Length) { $k = $s.Read($b, $r, $b.Length - $r); if ($k -le 0) { break }; $r += $k }; $r }
  if ((ReadFull $in $head) -ne 1MB) { throw 'Could not read the first 1MB of the image' }
  # Write the first 1MB as zeros, then the bulk data, then the real first 1MB (MBR) last,
  # so Windows does not try to mount anything while the write is in progress.
  $out.Write((New-Object byte[] (1MB)), 0, 1MB); $tot = 1MB
  while (($n = (ReadFull $in $buf)) -gt 0) {
    $out.Write($buf, 0, $n); $tot += $n
    if (($tot - 1MB) % 1GB -eq 0) { '{0:N1} GB written' -f ($tot / 1GB) }
  }
  $out.Flush(); [void]$out.Seek(0, 'Begin'); $out.Write($head, 0, 1MB); $out.Flush()
  "Wrote $tot of $len bytes"
  if ($tot -ne $len) { throw 'Short write' }
  'WRITE_DONE_OK'
} catch {
  "ERROR: $_"; 'WRITE_FAILED'; exit 1
} finally {
  if ($out) { $out.Close() }
  if ($in) { $in.Close() }
  if ($proc) { if (-not $proc.HasExited) { $proc.Kill() }; $proc.Dispose() }
  Update-HostStorageCache
}
