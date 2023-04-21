# https://registry.terraform.io/providers/scaleway/scaleway/latest/docs/resources/k8s_cluster

resource "scaleway_k8s_cluster" "main" {
  name    = var.name
  version = var.kubernetes_version
  region  = var.region
  cni     = "calico"
  tags    = [for k, v in var.tags : "${k}::${v}"]
  # true means that you will lose all your cluster data and network configuration when you delete your cluster
  delete_additional_resources = true

  autoscaler_config {
    disable_scale_down              = false
    scale_down_delay_after_add      = "5m"
    estimator                       = "binpacking"
    expander                        = "random"
    ignore_daemonsets_utilization   = true
    balance_similar_node_groups     = true
    expendable_pods_priority_cutoff = -5
  }
}

locals {
  region_to_zones = {
    "fr-par" = ["fr-par-1", "fr-par-2", "fr-par-3"]
    "nl-ams" = ["nl-ams-1", "nl-ams-2"]
    "pl-waw" = ["pl-waw-1"]
  }
}

resource "scaleway_k8s_pool" "main" {
  for_each    = { for group in var.node_groups : group.name => group }
  cluster_id  = scaleway_k8s_cluster.main.id
  name        = each.value.name
  tags        = [for k, v in var.tags : "${k}::${v}"]
  node_type   = each.value.machine_type
  size        = each.value.min_size
  autoscaling = true
  autohealing = true
  min_size    = each.value.min_size
  max_size    = each.value.max_size
  region      = var.region
  zone        = local.region_to_zones[var.region][0]

  lifecycle {
    create_before_destroy = true
  }
}
