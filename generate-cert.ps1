# PowerShell script to generate a self-signed certificate for development

# Create certificates directory if it doesn't exist
if (!(Test-Path "certs")) {
    New-Item -ItemType Directory -Path "certs"
}

# Generate a self-signed certificate
$cert = New-SelfSignedCertificate -DnsName "localhost", "127.0.0.1" -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(1) -FriendlyName "DockerPOC Development Certificate"

# Export the certificate to PFX format
$password = ConvertTo-SecureString -String "your-certificate-password" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "certs\ssl-cert.pfx" -Password $password

# Export the certificate to CER format (for viewing)
Export-Certificate -Cert $cert -FilePath "certs\ssl-cert.cer"

Write-Host "Certificate generated successfully!"
Write-Host "PFX file: certs\ssl-cert.pfx"
Write-Host "CER file: certs\ssl-cert.cer"
Write-Host "Password: your-certificate-password"
Write-Host ""
Write-Host "To trust the certificate in development, run:"
Write-Host "certutil -addstore -f \"ROOT\" certs\ssl-cert.cer" 