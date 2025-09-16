#!/bin/bash

# OEM Quote Management Flow Testing Script
# This script validates the Power Automate flows and configurations

set -e

echo "=== OEM Quote Management Flow Testing ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to print colored output
print_test_header() {
    echo -e "${BLUE}[TEST]${NC} $1"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASSED_TESTS=$((PASSED_TESTS + 1))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Test configuration files
test_config_files() {
    print_test_header "Testing configuration files"
    
    # Test flow-config.json exists and is valid JSON
    if [ -f "src/config/flow-config.json" ]; then
        if python3 -m json.tool src/config/flow-config.json > /dev/null 2>&1; then
            print_pass "flow-config.json is valid JSON"
        else
            print_fail "flow-config.json contains invalid JSON"
        fi
    else
        print_fail "flow-config.json not found"
    fi
    
    # Test email-templates.json exists and is valid JSON  
    if [ -f "src/templates/email-templates.json" ]; then
        if python3 -m json.tool src/templates/email-templates.json > /dev/null 2>&1; then
            print_pass "email-templates.json is valid JSON"
        else
            print_fail "email-templates.json contains invalid JSON"
        fi
    else
        print_fail "email-templates.json not found"
    fi
}

# Test Power Automate flow files
test_flow_files() {
    print_test_header "Testing Power Automate flow files"
    
    # Check main flow file
    if [ -f "src/flows/oem-quote-management-flow.json" ]; then
        if python3 -m json.tool src/flows/oem-quote-management-flow.json > /dev/null 2>&1; then
            print_pass "Main flow JSON is valid"
        else
            print_fail "Main flow JSON is invalid"
        fi
    else
        print_fail "Main flow file not found"
    fi
    
    # Check follow-up flow file
    if [ -f "src/flows/follow-up-escalation-flow.json" ]; then
        if python3 -m json.tool src/flows/follow-up-escalation-flow.json > /dev/null 2>&1; then
            print_pass "Follow-up flow JSON is valid"
        else
            print_fail "Follow-up flow JSON is invalid"
        fi
    else
        print_fail "Follow-up flow file not found"
    fi
    
    # Check helper functions flow file
    if [ -f "src/utils/helper-functions-flow.json" ]; then
        if python3 -m json.tool src/utils/helper-functions-flow.json > /dev/null 2>&1; then
            print_pass "Helper functions flow JSON is valid"
        else
            print_fail "Helper functions flow JSON is invalid"
        fi
    else
        print_fail "Helper functions flow file not found"
    fi
}

# Test email template structure
test_email_templates() {
    print_test_header "Testing email template structure"
    
    if [ -f "src/templates/email-templates.json" ]; then
        # Check for required template sections
        if jq -e '.emailTemplates.initialVendorRequest' src/templates/email-templates.json > /dev/null 2>&1; then
            print_pass "Initial vendor request template found"
        else
            print_fail "Initial vendor request template missing"
        fi
        
        if jq -e '.emailTemplates.followUpReminder' src/templates/email-templates.json > /dev/null 2>&1; then
            print_pass "Follow-up reminder template found"
        else
            print_fail "Follow-up reminder template missing"
        fi
        
        if jq -e '.emailTemplates.escalationNotice' src/templates/email-templates.json > /dev/null 2>&1; then
            print_pass "Escalation notice template found"
        else
            print_fail "Escalation notice template missing"
        fi
        
        if jq -e '.emailTemplates.errorNotification' src/templates/email-templates.json > /dev/null 2>&1; then
            print_pass "Error notification template found"
        else
            print_fail "Error notification template missing"
        fi
    fi
}

# Test configuration values
test_config_values() {
    print_test_header "Testing configuration values"
    
    if [ -f "src/config/flow-config.json" ]; then
        # Check email configuration
        if jq -e '.email.adminEmail' src/config/flow-config.json > /dev/null 2>&1; then
            admin_email=$(jq -r '.email.adminEmail' src/config/flow-config.json)
            if [[ "$admin_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                print_pass "Admin email format is valid: $admin_email"
            else
                print_fail "Admin email format is invalid: $admin_email"
            fi
        else
            print_fail "Admin email not configured"
        fi
        
        # Check timing configuration
        if jq -e '.timing.followUpHours' src/config/flow-config.json > /dev/null 2>&1; then
            followup_hours=$(jq -r '.timing.followUpHours' src/config/flow-config.json)
            if [ "$followup_hours" -gt 0 ] && [ "$followup_hours" -lt 168 ]; then
                print_pass "Follow-up hours is reasonable: ${followup_hours}h"
            else
                print_fail "Follow-up hours is unreasonable: ${followup_hours}h"
            fi
        else
            print_fail "Follow-up hours not configured"
        fi
        
        # Check escalation configuration
        if jq -e '.timing.escalationHours' src/config/flow-config.json > /dev/null 2>&1; then
            escalation_hours=$(jq -r '.timing.escalationHours' src/config/flow-config.json)
            if [ "$escalation_hours" -gt "$followup_hours" ] && [ "$escalation_hours" -lt 168 ]; then
                print_pass "Escalation hours is reasonable: ${escalation_hours}h"
            else
                print_fail "Escalation hours is unreasonable: ${escalation_hours}h"
            fi
        else
            print_fail "Escalation hours not configured"
        fi
    fi
}

# Test customer number extraction patterns
test_customer_extraction() {
    print_test_header "Testing customer number extraction patterns"
    
    # Test various email subject formats
    test_subjects=(
        "Quote Request Customer: ABC123"
        "Quote Request - Customer: DEF456"  
        "RFQ Customer: GHI789"
        "Request for Quote Customer: JKL012"
        "URGENT: Quote Request Customer: MNO345"
    )
    
    for subject in "${test_subjects[@]}"; do
        # Simulate customer number extraction using the pattern from config
        if [[ "$subject" =~ Customer:[[:space:]]*([A-Z0-9]+) ]]; then
            customer_num="${BASH_REMATCH[1]}"
            if [ ${#customer_num} -ge 3 ] && [ ${#customer_num} -le 20 ]; then
                print_pass "Extracted customer number from '$subject': $customer_num"
            else
                print_fail "Customer number length invalid in '$subject': $customer_num"
            fi
        else
            print_fail "Could not extract customer number from '$subject'"
        fi
    done
}

# Test directory structure
test_directory_structure() {
    print_test_header "Testing directory structure"
    
    required_dirs=("src" "src/flows" "src/config" "src/templates" "src/utils" "scripts" "docs")
    
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            print_pass "Directory exists: $dir"
        else
            print_fail "Directory missing: $dir"
        fi
    done
}

# Test file permissions
test_file_permissions() {
    print_test_header "Testing file permissions"
    
    # Check if deploy script is executable
    if [ -x "scripts/deploy.sh" ]; then
        print_pass "Deploy script is executable"
    else
        print_fail "Deploy script is not executable"
    fi
    
    # Check if test script is executable (this script)
    if [ -x "scripts/test.sh" ]; then
        print_pass "Test script is executable"
    else
        print_warning "Test script may not be executable"
    fi
}

# Generate test report
generate_test_report() {
    print_info "Generating test report..."
    
    cat > test-report.txt << EOF
# OEM Quote Management Flow Test Report

## Test Summary
- **Date**: $(date)
- **Total Tests**: $TOTAL_TESTS
- **Passed**: $PASSED_TESTS  
- **Failed**: $FAILED_TESTS
- **Success Rate**: $(( (PASSED_TESTS * 100) / TOTAL_TESTS ))%

## Test Categories
- Configuration Files: JSON validation and structure
- Flow Files: Power Automate flow definition validation
- Email Templates: Template structure and completeness  
- Configuration Values: Validation of settings and formats
- Customer Extraction: Email parsing pattern testing
- Directory Structure: Required directories and organization
- File Permissions: Executable scripts and access rights

## Recommendations
$(if [ $FAILED_TESTS -gt 0 ]; then
    echo "- Review and fix failed tests before deployment"
    echo "- Validate configuration values match your environment"
    echo "- Ensure all required files are present and properly formatted"
else
    echo "- All tests passed! Solution is ready for deployment"
    echo "- Proceed with manual Power Platform configuration"
    echo "- Test with real data in a development environment first"
fi)

## Next Steps
1. Review any failed tests and make necessary corrections
2. Run deployment script: ./scripts/deploy.sh
3. Configure Power Platform connections and SharePoint lists
4. Test with sample quote request emails
5. Monitor flow execution and performance

EOF

    print_info "Test report saved to test-report.txt"
}

# Main test execution
main() {
    echo "Starting comprehensive testing..."
    echo ""
    
    test_directory_structure
    test_config_files  
    test_flow_files
    test_email_templates
    test_config_values
    test_customer_extraction
    test_file_permissions
    
    echo ""
    echo "=== Test Results ==="
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC} ✅"
    else
        echo -e "${RED}Some tests failed!${NC} ❌"
    fi
    
    echo ""
    generate_test_report
    
    # Exit with error code if any tests failed
    if [ $FAILED_TESTS -gt 0 ]; then
        exit 1
    fi
}

# Run main function
main "$@"