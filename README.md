# Front Door Facade
Create a facade with Azure Front Door and Azure Functions proxies for two instances of the same REST APIs published under different base paths
<!-- 
[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnianton%2Ffrontdoor-facade%2Fmain%2Fazuredeploy.json) -->


This template deploys an **Azure Front Door** exposing a same API facade for the two instances of an API served in different path. The sample API is implemented by an Azure Function deployed in Azure for the demo's purposes.


![alt text](https://raw.githubusercontent.com/nianton/frontdoor-facade/main/.assets/Front-Door-Proxy.png "Front Door Proxy via Azure Functions")


If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
