locals {
  resource_manifests = [
    for manifest in module.manifests[*].manifest : manifest
    if !(strcontains(manifest.apiVersion, "tf-gapi.lukerops.com") && manifest.kind == "CustomResourceDefinition")
  ]
}

module "resources" {
  source = "./modules/resource/"
  count  = length(local.resource_manifests)

  manifest = local.resource_manifests[count.index]
  custom_resource_definitions = flatten(concat(
    module.custom_resource_definitions_v1alpha1[*].schemas,
    module.custom_resource_definitions_v1alpha2[*].schemas,
  ))
}
