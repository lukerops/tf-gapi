locals {
  error_messages = {
    field_not_found            = <<-EOT
      Invalid "version" for CustomResourceDefinition!
      The property "versions[%d].%s" are required.
      (metadata.name: "%s"; path: "%s")
    EOT
    wrong_specSchema_root_type = <<-EOT
      Invalid "version" for CustomResourceDefinition!
      The type for "versions[%d].specSchema.type" must be "object" (got "%s").
      (metadata.name: "%s"; path: "%s")
    EOT
    wrong_specSchema_properties_field_type = <<-EOT
      Invalid "version" for CustomResourceDefinition!
      The field "versions[%d].specSchema.properties" must be an object.
      (metadata.name: "%s"; path: "%s")
    EOT
    empty_specSchema_properties = <<-EOT
      Invalid "version" for CustomResourceDefinition!
      The field "versions[%d].specSchema.properties" must have at least one element.
      (metadata.name: "%s"; path: "%s")
    EOT
  }

  version_enabled    = try(var.schema_version.enabled, true)
  version_deprecated = try(var.schema_version.deprecated, false)
  specSchema_type    = try(var.schema_version.specSchema.type, "object")

  properties = try(var.schema_version.specSchema.properties, {})
  properties_size = try(length(keys(local.properties)), 1)
}

output "schema_version" {
  value = {
    name       = try(var.schema_version.name, null)
    enabled    = local.version_enabled
    deprecated = local.version_deprecated
    specSchema = {}
  }

  precondition {
    condition = can(var.schema_version.name)
    error_message = format(
      local.error_messages.field_not_found,
      var.index,
      "name",
      var.name,
      var.path,
    )
  }

  precondition {
    condition = can(var.schema_version.specSchema)
    error_message = format(
      local.error_messages.field_not_found,
      var.index,
      "specSchema",
      var.name,
      var.path,
    )
  }

  precondition {
    condition = can(var.schema_version.specSchema.type)
    error_message = format(
      local.error_messages.field_not_found,
      var.index,
      "specSchema.type",
      var.name,
      var.path,
    )
  }

  precondition {
    condition = local.specSchema_type == "object"
    error_message = format(
      local.error_messages.wrong_specSchema_root_type,
      var.index,
      local.specSchema_type,
      var.name,
      var.path,
    )
  }

  precondition {
    condition = can(var.schema_version.specSchema.properties)
    error_message = format(
      local.error_messages.field_not_found,
      var.index,
      "specSchema.properties",
      var.name,
      var.path,
    )
  }

  precondition {
    condition = can(tomap(local.properties))
    error_message = format(
      local.error_messages.wrong_specSchema_properties_field_type,
      var.index,
      var.name,
      var.path,
    )
  }

  precondition {
    condition = local.properties_size > 0
    error_message = format(
      local.error_messages.empty_specSchema_properties,
      var.index,
      var.name,
      var.path,
    )
  }
}
