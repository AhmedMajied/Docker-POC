# Azure App Service Deployment Guide

This guide explains how to deploy your Docker POC application to Azure App Service using GitHub Actions CI/CD.

## Prerequisites

- Azure subscription
- GitHub repository
- Azure App Service (Linux container) created
- GitHub Container Registry access

## Step 1: Azure App Service Setup

### 1.1 Create App Service
1. Go to Azure Portal
2. Create a new App Service
3. Choose **Linux** as the OS
4. Select **Container** as the publish method
5. Note down your App Service name

### 1.2 Configure App Service
1. Go to your App Service in Azure Portal
2. Navigate to **Settings > Configuration**
3. Add these Application Settings:
   ```
   WEBSITES_ENABLE_APP_SERVICE_STORAGE = true
   DOCKER_ENABLE_CI = true
   ```

## Step 2: GitHub Repository Setup

### 2.1 Update GitHub Actions Workflow

Edit `.github/workflows/azure-deploy.yml` and replace:
```yaml
app-name: 'your-azure-app-service-name'  # Replace with your actual App Service name
```

With your actual App Service name.

### 2.2 Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

#### AZURE_CREDENTIALS
1. Install Azure CLI
2. Run: `az login`
3. Run: `az ad sp create-for-rbac --name "github-actions" --role contributor --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} --sdk-auth`
4. Copy the JSON output and add it as `AZURE_CREDENTIALS` secret

#### GITHUB_TOKEN
- This is automatically available in GitHub Actions
- No need to add manually

## Step 3: Azure Container Registry Setup (Optional)

If you want to use Azure Container Registry instead of GitHub Container Registry:

### 3.1 Create Azure Container Registry
```bash
az acr create --resource-group your-rg --name yourregistryname --sku Basic
```

### 3.2 Update GitHub Actions Workflow
Replace the registry section in `.github/workflows/azure-deploy.yml`:

```yaml
env:
  REGISTRY: yourregistryname.azurecr.io
  IMAGE_NAME: dockerpoc

# In the login step:
- name: Log in to Azure Container Registry
  uses: docker/login-action@v3
  with:
    registry: ${{ env.REGISTRY }}
    username: ${{ secrets.ACR_USERNAME }}
    password: ${{ secrets.ACR_PASSWORD }}
```

## Step 4: Deployment Process

### 4.1 Automatic Deployment
1. Push code to `main` or `master` branch
2. GitHub Actions will automatically:
   - Build Docker image
   - Push to container registry
   - Deploy to Azure App Service

### 4.2 Manual Deployment
You can also trigger deployment manually:
1. Go to Actions tab in GitHub
2. Select "Build and Deploy to Azure App Service"
3. Click "Run workflow"

## Step 5: Verify Deployment

### 5.1 Check GitHub Actions
1. Go to Actions tab in GitHub
2. Monitor the workflow execution
3. Check for any errors

### 5.2 Check Azure App Service
1. Go to Azure Portal
2. Navigate to your App Service
3. Check the **Log stream** for any errors
4. Visit your app URL

### 5.3 Test Your Application
- HTTP: `https://your-app-service-name.azurewebsites.net`
- HTTPS: `https://your-app-service-name.azurewebsites.net`

## Configuration Files

### Production Dockerfile
- `Dockerfile.prod` - Optimized for production
- Uses non-root user for security
- Production environment settings

### Production Settings
- `appsettings.Production.json` - Production configuration
- Optimized for Azure App Service

## Troubleshooting

### Common Issues

#### 1. Build Failures
- Check Dockerfile syntax
- Ensure all dependencies are included
- Verify .dockerignore excludes unnecessary files

#### 2. Deployment Failures
- Verify Azure credentials
- Check App Service name in workflow
- Ensure App Service supports containers

#### 3. Runtime Errors
- Check App Service logs
- Verify environment variables
- Check container health

### Debugging Commands

#### Check Container Logs
```bash
# In Azure Portal > App Service > Log stream
# Or use Azure CLI:
az webapp log tail --name your-app-service-name --resource-group your-rg
```

#### Check Container Status
```bash
# In Azure Portal > App Service > Container settings
# Verify the image is being pulled correctly
```

## Security Best Practices

1. **Non-Root User**: Container runs as non-root
2. **Secrets Management**: Use Azure Key Vault for sensitive data
3. **HTTPS Only**: Configure SSL certificates
4. **Network Security**: Use Azure VNet if needed

## Cost Optimization

1. **App Service Plan**: Choose appropriate tier
2. **Container Registry**: Use Basic tier for development
3. **Monitoring**: Set up alerts for costs

## Next Steps

1. **Set up monitoring** with Application Insights
2. **Configure custom domain** and SSL certificates
3. **Set up staging environments** for testing
4. **Implement blue-green deployment** for zero-downtime updates 