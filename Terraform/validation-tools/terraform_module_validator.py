#!/usr/bin/env python3
"""
Terraform Module Validation Script
Performs static analysis and validation of Terraform modules

Usage:
    python3 terraform_module_validator.py [module_path]
    
If no module_path is provided, validates the current directory.
"""

import os
import re
import json
import sys
from pathlib import Path

class TerraformModuleValidator:
    def __init__(self, module_path="."):
        self.module_path = Path(module_path)
        self.errors = []
        self.warnings = []
        self.info = []
        
    def validate_file_structure(self):
        """Validate that required files exist"""
        required_files = ['main.tf', 'variables.tf', 'outputs.tf', 'versions.tf']
        recommended_files = ['README.md', 'examples/']
        
        for file in required_files:
            file_path = self.module_path / file
            if file_path.exists():
                self.info.append(f"✓ Required file exists: {file}")
            else:
                self.errors.append(f"✗ Missing required file: {file}")
        
        for file in recommended_files:
            file_path = self.module_path / file
            if file_path.exists():
                self.info.append(f"✓ Recommended file/directory exists: {file}")
            else:
                self.warnings.append(f"⚠ Missing recommended file/directory: {file}")
    
    def validate_terraform_syntax(self):
        """Basic Terraform syntax validation"""
        tf_files = list(self.module_path.glob('*.tf'))
        
        for tf_file in tf_files:
            self.info.append(f"Checking syntax for: {tf_file.name}")
            
            with open(tf_file, 'r') as f:
                content = f.read()
                
            # Check for basic syntax issues
            self._check_brackets(content, tf_file.name)
            self._check_quotes(content, tf_file.name)
            self._check_resource_syntax(content, tf_file.name)
    
    def _check_brackets(self, content, filename):
        """Check for balanced brackets"""
        open_braces = content.count('{')
        close_braces = content.count('}')
        
        if open_braces != close_braces:
            self.errors.append(f"✗ {filename}: Unbalanced braces - {open_braces} open, {close_braces} close")
        else:
            self.info.append(f"✓ {filename}: Brackets are balanced")
    
    def _check_quotes(self, content, filename):
        """Check for basic quote issues"""
        lines = content.split('\n')
        for i, line in enumerate(lines, 1):
            # Skip comments
            if line.strip().startswith('#'):
                continue
            
            # Count quotes (basic check)
            quote_count = line.count('"') - line.count('\\"')
            if quote_count % 2 != 0:
                self.warnings.append(f"⚠ {filename}:{i}: Possible unbalanced quotes")
    
    def _check_resource_syntax(self, content, filename):
        """Check for basic resource syntax"""
        # Check for resource blocks
        resource_pattern = r'resource\s+"[^"]+"\s+"[^"]+"\s*{'
        resources = re.findall(resource_pattern, content)
        
        if resources:
            self.info.append(f"✓ {filename}: Found {len(resources)} resource blocks")
        
        # Check for variable blocks in variables.tf
        if filename == 'variables.tf':
            variable_pattern = r'variable\s+"[^"]+"\s*{'
            variables = re.findall(variable_pattern, content)
            self.info.append(f"✓ {filename}: Found {len(variables)} variable definitions")
        
        # Check for output blocks in outputs.tf
        if filename == 'outputs.tf':
            output_pattern = r'output\s+"[^"]+"\s*{'
            outputs = re.findall(output_pattern, content)
            self.info.append(f"✓ {filename}: Found {len(outputs)} output definitions")
    
    def validate_variables(self):
        """Validate variable definitions and usage"""
        variables_file = self.module_path / 'variables.tf'
        main_file = self.module_path / 'main.tf'
        
        if not variables_file.exists() or not main_file.exists():
            return
        
        # Extract variable names from variables.tf
        with open(variables_file, 'r') as f:
            variables_content = f.read()
        
        variable_names = re.findall(r'variable\s+"([^"]+)"', variables_content)
        self.info.append(f"✓ Found {len(variable_names)} variable definitions")
        
        # Check if variables are used in main.tf
        with open(main_file, 'r') as f:
            main_content = f.read()
        
        for var_name in variable_names:
            if f'var.{var_name}' in main_content:
                self.info.append(f"✓ Variable '{var_name}' is used in main.tf")
            else:
                self.warnings.append(f"⚠ Variable '{var_name}' is defined but not used")
    
    def validate_outputs(self):
        """Validate output definitions"""
        outputs_file = self.module_path / 'outputs.tf'
        
        if not outputs_file.exists():
            return
        
        with open(outputs_file, 'r') as f:
            content = f.read()
        
        # Check for required output attributes
        output_blocks = re.findall(r'output\s+"([^"]+)"\s*{([^}]+)}', content, re.DOTALL)
        
        for output_name, output_content in output_blocks:
            if 'description' in output_content:
                self.info.append(f"✓ Output '{output_name}' has description")
            else:
                self.warnings.append(f"⚠ Output '{output_name}' missing description")
            
            if 'value' in output_content:
                self.info.append(f"✓ Output '{output_name}' has value")
            else:
                self.errors.append(f"✗ Output '{output_name}' missing value")
    
    def validate_variable_constraints(self):
        """Validate variable validation blocks and constraints"""
        variables_file = self.module_path / 'variables.tf'
        
        if not variables_file.exists():
            return
        
        with open(variables_file, 'r') as f:
            content = f.read()
        
        # Check for validation blocks
        validation_count = content.count('validation {')
        self.info.append(f"✓ Found {validation_count} variable validation blocks")
        
        # Check for default values
        default_count = content.count('default =')
        self.info.append(f"✓ Found {default_count} variables with default values")
        
        # Check for type definitions
        type_count = content.count('type =')
        self.info.append(f"✓ Found {type_count} variables with type definitions")
    
    def validate_naming_conventions(self):
        """Validate Terraform naming conventions"""
        tf_files = list(self.module_path.glob('*.tf'))
        
        for tf_file in tf_files:
            with open(tf_file, 'r') as f:
                content = f.read()
            
            # Check resource naming
            resources = re.findall(r'resource\s+"([^"]+)"\s+"([^"]+)"', content)
            for resource_type, resource_name in resources:
                if not re.match(r'^[a-z][a-z0-9_]*$', resource_name):
                    self.warnings.append(f"⚠ Resource '{resource_name}' doesn't follow snake_case convention")
                else:
                    self.info.append(f"✓ Resource '{resource_name}' follows naming convention")
    
    def run_validation(self):
        """Run all validation checks"""
        print("🔍 Starting Terraform Module Validation...")
        print("=" * 50)
        
        self.validate_file_structure()
        self.validate_terraform_syntax()
        self.validate_variables()
        self.validate_outputs()
        self.validate_variable_constraints()
        self.validate_naming_conventions()
        
        # Print results
        print("\n📋 Validation Results:")
        print("=" * 50)
        
        if self.errors:
            print("\n❌ ERRORS:")
            for error in self.errors:
                print(f"  {error}")
        
        if self.warnings:
            print("\n⚠️  WARNINGS:")
            for warning in self.warnings:
                print(f"  {warning}")
        
        if self.info:
            print("\n✅ INFO:")
            for info in self.info:
                print(f"  {info}")
        
        # Summary
        print(f"\n📊 SUMMARY:")
        print(f"  Errors: {len(self.errors)}")
        print(f"  Warnings: {len(self.warnings)}")
        print(f"  Info: {len(self.info)}")
        
        if len(self.errors) == 0:
            print("\n🎉 Module validation completed successfully!")
            return True
        else:
            print("\n💥 Module validation failed with errors!")
            return False

if __name__ == "__main__":
    module_path = sys.argv[1] if len(sys.argv) > 1 else "."
    validator = TerraformModuleValidator(module_path)
    success = validator.run_validation()
    exit(0 if success else 1)