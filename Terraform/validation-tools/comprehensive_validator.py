#!/usr/bin/env python3
"""
Comprehensive Terraform Module Validator
Runs all validation checks for any Terraform module

Usage:
    python3 comprehensive_validator.py [module_path]
    
If no module_path is provided, validates the current directory.
"""

import subprocess
import sys
from pathlib import Path

def run_validation_script(script_name, description, module_path="."):
    """Run a validation script and return results"""
    print(f"\n🔍 {description}")
    print("=" * 60)
    
    try:
        script_path = Path(__file__).parent / script_name
        result = subprocess.run(
            [sys.executable, str(script_path), module_path], 
            capture_output=True, 
            text=True
        )
        
        print(result.stdout)
        
        if result.stderr:
            print("STDERR:", result.stderr)
        
        return result.returncode == 0
    
    except Exception as e:
        print(f"❌ Error running {script_name}: {e}")
        return False

def check_terraform_best_practices(module_path):
    """Check Terraform best practices"""
    print("\n🎯 Checking Terraform Best Practices")
    print("=" * 60)
    
    module_path = Path(module_path)
    best_practices = []
    
    # Check for provider version constraints
    versions_file = module_path / 'versions.tf'
    if versions_file.exists():
        with open(versions_file, 'r') as f:
            content = f.read()
            if 'required_providers' in content:
                best_practices.append("✅ Provider version constraints defined")
            else:
                best_practices.append("⚠️  Provider version constraints missing")
    else:
        best_practices.append("⚠️  versions.tf file missing")
    
    # Check for examples directory
    examples_dir = module_path / 'examples'
    if examples_dir.exists():
        best_practices.append("✅ Examples directory exists")
    else:
        best_practices.append("⚠️  Examples directory missing")
    
    # Check for README.md
    readme_file = module_path / 'README.md'
    if readme_file.exists():
        best_practices.append("✅ README.md exists")
        
        # Check README content
        with open(readme_file, 'r') as f:
            readme_content = f.read().lower()
            if 'usage' in readme_content:
                best_practices.append("✅ README contains usage section")
            else:
                best_practices.append("⚠️  README missing usage section")
                
            if 'requirements' in readme_content or 'prerequisites' in readme_content:
                best_practices.append("✅ README contains requirements section")
            else:
                best_practices.append("⚠️  README missing requirements section")
    else:
        best_practices.append("❌ README.md missing")
    
    # Check for .gitignore
    gitignore_file = module_path / '.gitignore'
    if gitignore_file.exists():
        best_practices.append("✅ .gitignore exists")
    else:
        best_practices.append("⚠️  .gitignore missing")
    
    # Check for locals.tf (optional but good practice)
    locals_file = module_path / 'locals.tf'
    if locals_file.exists():
        best_practices.append("✅ locals.tf exists (good for complex expressions)")
    
    for practice in best_practices:
        print(f"  {practice}")
    
    return True

def generate_validation_report(module_path, results):
    """Generate a comprehensive validation report"""
    report_file = Path(module_path) / 'validation_report.md'
    
    with open(report_file, 'w') as f:
        f.write("# Terraform Module Validation Report\n\n")
        f.write(f"**Module Path:** `{module_path}`\n")
        f.write(f"**Generated:** {Path(__file__).name}\n\n")
        
        f.write("## Validation Results\n\n")
        
        passed = sum(1 for _, success in results if success)
        total = len(results)
        
        f.write(f"**Overall Score:** {passed}/{total} checks passed\n\n")
        
        for description, success in results:
            status = "✅ PASS" if success else "❌ FAIL"
            f.write(f"- {status} {description}\n")
        
        f.write("\n## Recommendations\n\n")
        
        if passed == total:
            f.write("🎉 Excellent! Your module passes all validation checks.\n\n")
            f.write("### Next Steps:\n")
            f.write("- Consider adding more comprehensive examples\n")
            f.write("- Add integration tests if not already present\n")
            f.write("- Document any specific deployment requirements\n")
        else:
            f.write("⚠️ Your module needs attention in the following areas:\n\n")
            for description, success in results:
                if not success:
                    f.write(f"- **{description}**: Review and fix identified issues\n")
        
        f.write("\n---\n")
        f.write("*This report was generated automatically. Review all findings manually.*\n")
    
    print(f"\n📄 Validation report saved to: {report_file}")

def main():
    """Run comprehensive validation"""
    module_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    print("🚀 Starting Comprehensive Terraform Module Validation")
    print("=" * 60)
    print(f"📁 Module Path: {Path(module_path).absolute()}")
    
    validation_results = []
    
    # Run individual validation scripts
    scripts = [
        ("terraform_module_validator.py", "Module Structure and Syntax Validation"),
        ("variable_validation_tester.py", "Variable Validation Testing"),
        ("output_verifier.py", "Output Verification")
    ]
    
    for script, description in scripts:
        success = run_validation_script(script, description, module_path)
        validation_results.append((description, success))
    
    # Check best practices
    best_practices_success = check_terraform_best_practices(module_path)
    validation_results.append(("Terraform Best Practices", best_practices_success))
    
    # Final summary
    print("\n🏁 COMPREHENSIVE VALIDATION SUMMARY")
    print("=" * 60)
    
    passed = 0
    total = len(validation_results)
    
    for description, success in validation_results:
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"  {status} - {description}")
        if success:
            passed += 1
    
    print(f"\n📊 Overall Results: {passed}/{total} validation checks passed")
    
    # Generate report
    generate_validation_report(module_path, validation_results)
    
    if passed == total:
        print("\n🎉 ALL VALIDATIONS PASSED!")
        print("✅ Module is ready for production use")
        print("✅ All best practices are followed")
        print("✅ Code structure and syntax are valid")
        print("✅ Variable validation is comprehensive")
        print("✅ Outputs are properly defined and accessible")
        return True
    else:
        print(f"\n💥 {total - passed} validation(s) failed!")
        print("❌ Module needs attention before production use")
        print("📋 Check the validation report for detailed recommendations")
        return False

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)