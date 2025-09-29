# Use the official .NET 8 runtime image as the base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

# Set environment variables for production
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

# Use the official .NET 8 SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the project file and restore dependencies
COPY ["DockerPOC.csproj", "./"]
RUN dotnet restore "DockerPOC.csproj"

# Copy the rest of the source code
COPY . .
WORKDIR "/src"

# Build the application
RUN dotnet build "DockerPOC.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "DockerPOC.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final stage/image
FROM base AS final
WORKDIR /app

# Copy the published application
COPY --from=publish /app/publish .

# Add health check for production
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f https://dockerpoc-apim.azure-api.net/home || exit 1

# Set the entry point
ENTRYPOINT ["dotnet", "DockerPOC.dll"] 