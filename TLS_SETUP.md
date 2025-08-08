# TLS Setup for Docker Development Environment

This guide covers setting up TLS/HTTPS for the Docker development environment.

## 🚀 Quick Start

### 1. Generate Self-Signed Certificates
```powershell
.\generate-cert.ps1
```

### 2. Set Up Permissions
```powershell
.\setup-permissions.ps1
```

### 3. Start the Application
```bash
docker-compose up --build
```

## 📋 Prerequisites

- Docker Desktop running
- PowerShell (for certificate generation)
- .NET 8 SDK (for development)

## 🔐 Certificate Generation

The `generate-cert.ps1` script creates:
- `certs/ssl-cert.pfx` - Certificate for Kestrel
- `certs/ssl-cert.cer` - Certificate for browser trust

**Certificate Details:**
- **Password**: `password`
- **DNS Name**: `localhost`
- **Validity**: 1 year
- **Type**: Self-signed (development only)

## 🌐 Browser Trust Setup

### Chrome/Edge
1. Open `chrome://settings/certificates`
2. Click "Import" under "Authorities"
3. Select `certs/ssl-cert.cer`
4. Check "Trust this certificate for identifying websites"

### Firefox
1. Open `about:preferences#privacy`
2. Click "View Certificates"
3. Go to "Authorities" tab
4. Click "Import" and select `certs/ssl-cert.cer`
5. Check "Trust this CA to identify websites"

## 🐳 Docker Configuration

### Development Environment
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Certificate**: Mounted from `./certs:/app/certs:ro`
- **User**: Non-root (UID 1000)
- **Health Check**: Enabled

### Production Environment
- **Ports**: 80 (HTTP only)
- **SSL Termination**: Handled by Azure App Service
- **User**: Non-root (UID 1000)
- **Health Check**: Enabled

## 🔧 Configuration Files

### appsettings.json
```json
{
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://0.0.0.0:80"
      },
      "Https": {
        "Url": "https://0.0.0.0:443",
        "Certificate": {
          "Path": "certs/ssl-cert.pfx",
          "Password": "password"
        }
      }
    }
  }
}
```

### docker-compose.yml
```yaml
volumes:
  - ./certs:/app/certs:ro
ports:
  - "80:80"
  - "443:443"
```

## 🛡️ Security Features

### Development
- ✅ Self-signed certificates for local development
- ✅ Non-root user (UID 1000)
- ✅ Read-only certificate mounting
- ✅ Health checks
- ✅ Security headers

### Production
- ✅ HTTP-only (SSL termination by Azure)
- ✅ Non-root user (UID 1000)
- ✅ Health checks
- ✅ Security headers
- ✅ Pinned image versions

## 🚨 Troubleshooting

### Certificate Issues
```bash
# Regenerate certificates
.\generate-cert.ps1

# Rebuild container
docker-compose down
docker-compose up --build
```

### Permission Issues
```bash
# Fix permissions
.\setup-permissions.ps1

# Restart container
docker-compose restart
```

### Browser Trust Issues
1. Clear browser cache
2. Import certificate again
3. Restart browser

### Port Conflicts
```bash
# Check what's using the ports
netstat -ano | findstr :80
netstat -ano | findstr :443

# Stop conflicting services
docker-compose down
```

## 📝 Notes

- **Development certificates** are self-signed and not trusted by browsers by default
- **Production** uses Azure App Service SSL termination
- **Certificates** are mounted as read-only in containers
- **Non-root user** enhances security
- **Health checks** monitor application status

## 🔄 Maintenance

### Certificate Renewal
```powershell
# Regenerate certificates (when expired)
.\generate-cert.ps1
```

### Security Updates
- Update base images monthly
- Monitor for CVE announcements
- Run Checkov security scans

## 📚 Additional Resources

- [ASP.NET Core HTTPS](https://docs.microsoft.com/en-us/aspnet/core/security/enforcing-ssl)
- [Docker Security Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kestrel Configuration](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel) 