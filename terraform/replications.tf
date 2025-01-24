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
