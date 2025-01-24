resource "harbor_project" "myProject" {
  name                   = "myProject"
  public                 = true         # (Optional) Default value is false
  vulnerability_scanning = false        # (Optional) Default value is true. Automatically scan images on push
}
