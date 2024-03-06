locals {
  error_messages = {
    field_not_found       = <<-EOT
      Invalid "version" for CustomResourceDefinition!
      The property "%s.%s" are required.
      (metadata.name: "%s"; path: "%s")
    EOT
    invalid_property_type = <<-EOT
      Invalid "version" for CustomResourceDefinition!
      The type for the property "%s.items.type" must be one of %#v (got "%s").
      (metadata.name: "%s"; path: "%s")
    EOT
  }

  valid_types = ["string", "integer", "object", "bool"]
  type        = try(var.options.items.type, "empty")

  common_options = {
    description  = try(var.options.description, null)
    externalDocs = try(var.options.externalDocs, null)
  }
  options = flatten([
    module.string[*].options,
    module.integer[*].options,
    module.bool[*].options,
    module.object[*].options,
  ])
}

module "string" {
  source = "../string/"
  count  = local.type == "string" ? 1 : 0

  path     = var.path
  name     = var.name
  property = "${var.property}.items"
  options  = try(var.options.items, {})
}

module "integer" {
  source = "../integer/"
  count  = local.type == "integer" ? 1 : 0

  path     = var.path
  name     = var.name
  property = "${var.property}.items"
  options  = try(var.options.items, {})
}

module "bool" {
  source = "../bool/"
  count  = local.type == "bool" ? 1 : 0

  path     = var.path
  name     = var.name
  property = "${var.property}.items"
  options  = try(var.options.items, {})
}

module "object" {
  source = "../object/"
  count  = local.type == "object" ? 1 : 0

  path     = var.path
  name     = var.name
  property = "${var.property}.items"
  options  = try(var.options.items, {})
}

output "options" {
  value = {
    type     = "array"
    minItems = try(tonumber(var.options.minItems), null)
    maxItems = try(tonumber(var.options.maxItems), null)
    items    = merge(local.common_options, local.options...)
  }

  precondition {
    condition = can(var.options.items)
    error_message = format(
      local.error_messages.field_not_found,
      var.property,
      "items",
      var.name,
      var.path,
    )
  }

  precondition {
    condition = can(var.options.items.type)
    error_message = format(
      local.error_messages.field_not_found,
      var.property,
      "items.type",
      var.name,
      var.path,
    )
  }

  precondition {
    condition = try(contains(local.valid_types, var.options.items.type), true)
    error_message = format(
      local.error_messages.invalid_property_type,
      var.property,
      local.valid_types,
      local.type,
      var.name,
      var.path,
    )
  }
}
