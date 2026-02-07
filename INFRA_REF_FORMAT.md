# Infrastructure Reference Format

## Date: January 24, 2026

---

## ✅ Correct Format

**Infrastructure Reference (`infra_ref`)**: `env_id/infra_id`

### Example:
```
tf_demo_env/harnesstf11
```

Where:
- `tf_demo_env` = Environment ID
- `harnesstf11` = Infrastructure ID

---

## 🔧 Usage in Experiments

### In Terraform:
```hcl
resource "harness_chaos_experiment" "example" {
  org_id            = "my-org"
  project_id        = "my-project"
  template_identity = "my-template"
  hub_identity      = "my-hub"
  name              = "My Experiment"
  infra_ref         = "tf_demo_env/harnesstf11"  # env_id/infra_id format
  import_type       = "REFERENCE"  # or "LOCAL"
}
```

---

## 📝 Variable Setup

### In variables.tf:
```hcl
variable "infra_ref" {
  description = "Infrastructure reference in format: env_id/infra_id"
  type        = string
  default     = "tf_demo_env/harnesstf11"
}
```

### Set via environment variable:
```bash
export TF_VAR_infra_ref="tf_demo_env/harnesstf11"
```

---

## ⚠️ Common Errors

### Error: "invalid infra id format"
**Cause**: Wrong format for `infra_ref`

**Wrong**:
```hcl
infra_ref = "harnesstf11"  # Missing env_id
infra_ref = "my-infra"      # Wrong format
```

**Correct**:
```hcl
infra_ref = "tf_demo_env/harnesstf11"  # env_id/infra_id
```

---

## 🎯 Format Rules

1. **Two parts**: Must have exactly two parts separated by `/`
2. **Environment ID first**: `env_id` comes before `/`
3. **Infrastructure ID second**: `infra_id` comes after `/`
4. **No spaces**: No spaces in the format
5. **Case sensitive**: Respect the case of IDs

---

## 📊 Examples

### Valid Formats:
```
tf_demo_env/harnesstf11
production-env/k8s-cluster-01
dev_environment/infra_123
my-env/my-infra
```

### Invalid Formats:
```
harnesstf11                    # Missing env_id
tf_demo_env                    # Missing infra_id
tf_demo_env/harnesstf11/extra  # Too many parts
tf_demo_env harnesstf11        # Missing slash
```

---

## 🔍 How to Find Your Values

### Environment ID:
- Check your Harness environment settings
- Usually in format: `env_name` or `env-name`

### Infrastructure ID:
- Check your Chaos infrastructure settings
- Usually in format: `infra_name` or `infra-name`

### Combined:
```
{environment_id}/{infrastructure_id}
```

---

## ✅ Testing

To test if your format is correct:

```bash
# Set the variable
export TF_VAR_infra_ref="your_env_id/your_infra_id"

# Validate
terraform validate

# Plan (will show if format is accepted)
terraform plan
```

---

## 📝 Summary

**Format**: `env_id/infra_id`  
**Example**: `tf_demo_env/harnesstf11`  
**Required**: Yes, for all experiments  
**Applies to**: Both REFERENCE and LOCAL import types

Make sure your `infra_ref` variable uses this exact format!
