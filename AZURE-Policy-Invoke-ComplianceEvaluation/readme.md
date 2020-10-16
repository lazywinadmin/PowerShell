```
# The code assume you are already connected to azure

# Load the function
. ./invoke-complianceevaluation.ps1

# Trigger Policy Compliance evaluation against current subscription
Invoke-ComplianceEvaluation

# Trigger Policy Compliance evaluation against specified subscription
Invoke-ComplianceEvaluation -subscriptionid <uid>

# Trigger Policy Compliance evaluation against ResourceGroup specified (in current subscription)
Invoke-ComplianceEvaluation -ResourceGroupName MyRg

# Trigger Policy Compliance evaluation against ResourceGroup specified (in specified subscription)
Invoke-ComplianceEvaluation -ResourceGroupName MyRg -subscriptionid <uid>

```
