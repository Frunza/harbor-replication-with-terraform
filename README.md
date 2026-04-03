# Harbor replication with Terraform

## Scenario

If you have a `Harbor` installation, how to you make sure that everything works fine, by replicating some public repository? Since `Terraform` has a provider for `Harbor` this should be dine as infrastructure as code.

## Prerequisites

A Linux or MacOS machine for local development. If you are running Windows, you first need to set up the *Windows Subsystem for Linux (WSL)* environment.

You need `docker cli` on your machine for testing purposes, and/or on the machines that run your pipeline.
You can verify this by running the following command:
```sh
docker --version
```

Set the following environment variable for `Harbor` access:
- HARBOR_URL
- HARBOR_USERNAME
- HARBOR_PASSWORD

Set the following environment variables that are needed for *GitLab* authentication, the place where the terraform state files are stored:
- TF_HTTP_USERNAME
- TF_HTTP_PASSWORD

## Implementation

We want to run everything in a docker container, so let's create the `dockerfile`:
 ```sh
FROM hashicorp/terraform:1.5.0

COPY . /infrastructure
WORKDIR /infrastructure
```

Let's inject the environment variables and terraform commands in a `docker compose` file:
 ```sh
version: '3.9'

services:
  mainservice:
    image: harborreplication
    network_mode: host
    working_dir: /infrastructure
    environment:
      - TF_HTTP_USERNAME=${TF_HTTP_USERNAME}
      - TF_HTTP_PASSWORD=${TF_HTTP_PASSWORD}
      - HARBOR_URL=${HARBOR_URL}
      - HARBOR_USERNAME=${HARBOR_USERNAME}
      - HARBOR_PASSWORD=${HARBOR_PASSWORD}
    entrypoint: ["sh", "-c"]
    command: ["cd terraform && terraform init && terraform validate && terraform apply -auto-approve"]
```

Now comes the `Terraform` part. First of all, we must configure the `Harbor` provider:
 ```sh
terraform {
  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = "3.10.15"
    }
  }
}

# Configure the Harbor Provider
# Credentials can be provided by using the HARBOR_URL, HARBOR_USERNAME and HARBOR_PASSWORD environment variables. (https://registry.terraform.io/providers/goharbor/harbor/latest/docs)
provider "harbor" {
}
```

To create a replication, we need a destination and some source.
The destination is a `Harbor` project:
```sh
resource "harbor_project" "myProject" {
  name                   = "myProject"
  public                 = true         # (Optional) Default value is false
  vulnerability_scanning = false        # (Optional) Default value is true. Automatically scan images on push
}
```

The source will be some project from `docker-hub`, so let's configure a registry for it:
```sh
resource "harbor_registry" "docker-hub" {
  provider_name = "docker-hub"
  name          = "dockerhub"
  endpoint_url  = "https://hub.docker.com"
}
```

Now we can create the replication:
```sh
resource "harbor_replication" "replicationMyProject" {
  name                   = "replication-test-dockerhub"
  action                 = "pull"
  registry_id            = harbor_registry.docker-hub.registry_id
  schedule               = "0 */6 * * * *"
  dest_namespace         = harbor_project.myProject.name
  dest_namespace_replace = 0
  filters {
    name = "library/hello-world"
  }
  filters {
    tag = "nanoserver-ltsc2022"
  }
}
```
If you want to trigger the replication manually via the `Harbor` user interface remove the *schedule* parameter.

## Usage

You can create a script to run the code inside a container:
```sh
#!/bin/sh

# Exit immediately if a simple command exits with a nonzero exit value
set -e

docker build -f docker/dockerfile -t harborreplication .
docker compose -f docker/docker-compose.yml run --rm mainservice
```
