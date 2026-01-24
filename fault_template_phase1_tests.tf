// # ============================================================================
// # Fault Template Tests - Phase 1: Core Fields
// # ============================================================================
// # Tests: 5 comprehensive test cases covering core functionality
// # Coverage: identity, name, description, tags, category, infrastructure,
// #           basic spec (fault_name, params), kubernetes targets, variables
// # ============================================================================

// # Test 1: Basic Pod Delete Fault Template
// resource "harness_chaos_fault_template" "pod_delete_basic" {
//   org_id       = var.organization_id
//   project_id   = var.project_id
//   hub_identity = var.chaos_hub_identity

//   identity    = "tf-pod-delete-basic"
//   name        = "TF Pod Delete - Basic"
//   description = "Basic pod deletion fault template for testing"

//   infrastructure_type = "Kubernetes"
//   infrastructures     = ["k8s"]
//   category            = ["pods", "kubernetes"]
//   tags                = ["terraform", "test", "pod-delete", "basic"]

//   spec {
//     chaos {
//       fault_name = "pod-delete"

//       params {
//         name  = "TOTAL_CHAOS_DURATION"
//         value = "30"
//       }

//       params {
//         name  = "CHAOS_INTERVAL"
//         value = "10"
//       }

//       params {
//         name  = "FORCE"
//         value = "false"
//       }
//     }

//     target {
//       kubernetes {
//         kind      = "deployment"
//         namespace = "default"
//         labels = {
//           app = "nginx"
//         }
//       }
//     }
//   }

//   variables {
//     name        = "chaos_duration"
//     value       = "30"
//     type        = "string"
//     required    = false
//     description = "Duration of chaos in seconds"
//   }

//   variables {
//     name        = "target_namespace"
//     value       = "default"
//     type        = "string"
//     required    = true
//     description = "Target namespace for chaos"
//   }
// }

// # Test 2: Container Kill with Multiple Targets
// resource "harness_chaos_fault_template" "container_kill_multi" {
//   org_id       = var.organization_id
//   project_id   = var.project_id
//   hub_identity = var.chaos_hub_identity

//   identity    = "tf-container-kill-multi"
//   name        = "TF Container Kill - Multiple Targets"
//   description = "Container kill fault with multiple target configurations"

//   infrastructure_type = "Kubernetes"
//   infrastructures     = ["k8s"]
//   category            = ["pods", "containers"]
//   tags                = ["terraform", "container-kill", "multi-target"]
//   type                = "chaos"

//   spec {
//     chaos {
//       fault_name = "container-kill"

//       params {
//         name  = "TARGET_CONTAINER"
//         value = "nginx"
//       }

//       params {
//         name  = "CHAOS_DURATION"
//         value = "60"
//       }

//       params {
//         name  = "SIGNAL"
//         value = "SIGKILL"
//       }
//     }

//     target {
//       # Target 1: Deployment in default namespace
//       kubernetes {
//         kind      = "deployment"
//         namespace = "default"
//         labels = {
//           app  = "frontend"
//           tier = "web"
//         }
//       }

//       # Target 2: StatefulSet in production namespace
//       kubernetes {
//         kind      = "statefulset"
//         namespace = "production"
//         labels = {
//           app = "database"
//         }
//         names = ["postgres-0", "postgres-1"]
//       }
//     }
//   }

//   variables {
//     name        = "container_name"
//     value       = "<+input>"
//     type        = "string"
//     required    = true
//     description = "Name of the container to kill"
//   }

//   variables {
//     name        = "signal_type"
//     value       = "SIGKILL"
//     type        = "string"
//     required    = false
//     description = "Signal to send to container"
//   }
// }

// # Test 3: Network Chaos with Runtime Inputs
// resource "harness_chaos_fault_template" "network_loss_runtime" {
//   org_id       = var.organization_id
//   project_id   = var.project_id
//   hub_identity = var.chaos_hub_identity

