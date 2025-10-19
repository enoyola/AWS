#!/usr/bin/env python3
"""
Output Verification Script
Verifies that all outputs are properly defined and reference valid resources

Usage:
    python3 output_verifier.py [module_path]
    
If no module_path is provided, verifies the current directory.
"""

import re
import sys
from pathlib import Path

class OutputVerifier:
    def __init__(self, module_path="."):
        self.module_path = Path(module_path)
        self.errors = []
        self.warnings = []
        self.info = []
        
    def load_resources(self):
        """Load all resources from main.tf"""
        main_file = self.module_path / 'main.tf'
        
        if not main_file.exists():
            print("❌ main.tf not found in the specified path")
            return [], []
        
        with open(main_file, 'r') as f:
            content = f.read()
        
        # Extract resource definitions
        resource_pattern = r'resource\s+"([^"]+)"\s+"([^"]+)"\s*{'
        resources = re.findall(resource_pattern, content)
        
        # Extract data sources
        data_pattern = r'data\s+"([^"]+)"\s+"([^"]+)"\s*{'
        data_sources = re.findall(data_pattern, content)
        
        return resources, data_sources
    
    def load_outputs(self):
        """Load all outputs from outputs.tf"""
        outputs_file = self.module_path / 'outputs.tf'
        
        if not outputs_file.exists():
            print("❌ outputs.tf not found in the specified path")
            return {}
        
        with open(outputs_file, 'r') as f:
            content = f.read()
        
        # Extract output blocks with their content
        output_pattern = r'output\s+"([^"]+)"\s*{([^}]+(?:{[^}]*}[^}]*)*)}' 
        outputs = re.findall(output_pattern, content, re.DOTALL)
        
        output_details = {}
        for output_name, output_content in outputs:
            output_details[output_name] = {
                'description': self._extract_description(output_content),
                'value': self._extract_value(output_content),
                'sensitive': self._extract_sensitive(output_content)
            }
        
        return output_details
    
    def _extract_description(self, content):
        """Extract description from output content"""
        desc_match = re.search(r'description\s*=\s*"([^"]+)"', content)
        return desc_match.group(1) if desc_match else None
    
    def _extract_value(self, content):
        """Extract value from output content"""
        value_match = re.search(r'value\s*=\s*([^\n]+)', content)
        return value_match.group(1).strip() if value_match else None
    
    def _extract_sensitive(self, content):
        """Extract sensitive flag from output content"""
        sensitive_match = re.search(r'sensitive\s*=\s*(true|false)', content)
        return sensitive_match.group(1) == 'true' if sensitive_match else False
    
    def verify_output_references(self):
        """Verify that output values reference valid resources"""
        resources, data_sources = self.load_resources()
        outputs = self.load_outputs()
        
        if not outputs:
            return
        
        # Create a map of available resource references
        available_refs = set()
        
        # Add resource references
        for resource_type, resource_name in resources:
            available_refs.add(f"{resource_type}.{resource_name}")
        
        # Add data source references
        for data_type, data_name in data_sources:
            available_refs.add(f"data.{data_type}.{data_name}")
        
        print("🔍 Verifying Output References...")
        print("=" * 50)
        
        for output_name, output_info in outputs.items():
            print(f"\n📤 Output: {output_name}")
            
            # Check if description exists
            if output_info['description']:
                self.info.append(f"✓ Output '{output_name}' has description")
                print(f"  Description: {output_info['description']}")
            else:
                self.warnings.append(f"⚠ Output '{output_name}' missing description")
                print("  ⚠️  Missing description")
            
            # Check if value exists
            if output_info['value']:
                self.info.append(f"✓ Output '{output_name}' has value")
                print(f"  Value: {output_info['value']}")
                
                # Verify resource references in the value
                self._verify_value_references(output_name, output_info['value'], available_refs)
            else:
                self.errors.append(f"✗ Output '{output_name}' missing value")
                print("  ❌ Missing value")
            
            # Check sensitive flag
            if output_info['sensitive']:
                print("  🔒 Marked as sensitive")
        
        print(f"\n📊 Available Resources ({len(available_refs)}):")
        for ref in sorted(available_refs):
            print(f"  • {ref}")
    
    def _verify_value_references(self, output_name, value, available_refs):
        """Verify that the value references valid resources"""
        # Extract resource references from the value
        ref_patterns = [
            r'aws_[a-z_]+\.[a-z_]+',  # AWS resource references
            r'azurerm_[a-z_]+\.[a-z_]+',  # Azure resource references
            r'google_[a-z_]+\.[a-z_]+',  # GCP resource references
            r'data\.[a-z_]+\.[a-z_]+',  # Data source references
            r'local\.[a-z_]+',  # Local values
            r'var\.[a-z_]+',  # Variables
        ]
        
        found_refs = set()
        for pattern in ref_patterns:
            matches = re.findall(pattern, value)
            found_refs.update(matches)
        
        # Check if references are valid (skip var. and local. references)
        for ref in found_refs:
            if ref.startswith(('var.', 'local.')):
                print(f"    ℹ️  Reference: {ref} (variable/local)")
                continue
                
            if ref in available_refs:
                self.info.append(f"✓ Output '{output_name}' references valid resource: {ref}")
                print(f"    ✅ Valid reference: {ref}")
            else:
                self.errors.append(f"✗ Output '{output_name}' references invalid resource: {ref}")
                print(f"    ❌ Invalid reference: {ref}")
    
    def verify_common_outputs(self):
        """Verify that common/expected outputs are present"""
        outputs = self.load_outputs()
        
        if not outputs:
            return
        
        # Define common outputs that are often expected
        common_outputs = {
            'id': 'Resource identifier',
            'arn': 'Amazon Resource Name',
            'name': 'Resource name',
            'vpc_id': 'VPC identifier',
            'subnet_id': 'Subnet identifier',
            'security_group_id': 'Security group identifier',
            'instance_id': 'Instance identifier',
            'private_ip': 'Private IP address',
            'public_ip': 'Public IP address'
        }
        
        print(f"\n🎯 Checking for Common Outputs...")
        print("=" * 50)
        
        found_common = []
        for output_name in outputs.keys():
            for common_name, description in common_outputs.items():
                if common_name in output_name.lower():
                    found_common.append((output_name, description))
                    break
        
        if found_common:
            print("✅ Found common outputs:")
            for output_name, description in found_common:
                print(f"  • {output_name}: {description}")
        else:
            print("ℹ️  No common outputs detected (this may be normal depending on the module)")
    
    def verify_output_organization(self):
        """Verify outputs are well organized"""
        outputs = self.load_outputs()
        
        if not outputs:
            return
        
        print(f"\n📂 Output Organization Analysis...")
        print("=" * 50)
        
        # Group outputs by common prefixes
        prefixes = {}
        for output_name in outputs.keys():
            parts = output_name.split('_')
            if len(parts) > 1:
                prefix = parts[0]
                if prefix not in prefixes:
                    prefixes[prefix] = []
                prefixes[prefix].append(output_name)
        
        if prefixes:
            print("📁 Outputs grouped by prefix:")
            for prefix, output_list in prefixes.items():
                print(f"  {prefix}:")
                for output in output_list:
                    print(f"    • {output}")
        
        print(f"\n📊 Total outputs: {len(outputs)}")
        print(f"📊 Organized prefixes: {len(prefixes)}")
    
    def run_verification(self):
        """Run all verification checks"""
        print("🔍 Starting Output Verification...")
        print("=" * 50)
        
        self.verify_output_references()
        self.verify_common_outputs()
        self.verify_output_organization()
        
        # Print results summary
        print("\n📋 Verification Results:")
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
            print(f"\n✅ SUCCESSFUL CHECKS: {len(self.info)}")
        
        # Summary
        print(f"\n📊 SUMMARY:")
        print(f"  Errors: {len(self.errors)}")
        print(f"  Warnings: {len(self.warnings)}")
        print(f"  Successful checks: {len(self.info)}")
        
        if len(self.errors) == 0:
            print("\n🎉 Output verification completed successfully!")
            return True
        else:
            print("\n💥 Output verification failed with errors!")
            return False

if __name__ == "__main__":
    module_path = sys.argv[1] if len(sys.argv) > 1 else "."
    verifier = OutputVerifier(module_path)
    success = verifier.run_verification()
    exit(0 if success else 1)