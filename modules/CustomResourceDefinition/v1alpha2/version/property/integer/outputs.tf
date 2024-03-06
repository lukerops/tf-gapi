output "options" {
  value = {
    type    = "integer"
    minimum = try(tonumber(var.options.minimum), null)
    maximum = try(tonumber(var.options.maximum), null)
  }
}