//   identity    = "tf-network-loss-runtime"
//   name        = "TF Network Loss - Runtime Inputs"
//   description = "Network packet loss fault with runtime input variables"

//   infrastructure_type = "Kubernetes"
//   infrastructures     = ["k8s"]
//   category            = ["network", "kubernetes"]
//   tags                = ["terraform", "network", "runtime-inputs"]

//   spec {
//     chaos {
//       fault_name = "pod-network-loss"

//       params {
//         name  = "NETWORK_INTERFACE"
//         value = "eth0"
//       }

//       params {
//         name  = "NETWORK_PACKET_LOSS_PERCENTAGE"
//         value = "<+input>"
//       }

//       params {
//         name  = "TOTAL_CHAOS_DURATION"
//         value = "<+input>"
//       }

//       params {
//         name  = "TARGET_PODS"
//         value = "<+input>"
//       }
//     }

//     target {
//       kubernetes {
//         kind      = "deployment"
//         namespace = "<+input>"
//         labels = {
//           app = "<+input>"
//         }
//       }
//     }
//   }

//   variables {
//     name        = "packet_loss_percentage"
//     value       = "<+input>"
//     type        = "string"
//     required    = true
//     description = "Percentage of packets to drop (0-100)"
//   }

//   variables {
//     name        = "chaos_duration"
//     value       = "<+input>"
//     type        = "string"
//     required    = true
//     description = "Duration of chaos in seconds"
//   }

//   variables {
//     name        = "target_namespace"
//     value       = "<+input>"
//     type        = "string"
//     required    = true
//     description = "Namespace of target pods"
//   }

//   variables {
//     name        = "target_app_label"
//     value       = "<+input>"
//     type        = "string"
//     required    = true
//     description = "App label selector"
//   }
// }

// # Test 4: CPU Stress with Permissions
// resource "harness_chaos_fault_template" "cpu_stress_permissions" {
//   org_id       = var.organization_id
//   project_id   = var.project_id
//   hub_identity = var.chaos_hub_identity

//   identity    = "tf-cpu-stress-perms"
//   name        = "TF CPU Stress - With Permissions"
//   description = "CPU stress fault template with permission requirements"

//   infrastructure_type = "Kubernetes"
//   infrastructures     = ["k8s"]
//   category            = ["resource", "cpu", "stress"]
//   tags                = ["terraform", "cpu", "stress", "resource"]
//   permissions_required = "chaos.execute"

//   spec {
//     chaos {
//       fault_name = "pod-cpu-hog"

//       params {
//         name  = "CPU_CORES"
//         value = "2"
//       }

//       params {
//         name  = "TOTAL_CHAOS_DURATION"
//         value = "60"
//       }

//       params {
//         name  = "CPU_LOAD"
//         value = "100"
//       }

//       params {
//         name  = "PODS_AFFECTED_PERC"
//         value = "50"
//       }
//     }

//     target {
//       kubernetes {
//         kind      = "deployment"
//         namespace = "production"
//         labels = {
//           app     = "backend"
//           service = "api"
//         }
//       }
//     }
//   }

//   variables {
//     name        = "cpu_cores"
//     value       = "2"
//     type        = "string"
//     required    = false
//     description = "Number of CPU cores to stress"
//   }

//   variables {
//     name        = "cpu_load_percentage"
//     value       = "100"
//     type        = "string"
//     required    = false
//     description = "CPU load percentage (0-100)"
//   }

//   variables {
//     name        = "affected_pods_percentage"
//     value       = "50"
//     type        = "string"
//     required    = false
//     description = "Percentage of pods to affect"
//   }
// }

// # Test 5: Disk Fill with Multiple Parameters
// resource "harness_chaos_fault_template" "disk_fill_complex" {
//   org_id       = var.organization_id
//   project_id   = var.project_id
//   hub_identity = var.chaos_hub_identity

//   identity    = "tf-disk-fill-complex"
//   name        = "TF Disk Fill - Complex Parameters"
//   description = "Disk fill fault with complex parameter configuration"

