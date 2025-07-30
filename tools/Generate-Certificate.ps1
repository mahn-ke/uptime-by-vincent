$subdomain = ((Split-Path -Leaf (Get-Location)) -split '-')[0]

# Ensure directories exist
$certsPath = Join-Path $env:CERT_HOME "certs"
$wellKnownPath = Join-Path $env:CERT_HOME ".well-known\$subdomain"
New-Item -ItemType Directory -Path $certsPath -Force | Out-Null
New-Item -ItemType Directory -Path $wellKnownPath -Force | Out-Null

# Path to wacs.exe (assumed to be in tools directory)
$wacsPath = Join-Path $env:ACME_HOME "wacs.exe"

# Run WACS to create certificate
echo "Setting up certificate renewal for $subdomain..."
pushd $env:ACME_HOME
$arguments = "--target manual --host $subdomain.by.vincent.mahn.ke --store pemfiles --pemfilespath $certsPath --validation filesystem --webroot $wellKnownPath --accepttos"
echo "Starting in '$PWD': '$wacsPath $arguments'"
$process = Start-Process -FilePath $wacsPath -ArgumentList $arguments -Wait -NoNewWindow -PassThru
popd
echo "WACS process completed with exit code: $($process.ExitCode)"

if ($process.ExitCode -ne 0) {
    Write-Error "Certificate renewal failed for $subdomain."
} else {
    Write-Host "Certificate successfully renewed for $subdomain in $certsPath."
}