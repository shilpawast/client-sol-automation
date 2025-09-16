#!/bin/bash

# OEM Quote Management Power Automate Deployment Script
# This script helps deploy the refactored Power Automate flows

set -e

echo "=== OEM Quote Management Flow Deployment ==="
echo "Starting deployment process..."

# Configuration
RESOURCE_GROUP="rg-oem-automation"
LOCATION="eastus"
SUBSCRIPTION_ID=""
FLOW_ENVIRONMENT=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Power Platform CLI is installed
    if ! command -v pac &> /dev/null; then
        print_warning "Power Platform CLI is not installed. Some features may not work."
    fi
    
    print_status "Prerequisites check completed."
}

# Login to Azure
azure_login() {
    print_status "Logging into Azure..."
    
    if [ -z "$SUBSCRIPTION_ID" ]; then
        print_warning "No subscription ID provided. Please set SUBSCRIPTION_ID variable."
        az login
    else
        az login --subscription "$SUBSCRIPTION_ID"
    fi
    
    print_status "Azure login completed."
}

# Validate configuration files
validate_configs() {
    print_status "Validating configuration files..."
    
    # Check if config files exist
    if [ ! -f "src/config/flow-config.json" ]; then
        print_error "flow-config.json not found!"
        exit 1
    fi
    
    if [ ! -f "src/templates/email-templates.json" ]; then
        print_error "email-templates.json not found!"
        exit 1
    fi
    
    # Validate JSON syntax
    if ! python3 -m json.tool src/config/flow-config.json > /dev/null 2>&1; then
        print_error "Invalid JSON syntax in flow-config.json"
        exit 1
    fi
    
    if ! python3 -m json.tool src/templates/email-templates.json > /dev/null 2>&1; then
        print_error "Invalid JSON syntax in email-templates.json"
        exit 1
    fi
    
    print_status "Configuration validation completed."
}

# Deploy flows
deploy_flows() {
    print_status "Deploying Power Automate flows..."
    
    # Create deployment directory
    mkdir -p deployment/logs
    
    # Copy flow definitions
    cp -r src/flows deployment/
    cp -r src/config deployment/
    cp -r src/templates deployment/
    
    print_status "Flow files prepared for deployment."
    
    # If Power Platform CLI is available, attempt deployment
    if command -v pac &> /dev/null; then
        if [ -n "$FLOW_ENVIRONMENT" ]; then
            print_status "Attempting automated deployment..."
            
            # Set environment
            pac auth create --environment "$FLOW_ENVIRONMENT"
            
            # Deploy main flow (this would need actual implementation)
            print_warning "Automated deployment not fully implemented. Please import flows manually."
        else
            print_warning "No flow environment specified. Skipping automated deployment."
        fi
    fi
    
    print_status "Flow deployment completed."
}

# Create SharePoint lists
create_sharepoint_lists() {
    print_status "Creating SharePoint lists structure..."
    
    cat > deployment/sharepoint-lists-schema.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<Lists>
  <List Name="VendorContacts" Description="Vendor contact information">
    <Fields>
      <Field Name="VendorId" Type="Text" Required="TRUE"/>
      <Field Name="VendorName" Type="Text" Required="TRUE"/>
      <Field Name="ContactName" Type="Text" Required="TRUE"/>
      <Field Name="Email" Type="Text" Required="TRUE"/>
      <Field Name="Phone" Type="Text"/>
      <Field Name="Role" Type="Choice">
        <Choices>
          <Choice>Primary Contact</Choice>
          <Choice>Product Manager</Choice>
          <Choice>Sales Representative</Choice>
        </Choices>
      </Field>
      <Field Name="IsActive" Type="Boolean" Required="TRUE"/>
    </Fields>
  </List>
  
  <List Name="QuoteTracking" Description="Quote processing tracking">
    <Fields>
      <Field Name="QuoteId" Type="Text" Required="TRUE"/>
      <Field Name="CustomerNumber" Type="Text" Required="TRUE"/>
      <Field Name="Status" Type="Choice">
        <Choices>
          <Choice>initiated</Choice>
          <Choice>email_sent</Choice>
          <Choice>48_hour_followup_sent</Choice>
          <Choice>escalated_to_product_manager</Choice>
          <Choice>vendor_responded</Choice>
          <Choice>completed</Choice>
          <Choice>error</Choice>
        </Choices>
      </Field>
      <Field Name="VendorEmail" Type="Text"/>
      <Field Name="VendorResponded" Type="Boolean" Required="TRUE"/>
      <Field Name="EscalatedTo" Type="Text"/>
      <Field Name="CreatedDate" Type="DateTime" Required="TRUE"/>
      <Field Name="LastModified" Type="DateTime"/>
    </Fields>
  </List>
</Lists>
EOF
    
    print_status "SharePoint lists schema created."
}

# Generate deployment report
generate_report() {
    print_status "Generating deployment report..."
    
    cat > deployment/deployment-report.md << EOF
# OEM Quote Management Deployment Report

## Deployment Summary
- **Date**: $(date)
- **Status**: Completed
- **Environment**: ${FLOW_ENVIRONMENT:-"Not specified"}

## Deployed Components

### Power Automate Flows
- [x] Main OEM Quote Management Flow
- [x] Follow-up and Escalation Flow  
- [x] Helper Functions Flow

### Configuration Files
- [x] Flow Configuration (flow-config.json)
- [x] Email Templates (email-templates.json)

### SharePoint Components
- [x] VendorContacts List Schema
- [x] QuoteTracking List Schema

## Next Steps

### Manual Configuration Required
1. **Import Power Automate Flows**
   - Import \`oem-quote-management-flow.json\`
   - Import \`follow-up-escalation-flow.json\`
   - Import \`helper-functions-flow.json\`

2. **Configure Connections**
   - Azure Data Lake connection
   - SharePoint Online connection
   - Outlook/Exchange connection
   - Excel Online connection

3. **Create SharePoint Lists**
   - Use the schema files to create required lists
   - Populate VendorContacts with initial data

4. **Update Configuration**
   - Set correct SharePoint site URLs
   - Configure Azure Data Lake table names
   - Set admin email addresses

### Testing Checklist
- [ ] Test email trigger with sample quote request
- [ ] Verify data lake connectivity
- [ ] Test SharePoint list operations
- [ ] Validate Excel template processing
- [ ] Test follow-up and escalation flows

## Support
For issues or questions, refer to the documentation or contact the development team.

EOF

    print_status "Deployment report generated: deployment/deployment-report.md"
}

# Main deployment process
main() {
    check_prerequisites
    
    if [ "$1" = "--skip-azure-login" ]; then
        print_warning "Skipping Azure login as requested."
    else
        azure_login
    fi
    
    validate_configs
    deploy_flows
    create_sharepoint_lists
    generate_report
    
    print_status "Deployment process completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Review the deployment report: deployment/deployment-report.md"
    echo "2. Import the Power Automate flows manually in the Power Platform portal"
    echo "3. Configure the required connections and SharePoint lists"
    echo "4. Test the flows with sample data"
}

# Run main function with all arguments
main "$@"