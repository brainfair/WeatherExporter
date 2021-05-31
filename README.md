WeatherExporter [![Terraform Azure VM](https://github.com/brainfair/WeatherExporter/actions/workflows/terraform.yml/badge.svg)](https://github.com/brainfair/WeatherExporter/actions/workflows/terraform.yml) [![Docker Compose Check](https://github.com/brainfair/WeatherExporter/actions/workflows/compose.yml/badge.svg)](https://github.com/brainfair/WeatherExporter/actions/workflows/compose.yml) [![CI/CD](https://github.com/brainfair/WeatherExporter/actions/workflows/docker.yml/badge.svg)](https://github.com/brainfair/WeatherExporter/actions/workflows/docker.yml)
===============
## What is it? ##
WeatherExporter get current weather from OpenWeatherMap and export them to metrics endpoint in prometheus format

## Build and Usage
### Environment variables must be present

Variable | Description
--- | ---
`OWM_API_KEY`	| OpenWeatherMap api key for retrive data
`OWM_LOCATION`	| OpenWeatherMap City for retrive data
`EXPORTER_PORT`	| Port for Expose

### Simple run
    
    $ go run .\main.go

### Build docker image and example run

    $ docker build -t weatherexporter -f dockerfile .
    $ docker run -d -t -i  -e OWM_API_KEY='YOUR_OWM_API_KEY' -e OWM_LOCATION='YOUR_CIRY' -e EXPORTER_PORT=':80' -p 80:80  weatherexporter

## Example Deployment ##
### Terraform
For Deploy we create Azure VM with same specifications. 
Configuration for create Azure VM is giver in the [terraform](terraform) folder

### Ansible
For configure VM and create service we use ansible role in [roles/weatherserver](roles/weatherserver)

### Docker-compose
For start service we use docker-compose file [docker-compose.yml](docker-compose.yml)

Docker-compose contains services:
- prometheus for collect metrics
- grafana for display metrics (with dashboards provision)
- weatherexporter for retrive temperature and export metrics
- traefik for reverse proxy to grafana with acme generated ssl certificate

### Github Variables for CI/CD
Option | Description
--- | ---
`AZURE_AD_CLIENT_ID`	| Azure AD Client ID
`AZURE_AD_CLIENT_SECRET` | Azure AD Client Secret
`AZURE_AD_TENANT_ID`	| Azure AD Tenant ID
`AZURE_SUBSCRIPTION_ID`  | Azure Subscription ID for Deployment
`DOCKER_HUB_ACCESS_TOKEN`	| Docker hub access token for push image
`DOCKER_HUB_USERNAME`  | Docker hub username for push image
`OWM_API_KEY`	| OpenWeatherMap api key for retrive data
`SERVER_NAME`	| HTTP Url for your server
`SSH_PRIVATE_KEY`	| SSH Private key for configure and deploy server
`TF_VAR_PUBLIC_KEY`	| SSH Public key for terraform configuration

### CI/CD
There are 3 workflow:
- [Check docker-compose file and check service can start (only PR trigger)](.github/workflows/compose.yml) 
- [Apply Terraform script and create VM in Azure (PR Check, Push Deploy)](.github/workflows/terraform.yml)
- [Configure Azure VM and deploy service (PR Check, Push Deploy)](.github/workflows/docker.yml)
