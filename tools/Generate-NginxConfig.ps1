param (
    [switch]$WithHttps = $false
)

function Generate-NginxConfig {
    param (
        [string]$fqdn,
        [string]$firstPart,
        [string]$firstPort,
        [bool]$WithHttps = $false
    )

    if (-not (Get-Module -ListAvailable -Name EPS)) {
        Install-Module -Name EPS -Force -Scope CurrentUser
    }
    Import-Module EPS

    $template = Get-Content -Raw -Path "./template.eps"

    $outFile = "output/$fqdn.conf"
    $nginxConfig = Invoke-EpsTemplate -Template $template -Binding @{
        fqdn      = $fqdn
        firstPart = $firstPart
        firstPort = $firstPort
        CERT_HOME = $env:CERT_HOME -replace '\\', '/'
        withHttps = $withHttps
    }
    if (Test-Path "output") {
        Remove-Item "output" -Recurse -Force
    }
    $outDir = Split-Path $outFile -Parent
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    Set-Content -Path $outFile -Value $nginxConfig

    Write-Host "NGINX config generated: $outFile"
}

function Get-FirstHostPort {
    param (
        [string]$fqdn
    )

    $composeFile = "docker-compose.yml"

    # Ensure powershell-yaml module is installed and imported
    if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
        Install-Module -Name powershell-yaml -Force -Scope CurrentUser
    }
    Import-Module powershell-yaml

    if (-not (Test-Path $composeFile)) {
        Write-Error "docker-compose.yml not found"
        exit 1
    }

    $yaml = ConvertFrom-Yaml (Get-Content $composeFile -Raw)
    if (-not $yaml.services) {
        Write-Error "No 'services' section found in docker-compose.yml"
        exit 1
    }

    $firstPort = $null
    foreach ($service in $yaml.services.Values) {
        if (-not $service.ports) { 
            continue 
        }
        foreach ($port in $service.ports) {
            # Trim whitespace and match "hostPort:containerPort" or "ip:hostPort:containerPort"
            $trimmedPort = $port.Trim()
            if ($trimmedPort -match '(\d+):\d+$') {
                $firstPort = $Matches[1]
                break
            }
        }
        if ($firstPort) { 
            break 
        }
    }

    return $firstPort
}

function Check-EnvVars {
    $requiredVars = @("CERT_HOME", "NGINX_HOME")
    
    foreach ($var in $requiredVars) {
        if (-not [System.Environment]::GetEnvironmentVariable($var)) {
            Write-Error "Environment variable '$var' is not set."
            exit 1
        }
    }
}

Check-EnvVars

$fqdn = ((Split-Path -Leaf (Get-Location)) -split '-')[0] + '.by.vincent.mahn.ke'

$firstPort = Get-FirstHostPort -fqdn $fqdn

if (-not $firstPort) {
    Write-Error "Could not find a host port in docker-compose.yml"
    exit 1
}

$firstPart = $fqdn.Split('.')[0]

Generate-NginxConfig -fqdn $fqdn -firstPart $firstPart -firstPort $firstPort -WithHttps $WithHttps