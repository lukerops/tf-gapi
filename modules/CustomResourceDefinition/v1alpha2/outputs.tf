locals {
  error_messages = {
    field_not_found              = <<-EOT
      Invalid "spec" for CustomResourceDefinition!
      The property "spec.%s" are required.
      (metadata.name: "%s"; path: "%s")
    EOT
    invalid_metadata_name        = <<-EOT
      Invalid "name" for CustomResourceDefinition!
      The "metadata.name" must be in the format "<lower case kind>.<group>".
      (metadata.name: "%s"; path: "%s")
    EOT
    kind_not_camel_cased         = <<-EOT
      Invalid "spec.kind" for CustomResourceDefinition!
      The "spec.kind" must be CamelCased.
      (metadata.name: "%s"; path: "%s")
    EOT
    versions_field_is_not_a_list = <<-EOT
      Invalid "spec.versions" for CustomResourceDefinition!
      The "spec.versions" must be a list.
      (metadata.name: "%s"; path: "%s")
    EOT
    invalid_versions_size        = <<-EOT
      Invalid "spec.versions" for CustomResourceDefinition!
      The "spec.versions" must have at least 1 element.
      (metadata.name: "%s"; path: "%s")
    EOT
  }

  kind_first_letter = try(substr(var.manifest.spec.kind, 0, 1), "")
}

module "version" {
  source = "./version/"
  count  = try(length(var.manifest.spec.versions), 0)

  path           = var.manifest.path
  name           = try(var.manifest.metadata.name, null)
  index          = count.index
  schema_version = var.manifest.spec.versions[count.index]
}

output "schemas" {
  value = [
    for version in module.version[*].schema_version : {
      path       = var.manifest.path
      apiVersion = try("${var.manifest.spec.group}/${version.name}", null)
      kind       = try(var.manifest.spec.kind, null)
      enabled    = version.enabled
      deprecated = version.deprecated
      specSchema = version.specSchema
    }
  ]

  precondition {
    condition = can(var.manifest.spec.group)
    error_message = format(
      local.error_messages.field_not_found,
      "group",
      var.manifest.metadata.name,
      var.manifest.path,
    )
  }

  precondition {
    condition = can(var.manifest.spec.kind)
    error_message = format(
      local.error_messages.field_not_found,
      "kind",
      var.manifest.metadata.name,
      var.manifest.path,
    )
  }

  precondition {
    condition = can(var.manifest.spec.versions)
    error_message = format(
      local.error_messages.field_not_found,
      "versions",
      var.manifest.metadata.name,
      var.manifest.path,
    )
  }

  precondition {
    condition = try(
      var.manifest.metadata.name == "${lower(var.manifest.spec.kind)}.${var.manifest.spec.group}",
      true,
    )
    error_message = format(
      local.error_messages.invalid_metadata_name,
      var.manifest.metadata.name,
      var.manifest.path,
    )
  }

  precondition {
    condition = local.kind_first_letter == upper(local.kind_first_letter)
    error_message = format(
      local.error_messages.kind_not_camel_cased,
      var.manifest.metadata.name,
      var.manifest.path,
    )
  }

  precondition {
    condition = can(tolist(var.manifest.spec.versions))
    error_message = format(
      local.error_messages.versions_field_is_not_a_list,
      var.manifest.metadata.name,
      var.manifest.path,
    )
  }

  precondition {
    condition = try(
      length(var.manifest.spec.versions) > 0,
      true,
    )
    error_message = format(
      local.error_messages.invalid_versions_size,
      var.manifest.metadata.name,
      var.manifest.path,
    )
  }
}
