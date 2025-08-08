# TLS Setup for Docker POC

This guide explains how to apply TLS/HTTPS to your Docker container for development with security best practices.

## Prerequisites

- Docker Desktop installed
- PowerShell (for certificate generation)

## Security Features

This setup includes:
- ✅ **Non-root user** for enhanced security
- ✅ **TLS/HTTPS** encryption
- ✅ **Security headers** protection
- ✅ **Certificate management** with proper permissions

## Development Setup (Self-Signed Certificate)

### Step 1: Generate Development Certificate

Run the PowerShell script to generate a self-signed certificate:

```powershell
.\generate-cert.ps1
```

This will create:
- `certs/ssl-cert.pfx` - The certificate file
- `certs/ssl-cert.cer` - The certificate for viewing

### Step 2: Set Permissions for Non-Root User

Set proper permissions for the certificates directory:

```powershell
.\setup-permissions.ps1
```

### Step 3: Trust the Certificate (Development Only)

```powershell
certutil -addstore -f "ROOT" certs\ssl-cert.cer
```

### Step 4: Run with Docker Compose

```bash
docker-compose up --build
```

Your application will be available at:
- HTTP: http://localhost:80
- HTTPS: https://localhost:443

## Security Features Explained

### Non-Root User
- Container runs as `appuser` (UID 1000) instead of root
- Reduces attack surface and follows security best practices
- Proper file permissions ensure the app can still access certificates

### TLS Configuration
- Self-signed certificates for development
- HTTPS redirection enabled
- Security headers configured

### Volume Mounting
- Certificates mounted as read-only (`:ro`)
- Proper UID/GID mapping for permissions

## Using Reverse Proxy (Optional)

### Using Nginx as Reverse Proxy

Create `nginx.conf`:

```nginx
events {
    worker_connections 1024;
}

http {
    upstream app {
        server dockerpoc:80;
    }

    server {
        listen 80;
        server_name localhost;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl;
        server_name localhost;

        ssl_certificate /etc/nginx/certs/ssl-cert.crt;
        ssl_certificate_key /etc/nginx/certs/ssl-cert.key;

        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### Docker Compose with Nginx

```yaml
version: '3.8'

services:
  dockerpoc:
    build: .
    expose:
      - "80"
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on:
      - dockerpoc
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

## Security Best Practices

1. **Non-Root User**: Container runs as `appuser` instead of root
2. **Use Strong Passwords**: Change the default certificate password
3. **Enable Security Headers**: Already configured in `Program.cs`
4. **Use HTTPS Only**: Redirect HTTP to HTTPS
5. **Validate Certificates**: Ensure certificates are valid and trusted
6. **Read-Only Volumes**: Certificates mounted as read-only
7. **Proper Permissions**: Certificates accessible by non-root user

## Troubleshooting

### Certificate Issues

If you see certificate errors:
1. Ensure the certificate is trusted (development)
2. Check certificate expiration
3. Verify certificate password in configuration
4. Run `.\setup-permissions.ps1` to fix permissions

### Permission Issues

If you get permission errors:
1. Run `.\setup-permissions.ps1` to set proper permissions
2. Ensure Docker has proper permissions
3. Check that certificates are readable by the non-root user

### Port Issues

If ports are already in use:
1. Change port mappings in `docker-compose.yml`
2. Stop other services using the same ports

## Environment Variables

Key environment variables for TLS:

- `ASPNETCORE_URLS`: Configure HTTP/HTTPS endpoints
- `ASPNETCORE_ENVIRONMENT`: Set to Development
- `USER`: Set to `1000:1000` for non-root user

## Testing TLS

Test your HTTPS setup:

```bash
# Test HTTP to HTTPS redirect
curl -I http://localhost:80

# Test HTTPS directly
curl -I https://localhost:443

# Test with certificate validation
curl -I --cacert certs/ssl-cert.cer https://localhost:443
```

## Container Security Verification

Verify the container is running as non-root:

```bash
# Check the user inside the container
docker-compose exec dockerpoc whoami

# Should return: appuser

# Check the UID
docker-compose exec dockerpoc id

# Should return: uid=1000(appuser) gid=1000(appuser)
``` 