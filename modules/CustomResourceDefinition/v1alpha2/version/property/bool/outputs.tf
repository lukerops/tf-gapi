output "options" {
  value = {
    type    = "bool"
    default = try(var.options.default, null)
  }
}
