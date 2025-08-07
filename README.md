# Docker POC - .NET 8 Web API

A simple .NET 8 Web API project that returns "success" on GET requests.

## Project Structure

```
Docker POC/
├── Controllers/
│   └── HomeController.cs
├── DockerPOC.csproj
├── Program.cs
├── appsettings.json
├── appsettings.Development.json
├── Dockerfile
├── .dockerignore
└── README.md
```

## API Endpoints

- `GET /home` - Returns "success" message

## Local Development

1. Ensure you have .NET 8 SDK installed
2. Run the following commands:

```bash
dotnet restore
dotnet build
dotnet run
```

3. Navigate to `https://localhost:7001` or `http://localhost:5000`
4. Access the API at `https://localhost:7001/home` or `http://localhost:5000/home`

## Docker Instructions

### Prerequisites

1. Install Docker Desktop for Windows
2. Ensure Docker Desktop is running
3. Open PowerShell or Command Prompt

### Building the Docker Image

1. Navigate to the project directory:
```bash
cd "D:\Work\Docker POC"
```

2. Build the Docker image:
```bash
docker build -t docker-poc-api .
```

### Running the Docker Container

1. Run the container:
```bash
docker run -d -p 8080:80 --name docker-poc-container docker-poc-api
```

2. Access the API:
   - Open your browser and go to `http://localhost:8080/home`
   - Or use curl: `curl http://localhost:8080/home`

### Docker Commands Reference

- **Build image**: `docker build -t docker-poc-api .`
- **Run container**: `docker run -d -p 8080:80 --name docker-poc-container docker-poc-api`
- **Stop container**: `docker stop docker-poc-container`
- **Remove container**: `docker rm docker-poc-container`
- **View logs**: `docker logs docker-poc-container`
- **List running containers**: `docker ps`
- **List all containers**: `docker ps -a`
- **List images**: `docker images`
- **Remove image**: `docker rmi docker-poc-api`

### Testing the API

Once the container is running, you can test the API using:

1. **Browser**: Navigate to `http://localhost:8080/home`
2. **curl**: `curl http://localhost:8080/home`
3. **PowerShell**: `Invoke-RestMethod -Uri "http://localhost:8080/home" -Method Get`

The API should return: `"success"`

## Troubleshooting

- If port 8080 is already in use, change the port mapping: `docker run -d -p 8081:80 --name docker-poc-container docker-poc-api`
- To see container logs: `docker logs docker-poc-container`
- To access container shell: `docker exec -it docker-poc-container /bin/bash` 