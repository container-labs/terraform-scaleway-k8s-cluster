variable "name" {
  type        = string
  description = "The name of the k8s cluster"
}

variable "tags" {
  type = map(any)
}

variable "kubernetes_version" {
  type = string
}

variable "region" {
  type = string
}

variable "node_groups" {
  type = any
}
