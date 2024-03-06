variable "manifest" {
  type = object({
    path       = string
    apiVersion = string
    kind       = string
    metadata = object({
      name = string
    })
    spec = any
  })
}
