// # ============================================================================
// # Fault Template Data Source Tests
// # ============================================================================
// # Tests data source lookup by identity and name
// # ============================================================================

// # Data Source Test 1: Lookup by Identity (RECOMMENDED)
// data "harness_chaos_fault_template" "pod_delete_by_identity" {
//   org_id       = var.organization_id
//   project_id   = var.project_id
//   hub_identity = var.chaos_hub_identity
  
//   identity = harness_chaos_fault_template.pod_delete_basic.identity
// }

// # Data Source Test 2: Lookup by Name (may have timing issues)
// data "harness_chaos_fault_template" "container_kill_by_name" {
//   org_id       = var.organization_id
//   project_id   = var.project_id
//   hub_identity = var.chaos_hub_identity
  
//   name = "TF Container Kill - Multiple Targets"
  
//   # Note: This depends on the resource being created first
//   depends_on = [harness_chaos_fault_template.container_kill_multi]
// }

// # ============================================================================
// # Outputs to verify data source functionality
// # ============================================================================

// output "data_source_pod_delete_identity" {
//   description = "Identity from data source lookup"
//   value       = data.harness_chaos_fault_template.pod_delete_by_identity.identity
// }

// output "data_source_pod_delete_name" {
//   description = "Name from data source lookup"
//   value       = data.harness_chaos_fault_template.pod_delete_by_identity.name
// }

// output "data_source_pod_delete_description" {
//   description = "Description from data source lookup"
//   value       = data.harness_chaos_fault_template.pod_delete_by_identity.description
// }

// output "data_source_pod_delete_tags" {
//   description = "Tags from data source lookup"
//   value       = data.harness_chaos_fault_template.pod_delete_by_identity.tags
// }

// output "data_source_pod_delete_revision" {
//   description = "Revision from data source lookup"
//   value       = data.harness_chaos_fault_template.pod_delete_by_identity.revision
// }

// output "data_source_container_kill_identity" {
//   description = "Identity from name-based lookup"
//   value       = data.harness_chaos_fault_template.container_kill_by_name.identity
// }

// output "data_source_container_kill_infrastructure_type" {
//   description = "Infrastructure type from name-based lookup"
//   value       = data.harness_chaos_fault_template.container_kill_by_name.infrastructure_type
// }

// # ============================================================================
// # Verification Tests
// # ============================================================================

// # Verify identity lookup matches resource
// output "identity_lookup_matches" {
//   description = "Verify identity lookup returns correct template"
//   value = (
//     data.harness_chaos_fault_template.pod_delete_by_identity.identity == 
//     harness_chaos_fault_template.pod_delete_basic.identity
//   )
// }

// # Verify name lookup matches resource
// output "name_lookup_matches" {
//   description = "Verify name lookup returns correct template"
//   value = (
//     data.harness_chaos_fault_template.container_kill_by_name.name == 
//     harness_chaos_fault_template.container_kill_multi.name
//   )
// }

// # ============================================================================
// # Usage Notes
// # ============================================================================
// # 
// # Identity-based lookup (RECOMMENDED):
// # - Fast and reliable
// # - No timing issues
// # - Use when you know the identity
// #
// # Name-based lookup:
// # - May have timing issues with newly created templates
// # - API's ListFaultTemplate may not return newly created templates immediately
// # - Use depends_on to ensure resource is created first
// # - Best for referencing existing templates
// #
// # ============================================================================
