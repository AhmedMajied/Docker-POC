# PowerShell script to generate self-signed certificates for development TLS
# This version uses a simpler approach that doesn't require admin privileges

Write-Host "Generating self-signed certificates for development..." -ForegroundColor Green

# Create certs directory if it doesn't exist
if (!(Test-Path "certs")) {
    New-Item -ItemType Directory -Path "certs"
    Write-Host "Created certs directory" -ForegroundColor Yellow
}

# Check if OpenSSL is available
$opensslPath = Get-Command openssl -ErrorAction SilentlyContinue
if ($opensslPath) {
    Write-Host "Using OpenSSL to generate certificates..." -ForegroundColor Yellow
    
    # Generate private key
    openssl genrsa -out "certs\ssl-cert.key" 2048
    
    # Generate certificate signing request
    openssl req -new -key "certs\ssl-cert.key" -out "certs\ssl-cert.csr" -subj "/CN=localhost"
    
    # Generate self-signed certificate
    openssl x509 -req -in "certs\ssl-cert.csr" -signkey "certs\ssl-cert.key" -out "certs\ssl-cert.crt" -days 365
    
    # Convert to PFX format for .NET
    openssl pkcs12 -export -out "certs\ssl-cert.pfx" -inkey "certs\ssl-cert.key" -in "certs\ssl-cert.crt" -passout pass:password
    
    # Clean up intermediate files
    Remove-Item "certs\ssl-cert.csr" -ErrorAction SilentlyContinue
    
    Write-Host "✅ Self-signed certificates generated successfully using OpenSSL!" -ForegroundColor Green
} else {
    Write-Host "OpenSSL not found. Trying alternative approach..." -ForegroundColor Yellow
    
    # Try using .NET to generate a development certificate
    try {
        dotnet dev-certs https --clean
        dotnet dev-certs https --trust
        
        # Export the certificate
        $certPath = "$env:USERPROFILE\.dotnet\https\localhost.pfx"
        if (Test-Path $certPath) {
            Copy-Item $certPath "certs\ssl-cert.pfx"
            Write-Host "✅ Development certificate copied successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ Could not find development certificate. Please run 'dotnet dev-certs https --trust' manually." -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "❌ Failed to generate certificates. Please install OpenSSL or run as administrator." -ForegroundColor Red
        Write-Host "You can install OpenSSL from: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "📁 Certificate files created in 'certs' directory:" -ForegroundColor Yellow
Get-ChildItem "certs" | ForEach-Object {
    Write-Host "   - $($_.Name)" -ForegroundColor White
}
Write-Host ""
Write-Host "🔐 Certificate password: password" -ForegroundColor Yellow
Write-Host "🌐 You can now run 'docker-compose up --build' for HTTPS development" -ForegroundColor Green
