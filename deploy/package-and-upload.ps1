# Bladetide — build a deploy tarball and install it on the VPS.
#
# Usage (from a machine that can reach the server over SSH):
#   pwsh deploy/package-and-upload.ps1 -Server 69.62.81.172
#   pwsh deploy/package-and-upload.ps1 -Server 69.62.81.172 -Port 2222 -User root
#   pwsh deploy/package-and-upload.ps1 -Server 69.62.81.172 -SkipUpload   # just build the tarball
#
# Secrets and local state are never included (.env, SQLite data, node_modules).
param(
    [Parameter(Mandatory = $true)][string]$Server,
    [int]$Port = 22,
    [string]$User = 'root',
    [string]$RemoteDir = '/opt/bladetide/app',
    [switch]$SkipUpload
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$tarball = Join-Path $env:TEMP 'bladetide-deploy.tgz'

Write-Host "[bladetide] packaging $repo ..."
Push-Location $repo
try {
    tar -czf $tarball `
        --exclude node_modules `
        --exclude '*/node_modules' `
        --exclude .git `
        --exclude 'apps/api/data' `
        --exclude '*/apps/api/data' `
        --exclude 'apps/api/.env' `
        --exclude '*/apps/api/.env' `
        --exclude 'apps/room-server/.env' `
        --exclude '*/apps/room-server/.env' `
        --exclude '*.log' `
        .
    if ($LASTEXITCODE -ne 0) { throw "tar failed with code $LASTEXITCODE" }
}
finally {
    Pop-Location
}

$size = [math]::Round((Get-Item $tarball).Length / 1MB, 2)
Write-Host "[bladetide] tarball: $tarball ($size MB)"
if ($SkipUpload) { Write-Host '[bladetide] -SkipUpload set; done.'; exit 0 }

Write-Host "[bladetide] uploading to ${User}@${Server}:${Port} ..."
scp -P $Port $tarball "${User}@${Server}:/tmp/bladetide-deploy.tgz"
if ($LASTEXITCODE -ne 0) { throw 'scp failed' }

$remote = @"
set -e
mkdir -p '$RemoteDir'
tar -xzf /tmp/bladetide-deploy.tgz -C '$RemoteDir'
rm -f /tmp/bladetide-deploy.tgz
bash '$RemoteDir/deploy/server-install.sh'
"@

ssh -p $Port "${User}@${Server}" $remote
if ($LASTEXITCODE -ne 0) { throw 'remote install failed' }

Write-Host ''
Write-Host '[bladetide] deployed. Remaining manual steps (see deploy/README.md):'
Write-Host '  1. Review /opt/bladetide/app/apps/api/.env and apps/room-server/.env (secrets, WEB_ORIGIN).'
Write-Host '  2. Add deploy/Caddyfile.bladetide to the existing Caddy conf.d, then reload Caddy.'
Write-Host '  3. Point the Vercel frontend at https://api.<domain> and wss://room.<domain>.'
