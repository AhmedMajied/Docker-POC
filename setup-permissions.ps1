# PowerShell script to set proper permissions for non-root user

# Create certificates directory if it doesn't exist
if (!(Test-Path "certs")) {
    New-Item -ItemType Directory -Path "certs"
}

# Set permissions for the certificates directory
# This ensures the non-root user in the container can read the certificates
Write-Host "Setting permissions for certificates directory..."

# For Windows, we need to ensure the directory is readable
# The container will run as UID 1000, so we make it readable by all
$acl = Get-Acl "certs"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","ReadAndExecute","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl "certs" $acl

Write-Host "Permissions set successfully!"
Write-Host "Certificate directory is now ready for non-root user access." 