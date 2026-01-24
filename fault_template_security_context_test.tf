# Fault template test with security contexts
# Based on successful curl response showing security context support

# NOTE: This test requires security context BUILD functions to be implemented
# Currently commented out - uncomment when security context support is added

# resource "harness_chaos_fault_template" "with_security_contexts" {
#   depends_on = [
#     harness_chaos_hub_v2.project_level
#   ]
#   org_id       = local.org_id
#   project_id   = local.project_id
#   hub_identity = var.probe_test_hub_identity != "" ? var.probe_test_hub_identity : harness_chaos_hub_v2.project_level[0].identity

#   identity    = "tf-security-context-test"
#   name        = "TF Security Context Test"
#   description = "Fault template with pod and container security contexts"

#   infrastructures      = ["KubernetesV2"]
#   category             = ["Kubernetes"]
#   type                 = "Custom"
#   tags                 = ["terraform", "security", "test"]
#   permissions_required = "Basic"

#   links {
#     name = "Permissions"
#     url  = ""
#   }

#   spec {
#     chaos {
#       fault_name = "byoc-injector"

#       params {
#         name  = "CHAOS_DURATION"
#         value = "30s"
#       }

#       kubernetes {
#         image = "harness/custom:ci"

#         # Pod Security Context
#         pod_security_context {
#           run_as_user  = 223
#           run_as_group = 219
#           fs_group     = 222
#         }

#         # Container Security Context with Capabilities
#         container_security_context {
#           privileged                   = true
#           read_only_root_filesystem    = true
#           allow_privilege_escalation   = true

#           capabilities {
#             add  = ["NET_ADMIN", "SYS_ADMIN"]
#             drop = ["SYS_ADMIN", "NET_ADMIN"]
#           }
#         }
#       }
#     }
#   }
# }

# output "security_context_fault_template_id" {
#   value = harness_chaos_fault_template.with_security_contexts.id
# }

# ============================================================================
# IMPLEMENTATION NOTE
# ============================================================================
# This test is commented out because security context BUILD functions
# are not yet implemented. The API supports these fields (confirmed via curl),
# and our READ functions can parse them, but we need to add BUILD support.
#
# To enable this test:
# 1. Implement pod_security_context BUILD in buildChaosKubernetesSpec()
# 2. Implement container_security_context BUILD with capabilities
# 3. Uncomment this test
# 4. Run terraform apply
#
# Estimated effort: 2-3 hours
# Priority: P1 (High impact for security-sensitive faults)
# ============================================================================
