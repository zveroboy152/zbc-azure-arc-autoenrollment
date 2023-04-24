Windows Server Onboarding Script
This PowerShell script is used to onboard Windows servers to Azure using Azure Arc. The script does the following:

Defines a script block to run on each active server
Gets a list of all active Windows servers in the domain
Loops through each server and performs a reachability check by pinging
If the server is reachable, the script block is executed on the server to onboard it to Azure using Azure Arc
Prerequisites
Azure subscription
Azure Resource Manager service endpoint
Azure AD service principal
Usage
Update the script block variables with your own Azure AD service principal credentials and subscription information.
Save the script as a .ps1 file.
Open PowerShell with elevated privileges and run the script.
Note: This script requires that the Azure Connected Machine Agent (Azcmagent) is installed on the server(s). If it is not installed, the script will attempt to download and install it.

Contributions
Contributions are welcome! If you notice any issues or have suggestions for improvements, please submit a pull request.
