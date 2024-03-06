output "options" {
  value = {
    type      = "string"
    minLength = try(tonumber(var.options.minLength), null)
    maxLength = try(tonumber(var.options.maxLength), null)
  }
}
