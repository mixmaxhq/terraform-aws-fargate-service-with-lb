locals {
  environment = "staging"
  app_name    = "rjt-test-terraform"
  image       = "nginxdemos/hello"
}

module "web" {
  source      = "../.."
  environment = local.environment
  name        = local.app_name
  image       = local.image
  cpu         = 256
  memory      = 512

  environment_vars = [{ "name" : "Name", "value" : local.app_name }]
}
