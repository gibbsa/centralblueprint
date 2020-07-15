# Azure Central Logging Blueprint

### Test blue print and script for setting up central logging.


Central_Workspace:

1. Blueprint.json = Primary blueprint file with parameters and resource group.
2. Artifacts folder = Beyond any RBAC or resource groups in primary blueprint file these are additional resources that created via ARM templates.
  * workspaceCreation.json - creates Log Analytics Workspace, adds Linux performance counters and syslogs, adds solutions for 'VM Insights', 'Docker Containers', 'Security Center' and 'Sentinel'.
  * activityLogging.json - Sets diagnostic settings for Acitvivty logs to send to central LA workspace.
  * policyVMdine.json - Enables deploy if not exist policies for VMs and VMSS to enable monitoring agents to LA workspace.

Parameters:
```json
"createWorkspace_Organization_Name": {
        "type": "string",
        "metadata": {
          "displayName": "Organization_Name (Create Workspace)"
        },
        "defaultValue": "Central-LAWS"
      },
"createWorkspace_data-retention": {
        "type": "int",
        "metadata": {
          "displayName": "data-retention (Create Workspace)",
          "description": "Number of days data will be retained for"
        },
        "defaultValue": 365
        },
"createWorkspace_location": {
        "type": "string",
        "metadata": {
          "displayName": "location (Create Workspace)",
          "description": "Region used when establishing the workspace"
        },
        "defaultValue": "East US"
"createWorkspace_automationAccountName": {
        "type": "string",
        "metadata": {
          "displayName": "automationAccountName (Create Workspace)",
          "description": "Automation account name"
        },
        "defaultValue": "CentralAA",
        "allowedValues": []
      },
"createWorkspace_automationAccountLocation": {
        "type": "string",
        "metadata": {
          "displayName": "automationAccountLocation (Create Workspace)",
          "description": "Specify the location in which to create the Automation account."
        },
        "defaultValue": "East US 2"
      }
```

Central_Workspace: Adds workbook for monitoring HDI clusters basic metrics and a dashboard artificat created from workbook for testing.

To deploy you can use the deployBlueprint PowerShell script. *Note: This script has not been completely tested, its design was to simplify testing quickly new blueprint changes.*