#!/usr/bin/env python3
"""
Variable Validation Test Script
Tests various input combinations for Terraform module variables

Usage:
    python3 variable_validation_tester.py [module_path]
    
If no module_path is provided, tests the current directory.
"""

import re
import sys
from pathlib import Path

class VariableValidationTester:
    def __init__(self, module_path="."):
        self.module_path = Path(module_path)
        self.test_results = []
        
    def load_variable_validations(self):
        """Extract validation rules from variables.tf"""
        variables_file = self.module_path / 'variables.tf'
        
        if not variables_file.exists():
            print("❌ variables.tf not found in the specified path")
            return {}
        
        with open(variables_file, 'r') as f:
            content = f.read()
        
        # Extract variable blocks with their validation rules
        variable_blocks = re.findall(
            r'variable\s+"([^"]+)"\s*{([^}]+(?:{[^}]*}[^}]*)*)}', 
            content, 
            re.DOTALL
        )
        
        validations = {}
        for var_name, var_content in variable_blocks:
            validations[var_name] = {
                'type': self._extract_type(var_content),
                'default': self._extract_default(var_content),
                'validation_rules': self._extract_validation_rules(var_content)
            }
        
        return validations
    
    def _extract_type(self, content):
        """Extract type from variable content"""
        type_match = re.search(r'type\s*=\s*([^\n]+)', content)
        return type_match.group(1).strip() if type_match else None
    
    def _extract_default(self, content):
        """Extract default value from variable content"""
        default_match = re.search(r'default\s*=\s*([^\n]+)', content)
        return default_match.group(1).strip() if default_match else None
    
    def _extract_validation_rules(self, content):
        """Extract validation rules from variable content"""
        validation_blocks = re.findall(
            r'validation\s*{([^}]+)}', 
            content, 
            re.DOTALL
        )
        
        rules = []
        for block in validation_blocks:
            condition_match = re.search(r'condition\s*=\s*([^\n]+)', block)
            error_match = re.search(r'error_message\s*=\s*"([^"]+)"', block)
            
            if condition_match and error_match:
                rules.append({
                    'condition': condition_match.group(1).strip(),
                    'error_message': error_match.group(1)
                })
        
        return rules
    
    def generate_test_cases(self, var_name, var_info):
        """Generate test cases based on variable type and validation rules"""
        test_cases = []
        
        # Common test cases based on variable name patterns
        if 'region' in var_name.lower():
            test_cases = [
                ('us-east-1', True, 'Valid US East region'),
                ('eu-west-1', True, 'Valid EU West region'),
                ('invalid-region', False, 'Invalid region format'),
                ('us-east', False, 'Incomplete region format'),
            ]
        
        elif 'cidr' in var_name.lower():
            test_cases = [
                ('10.0.0.0/16', True, 'Valid private CIDR'),
                ('192.168.1.0/24', True, 'Valid private CIDR'),
                ('172.16.0.0/12', True, 'Valid private CIDR'),
                ('invalid-cidr', False, 'Invalid CIDR format'),
                ('10.0.0.0/33', False, 'Invalid CIDR mask'),
            ]
        
        elif 'instance_type' in var_name.lower():
            test_cases = [
                ('t3.micro', True, 'Valid instance type'),
                ('m5.large', True, 'Valid instance type'),
                ('c5.xlarge', True, 'Valid instance type'),
                ('invalid.type', False, 'Invalid instance type'),
                ('nonexistent.huge', False, 'Non-existent instance type'),
            ]
        
        elif 'name' in var_name.lower() or 'prefix' in var_name.lower():
            test_cases = [
                ('valid-name', True, 'Valid name'),
                ('test123', True, 'Valid name with numbers'),
                ('INVALID', False, 'Uppercase not allowed'),
                ('invalid_name', False, 'Underscores not allowed'),
                ('123invalid', False, 'Cannot start with number'),
            ]
        
        elif 'environment' in var_name.lower() or 'env' in var_name.lower():
            test_cases = [
                ('dev', True, 'Valid environment'),
                ('prod', True, 'Valid environment'),
                ('staging', True, 'Valid environment'),
                ('invalid-env', False, 'Invalid environment'),
            ]
        
        elif 'ami' in var_name.lower():
            test_cases = [
                ('ami-12345678', True, 'Valid AMI ID'),
                ('ami-abcdef1234567890', True, 'Valid long AMI ID'),
                ('invalid-ami', False, 'Invalid AMI format'),
                ('ami-', False, 'Incomplete AMI ID'),
            ]
        
        elif var_info['type'] and 'list' in var_info['type']:
            test_cases = [
                (['item1', 'item2'], True, 'Valid list'),
                ([], True, 'Empty list'),
                ('not-a-list', False, 'Invalid type'),
            ]
        
        elif var_info['type'] and 'bool' in var_info['type']:
            test_cases = [
                (True, True, 'Valid boolean true'),
                (False, True, 'Valid boolean false'),
                ('true', False, 'String instead of boolean'),
            ]
        
        else:
            # Generic test cases
            test_cases = [
                ('valid-value', True, 'Generic valid value'),
                ('', False, 'Empty string'),
                (None, False, 'Null value'),
            ]
        
        return test_cases
    
    def simulate_validation(self, var_name, test_value, validation_info):
        """Simulate validation logic for a variable"""
        # This is a simplified simulation - in reality, Terraform would validate
        
        # Basic type checking
        var_type = validation_info.get('type', 'string')
        
        if 'bool' in str(var_type) and not isinstance(test_value, bool):
            return False
        
        if 'list' in str(var_type) and not isinstance(test_value, list):
            return False
        
        # Pattern-based validation simulation
        if 'region' in var_name.lower():
            return bool(re.match(r'^[a-z]{2}-[a-z]+-[0-9]$', str(test_value)))
        
        elif 'cidr' in var_name.lower():
            return self._validate_cidr(str(test_value))
        
        elif 'ami' in var_name.lower():
            return bool(re.match(r'^ami-[0-9a-f]{8,17}$', str(test_value)))
        
        elif 'name' in var_name.lower() or 'prefix' in var_name.lower():
            if not isinstance(test_value, str):
                return False
            return bool(re.match(r'^[a-z][a-z0-9-]*[a-z0-9]$', test_value))
        
        return True  # Default to valid for unknown patterns
    
    def _validate_cidr(self, cidr_str):
        """Validate CIDR format"""
        try:
            if '/' not in cidr_str:
                return False
            
            ip, mask = cidr_str.split('/')
            
            # Validate IP
            octets = ip.split('.')
            if len(octets) != 4:
                return False
            
            for octet in octets:
                if not octet.isdigit() or not 0 <= int(octet) <= 255:
                    return False
            
            # Validate mask
            if not mask.isdigit() or not 0 <= int(mask) <= 32:
                return False
            
            return True
        except:
            return False
    
    def test_variable_combinations(self):
        """Test various input combinations"""
        validations = self.load_variable_validations()
        
        if not validations:
            print("❌ No variables found to test")
            return False
        
        print("🧪 Testing Variable Validation Rules...")
        print("=" * 50)
        
        total_tests = 0
        passed_tests = 0
        
        for var_name, var_info in validations.items():
            print(f"\n🔍 Testing variable: {var_name}")
            print("-" * 30)
            
            test_cases = self.generate_test_cases(var_name, var_info)
            
            for test_value, expected_valid, description in test_cases:
                total_tests += 1
                result = self.simulate_validation(var_name, test_value, var_info)
                
                if result == expected_valid:
                    passed_tests += 1
                    status = "✅ PASS"
                else:
                    status = "❌ FAIL"
                
                print(f"  {status} | {description}")
                print(f"    Value: {test_value}")
                print(f"    Expected: {'Valid' if expected_valid else 'Invalid'}")
                print(f"    Result: {'Valid' if result else 'Invalid'}")
                print()
        
        print("=" * 50)
        print(f"📊 Test Summary: {passed_tests}/{total_tests} tests passed")
        
        if passed_tests == total_tests:
            print("🎉 All variable validation tests passed!")
        else:
            print(f"⚠️  {total_tests - passed_tests} tests failed")
        
        return passed_tests == total_tests

if __name__ == "__main__":
    module_path = sys.argv[1] if len(sys.argv) > 1 else "."
    tester = VariableValidationTester(module_path)
    success = tester.test_variable_combinations()
    exit(0 if success else 1)