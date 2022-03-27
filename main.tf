data "huaweicloud_availability_zones" "myaz" {}

module "vpc" {
  source        = "github.com/tecbrix/terraform-huaweicloud-vpc"
  primary_dns   = "100.125.128.250"
  secondary_dns = "100.125.1.250"
}

module "cce" {
  depends_on  = [module.vpc]
  source      = "github.com/tecbrix/terraform-huaweicloud-cce"
  subnet_id   = module.vpc.subnetid
  vpc_id      = module.vpc.vpcid
  node_flavor = "s6.large.4"
}

provider "helm" {
  kubernetes {
    host                   = module.cce.certificate_clusters.1.server
    insecure               = true
    client_certificate     = base64decode(module.cce.certificate_users.0.client_certificate_data)
    client_key             = base64decode(module.cce.certificate_users.0.client_key_data)
    cluster_ca_certificate = base64decode(module.cce.certificate_clusters.1.certificate_authority_data)
  }
}

# resource "local_file" "kubeconfig" {
#     content     = module.cce.kube_config_raw
#     filename    = "kubeconfig.json"
# }

resource "helm_release" "ecommdemo" {
  depends_on       = [module.cce]
  name             = "ecommdemo"
  repository       = "https://tecbrix.github.io/helm-charts"
  chart            = "huaweicloud-ecommdemo"
  namespace        = var.namespace
  timeout          = "300"
  create_namespace = true

  set {
    name  = "service.subnetID"
    value = module.vpc.subnetid
  }
}
