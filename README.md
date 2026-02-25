# Azure Auto RG Delete Schedule

Automatically deletes ephemeral Azure resource groups using an Azure Automation runbook on a daily schedule. Tag any resource group with `ephemeral=true` and a `created` timestamp, and it will be removed once it is older than 24 hours.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcppxaxa%2Fazure-auto-rg-delete-schedule%2Fmain%2Fazuredeploy.json)

---

## Tag Syntax

Apply these two tags to any resource group you want automatically cleaned up:

| Tag key    | Required | Value format / example                        |
|------------|----------|-----------------------------------------------|
| `ephemeral`| ✅ Yes   | `true`                                        |
| `created`  | ✅ Yes   | `2025-06-01 14:30:00` or `2025-06-01T14:30:00` |

**Example (Azure CLI):**
```bash
az group create --name my-test-rg --location eastus --tags ephemeral=true created="2025-06-01 14:30:00"
```

The runbook checks every 24 hours and deletes any resource group where `ephemeral=true` **and** the `created` timestamp is more than 24 hours in the past.
