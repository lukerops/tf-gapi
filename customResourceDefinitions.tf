locals {
  v1alpha1_manifests = [
    for manifest in module.manifests[*].manifest : manifest
    if manifest.apiVersion == "tf-gapi.lukerops.com/v1alpha1" && manifest.kind == "CustomResourceDefinition"
  ]

  v1alpha2_manifests = [
    for manifest in module.manifests[*].manifest : manifest
    if manifest.apiVersion == "tf-gapi.lukerops.com/v1alpha2" && manifest.kind == "CustomResourceDefinition"
  ]
}

module "custom_resource_definitions_v1alpha1" {
  source = "./modules/CustomResourceDefinition/v1alpha1/"
  count  = length(local.v1alpha1_manifests)

  manifest = local.v1alpha1_manifests[count.index]
}

module "custom_resource_definitions_v1alpha2" {
  source = "./modules/CustomResourceDefinition/v1alpha2/"
  count  = length(local.v1alpha2_manifests)

  manifest = local.v1alpha2_manifests[count.index]
}
