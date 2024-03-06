locals {
  error_messages = {
    field_not_found             = <<-EOT
      Invalid "version" for CustomResourceDefinition!
      The property "%s.%s" are required.
      (metadata.name: "%s"; path: "%s")
    EOT
    wrong_properties_field_type = <<-EOT
      Invalid "version" for CustomResourceDefinition!
      The field "%s.properties" must be an object.
      (metadata.name: "%s"; path: "%s")
    EOT
    empty_properties            = <<-EOT
      Invalid "version" for CustomResourceDefinition!
      The field "%s.properties" must have at least one element.
      (metadata.name: "%s"; path: "%s")
    EOT
  }

  properties      = try(var.options.properties, {})
  properties_size = try(length(keys(var.options.properties)), 1)
}

module "property" {
  source   = "./property/"
  for_each = toset(try(keys(local.properties), []))

  path     = var.path
  name     = var.name
  property = "${var.property}.properties.${each.key}"
  options  = local.properties[each.key]
}

output "options" {
  value = {
    type = "object"
    properties = {
      for property, result in module.property : property => result.options
    }
  }

  precondition {
    condition = can(var.options.properties)
    error_message = format(
      local.error_messages.field_not_found,
      var.property,
      "properties",
      var.name,
      var.path,
    )
  }

  precondition {
    condition = can(keys(local.properties))
    error_message = format(
      local.error_messages.wrong_properties_field_type,
      var.property,
      var.name,
      var.path,
    )
  }

  precondition {
    condition = local.properties_size > 0
    error_message = format(
      local.error_messages.empty_properties,
      var.property,
      var.name,
      var.path,
    )
  }
}