//   infrastructure_type = "Kubernetes"
//   infrastructures     = ["k8s"]
//   category            = ["resource", "disk", "storage"]
//   tags                = ["terraform", "disk", "storage", "complex"]
//   type                = "chaos"
//   is_default          = false

//   spec {
//     chaos {
//       fault_name = "pod-disk-fill"

//       params {
//         name  = "FILL_PERCENTAGE"
//         value = "80"
//       }

//       params {
//         name  = "TOTAL_CHAOS_DURATION"
//         value = "120"
//       }

//       params {
//         name  = "TARGET_CONTAINER"
//         value = "app"
//       }

//       params {
//         name  = "CONTAINER_PATH"
//         value = "/tmp"
//       }

//       params {
//         name  = "EPHEMERAL_STORAGE_MEBIBYTES"
//         value = "1024"
//       }

//       params {
//         name  = "DATA_BLOCK_SIZE"
//         value = "256"
//       }
//     }

//     target {
//       kubernetes {
//         kind      = "statefulset"
//         namespace = "storage"
//         labels = {
//           app       = "database"
//           component = "primary"
//           tier      = "backend"
//         }
//         names = ["postgres-primary-0"]
//       }
//     }
//   }

//   variables {
//     name        = "fill_percentage"
//     value       = "80"
//     type        = "string"
//     required    = false
//     description = "Percentage of disk to fill"
//   }

//   variables {
//     name        = "chaos_duration"
//     value       = "120"
//     type        = "string"
//     required    = false
//     description = "Duration of chaos in seconds"
//   }

//   variables {
//     name        = "target_path"
//     value       = "/tmp"
//     type        = "string"
//     required    = false
//     description = "Path to fill with data"
//   }

//   variables {
//     name        = "storage_size_mb"
//     value       = "1024"
//     type        = "string"
//     required    = false
//     description = "Amount of storage to fill in MB"
//   }
// }

// # ============================================================================
// # Outputs for Testing
// # ============================================================================

// output "fault_template_pod_delete_id" {
//   description = "ID of pod delete fault template"
//   value       = harness_chaos_fault_template.pod_delete_basic.id
// }

// output "fault_template_pod_delete_identity" {
//   description = "Identity of pod delete fault template"
//   value       = harness_chaos_fault_template.pod_delete_basic.identity
// }

// output "fault_template_pod_delete_revision" {
//   description = "Revision of pod delete fault template"
//   value       = harness_chaos_fault_template.pod_delete_basic.revision
// }

// output "fault_template_container_kill_id" {
//   description = "ID of container kill fault template"
//   value       = harness_chaos_fault_template.container_kill_multi.id
// }

// output "fault_template_network_loss_id" {
//   description = "ID of network loss fault template"
//   value       = harness_chaos_fault_template.network_loss_runtime.id
// }

// output "fault_template_cpu_stress_id" {
//   description = "ID of CPU stress fault template"
//   value       = harness_chaos_fault_template.cpu_stress_permissions.id
// }

// output "fault_template_disk_fill_id" {
//   description = "ID of disk fill fault template"
//   value       = harness_chaos_fault_template.disk_fill_complex.id
// }

// # ============================================================================
// # Test Summary
// # ============================================================================
// # Test 1: Basic pod delete with simple params and single target
// # Test 2: Container kill with multiple kubernetes targets
// # Test 3: Network loss with full runtime inputs
// # Test 4: CPU stress with permissions and multiple labels
// # Test 5: Disk fill with complex parameters and statefulset target
// #
// # Coverage:
// # - ✅ Basic fields (identity, name, description)
// # - ✅ Tags and categories
// # - ✅ Infrastructure type and list
// # - ✅ Fault name and parameters
// # - ✅ Kubernetes targets (kind, namespace, labels, names)
// # - ✅ Variables (all types, required/optional)
// # - ✅ Runtime inputs (<+input>)
// # - ✅ Multiple targets
// # - ✅ Permissions
// # - ✅ Type and flags
// # ============================================================================
