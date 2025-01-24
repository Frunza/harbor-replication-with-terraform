resource "harbor_registry" "docker-hub" {
  provider_name = "docker-hub"
  name          = "dockerhub"
  endpoint_url  = "https://hub.docker.com"
}
