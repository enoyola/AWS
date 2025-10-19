# Terraform Module Validation Tools

A comprehensive set of Python scripts for validating Terraform modules. These tools help ensure your Terraform modules follow best practices, have proper syntax, and are well-structured.

## Tools Overview

### 1. `terraform_module_validator.py`
**Purpose:** Validates basic module structure and syntax
- ✅ Checks for required files (main.tf, variables.tf, outputs.tf, versions.tf)
- ✅ Validates Terraform syntax (balanced brackets, quotes)
- ✅ Verifies resource definitions and naming conventions
- ✅ Checks variable usage and output definitions

### 2. `variable_validation_tester.py`
**Purpose:** Tests variable validation rules with various input combinations
- ✅ Generates test cases based on variable names and types
- ✅ Simulates Terraform validation logic
- ✅ Tests edge cases and invalid inputs
- ✅ Provides comprehensive test coverage reports

### 3. `output_verifier.py`
**Purpose:** Verifies output definitions and resource references
- ✅ Validates output descriptions and values
- ✅ Checks resource reference validity
- ✅ Analyzes output organization and structure
- ✅ Identifies common output patterns

### 4. `comprehensive_validator.py`
**Purpose:** Runs all validation tools and generates a report
- ✅ Executes all individual validators
- ✅ Checks Terraform best practices
- ✅ Generates markdown validation report
- ✅ Provides actionable recommendations

## Usage

### Quick Start
```bash
# Validate current directory
python3 comprehensive_validator.py

# Validate specific module
python3 comprehensive_validator.py /path/to/terraform/module
```

### Individual Tools
```bash
# Basic module validation
python3 terraform_module_validator.py [module_path]

# Variable validation testing
python3 variable_validation_tester.py [module_path]

# Output verification
python3 output_verifier.py [module_path]
```

## Requirements

- Python 3.6+
- No external dependencies (uses only standard library)

## Example Output

```
🚀 Starting Comprehensive Terraform Module Validation
============================================================
📁 Module Path: /path/to/your/module

🔍 Module Structure and Syntax Validation
============================================================
✓ Required file exists: main.tf
✓ Required file exists: variables.tf
✓ Required file exists: outputs.tf
✓ Required file exists: versions.tf
✓ Found 13 resource blocks
✓ Found 11 variable definitions
✓ Found 22 output definitions

🔍 Variable Validation Testing
============================================================
🧪 Testing Variable Validation Rules...
✅ PASS | Valid private CIDR
✅ PASS | Invalid CIDR format
📊 Test Summary: 40/40 tests passed

🔍 Output Verification
============================================================
✅ Valid reference: aws_instance.example
✅ Output 'instance_id' has description
📊 Available Resources (14)

🎯 Checking Terraform Best Practices
============================================================
✅ Provider version constraints defined
✅ README.md exists
✅ Examples directory exists

🏁 COMPREHENSIVE VALIDATION SUMMARY
============================================================
✅ PASS - Module Structure and Syntax Validation
✅ PASS - Variable Validation Testing
✅ PASS - Output Verification
✅ PASS - Terraform Best Practices

📊 Overall Results: 4/4 validation checks passed
🎉 ALL VALIDATIONS PASSED!
```

## Validation Report

The comprehensive validator generates a `validation_report.md` file with:
- Overall validation score
- Detailed results for each check
- Specific recommendations for improvements
- Next steps for module enhancement

## Supported Patterns

### Variable Validation
- **Regions:** `us-east-1`, `eu-west-1` format validation
- **CIDR blocks:** IPv4 CIDR notation validation
- **Instance types:** AWS instance type format validation
- **Names/Prefixes:** Naming convention validation
- **AMI IDs:** AWS AMI identifier format validation
- **Lists and booleans:** Type-specific validation

### Resource References
- **AWS resources:** `aws_*` resource validation
- **Azure resources:** `azurerm_*` resource validation
- **GCP resources:** `google_*` resource validation
- **Data sources:** `data.*` reference validation
- **Variables and locals:** `var.*` and `local.*` references

## Best Practices Checked

- ✅ Provider version constraints
- ✅ Required file structure
- ✅ Documentation (README.md)
- ✅ Examples directory
- ✅ Variable descriptions and validation
- ✅ Output descriptions
- ✅ Naming conventions
- ✅ Resource organization

## Customization

You can easily extend these tools by:

1. **Adding new validation patterns** in the respective scripts
2. **Modifying test cases** for your specific use cases
3. **Adding provider-specific checks** for other cloud providers
4. **Customizing best practice rules** for your organization

## Integration

These tools can be integrated into:
- **CI/CD pipelines** for automated validation
- **Pre-commit hooks** for development workflow
- **Module development** for continuous validation
- **Code review processes** for quality assurance

## Contributing

Feel free to extend these tools for your specific needs:
- Add support for additional cloud providers
- Implement more sophisticated validation logic
- Add integration with terraform validate/plan
- Create custom validation rules for your organization

## License

These tools are provided as-is for educational and development purposes. Modify and use them according to your needs.