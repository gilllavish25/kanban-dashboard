# Kanban Dashboard – Docker & Jenkins CI/CD on AWS

## Project Overview

This project demonstrates the deployment of a React + TypeScript Kanban Dashboard using Docker, Jenkins CI/CD, Docker Hub, and AWS EC2.

The application is containerized using a multi-stage Docker build and served using Nginx running as a non-root user.

The project implements an automated CI/CD pipeline to build, version, push, and deploy Docker images to an AWS EC2 instance.

## Technologies Used

- React
- TypeScript
- Vite
- Docker
- Jenkins
- GitHub
- Docker Hub
- AWS EC2
- Nginx
- Docker Scout

## Architecture

```text
GitHub → Jenkins → Docker Build → Docker Hub → AWS EC2 → Running Application
```

## Application URL

http://52.66.157.239

## Docker Hub Image

`gilllavish25/lavish-kanban-dashboard`

Available Docker image tags:

- `23`
- `24`
- `latest`

## Run Locally

### Prerequisites

- Node.js 22 or compatible version
- npm
- Git

### Clone the repository

```bash
git clone https://github.com/gilllavish25/kanban-dashboard.git
cd kanban-dashboard
```

### Install dependencies

```bash
npm install
```

### Start the development server

```bash
npm run dev
```

### Build the application

```bash
npm run build
```

## Run Using Docker

### Pull the image

```bash
docker pull gilllavish25/lavish-kanban-dashboard:latest
```

### Run the container

```bash
docker run -d \
  --name kanban-app \
  -p 8080:8080 \
  gilllavish25/lavish-kanban-dashboard:latest
```

Open the application:

http://localhost:8080

## Jenkins CI/CD Pipeline

The Jenkins pipeline automates the following stages:

1. Checkout source code from GitHub.
2. Build the Docker image.
3. Authenticate with Docker Hub using Jenkins Credentials.
4. Push versioned images to Docker Hub.
5. Pull the new image on AWS EC2.
6. Deploy the application in a Docker container.
7. Verify deployment using an HTTP health check.
8. Attempt rollback if deployment validation fails.

Automatic builds are currently configured through Jenkins SCM polling every two minutes.

## Docker Security

The project includes the following security measures:

- Multi-stage Docker build.
- Non-root Nginx runtime user (UID 101).
- Docker HEALTHCHECK instruction.
- CPU limit of 0.5 core.
- Memory limit of 128 MB.
- `.dockerignore` to exclude unnecessary files.
- Jenkins Credentials for Docker Hub authentication.
- Docker Scout vulnerability scanning.

### Latest Docker Scout Scan

Image: `gilllavish25/lavish-kanban-dashboard:23`

| Severity | Findings |
|---|---:|
| Critical | 0 |
| High | 4 |
| Medium | 6 |
| Low | 5 |
| Unspecified | 1 |
| **Total** | **16** |

The previous scan reported 47 vulnerabilities. The updated image reports 16, approximately 66% fewer findings.

Some vulnerabilities remain because the configured Alpine package repositories did not provide the required fixed versions at the time of verification.

## AWS Deployment

The application is deployed on an Ubuntu EC2 instance.

Deployment configuration:

- Application port: `80`
- Container port: `8080`
- Container name: `kanban-app`
- Restart policy: `unless-stopped`
- Memory limit: `128 MB`
- CPU limit: `0.5 core`

## Deployment Verification

The following checks were performed:

- Docker container status: healthy.
- HTTP response: `200 OK`.
- Runtime user: `101` (non-root).
- Memory limit: `128 MB`.
- CPU limit: `0.5 core`.
- Nginx health-check requests: successful.

### Docker Verification Commands

Check container status:

```bash
docker ps --filter name=kanban-app
```

Check HTTP response:

```bash
curl -I http://localhost
```

Check runtime user and resource limits:

```bash
docker inspect \
  --format='User={{.Config.User}} Memory={{.HostConfig.Memory}} NanoCPUs={{.HostConfig.NanoCpus}}' \
  kanban-app
```

## Rollback Testing

A manual rollback simulation was performed using a separate temporary Docker container to avoid affecting the production application.

### Test Procedure

1. Started a simulated failed deployment using Docker image `:24` without its Nginx web server.
2. Verified that the temporary container health status changed to `unhealthy`.
3. Confirmed that the HTTP request to port `8081` failed.
4. Removed the failed temporary container.
5. Restored the previous working Docker image `:23`.
6. Verified that the restored container became healthy.
7. Confirmed that the restored application returned HTTP `200 OK`.

### Rollback Test Results

| Verification | Result |
|---|---|
| Simulated deployment failure | Confirmed |
| Failed container health | Unhealthy |
| Previous image restored | Version 23 |
| Restored container status | Running |
| Restored container health | Healthy |
| HTTP response | 200 OK |

**Result:** Previous application version restored successfully without disturbing the production application.

**Note:** This was a manual rollback simulation using a temporary container. Automatic rollback through the Jenkins pipeline has not yet been independently tested.

## Repository

- GitHub: https://github.com/gilllavish25/kanban-dashboard
- Docker Hub: https://hub.docker.com/r/gilllavish25/lavish-kanban-dashboard
- Live Application: http://52.66.157.239

## Author

**Lavish Gill**

