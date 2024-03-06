locals {
  error_messages = {
    null_value    = <<-EOT
      Invalid resource manifest!
      The property "%s" is null and no default value was defined.
      (metadata.name: "%s"; path: "%s")
    EOT
    invalid_value = <<-EOT
      Invalid resource manifest!
      The type of the property "%s" must be bool.
      (metadata.name: "%s"; path: "%s")
    EOT
  }

  has_default_value    = try(var.schema.default, null) != null
  default_value        = try(var.schema.default, null)
  property_final_value = var.value != null ? var.value : local.has_default_value ? local.default_value : null

}

output "value" {
  value = tobool(local.property_final_value)

  precondition {
    condition = local.property_final_value != null
    error_message = format(
      local.error_messages.null_value,
      var.property,
      var.name,
      var.path,
    )
  }

  precondition {
    condition = can(tobool(local.property_final_value))
    error_message = format(
      local.error_messages.invalid_value,
      var.property,
      var.name,
      var.path,
    )
  }
}
