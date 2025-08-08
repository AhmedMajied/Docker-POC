# PowerShell script to set proper permissions for non-root user

Write-Host "Setting up permissions for non-root user..." -ForegroundColor Green

# Create certs directory if it doesn't exist
if (!(Test-Path "certs")) {
    New-Item -ItemType Directory -Path "certs"
    Write-Host "Created certs directory" -ForegroundColor Yellow
}

# Set permissions for certs directory (UID 1000 = appuser)
Write-Host "Setting permissions for certs directory..." -ForegroundColor Yellow

# For Windows, we'll set basic permissions
# In Docker, the container will handle the actual UID/GID mapping
$acl = Get-Acl "certs"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl "certs" $acl

Write-Host "✅ Permissions set successfully!" -ForegroundColor Green
Write-Host "📁 The certs directory is ready for Docker volume mounting" -ForegroundColor Yellow
Write-Host "🔐 Certificates will be accessible by the non-root user (UID 1000)" -ForegroundColor Yellow 