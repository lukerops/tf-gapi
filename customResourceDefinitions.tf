locals {
  crd_manifests = [
    for manifest in module.manifests[*].manifest : manifest
    if manifest.apiVersion == "tf-gapi.lukerops.com/v1alpha1" && manifest.kind == "CustomResourceDefinition"
  ]
}

module "custom_resource_definitions_v1alpha1" {
  source = "./validations/CustomResourceDefinition/v1alpha1/"
  count  = length(local.crd_manifests)

  manifest = local.crd_manifests[count.index]
}