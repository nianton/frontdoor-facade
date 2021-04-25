# Front Door Facade
Create a facade with Azure Front Door and Azure Functions proxies for two instances of the same REST APIs published under different base paths
<!-- 
[![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnianton%2Ffrontdoor-facade%2Fmain%2Fazuredeploy.json) -->

E.g. an API with the same definition is exposed as such:
* server1.com/path1
* server2.com/path2

so, a load balancing solution usually cannot be used to tackle this setup, to redirect requests between the two for high availability.

This solution uses **Azure Front Door** as the load balancing solution, exposing a same API facade for the two instances of an API which are served behind two **Azure Function proxies** which serve the purpose of consolidating the path between the two instances (the common path is defined in the **proxies.json** file, **/proxied/{\*all}** in the sample implementation). The sample API is implemented by an Azure Function deployed in Azure for the demo's purposes. 


![alt text](https://raw.githubusercontent.com/nianton/frontdoor-facade/main/.assets/Front-Door-Proxy.png "Front Door Proxy via Azure Functions")


For the deployment of this solutions, you will be requested with at least the two backendUrls for the APIs, you may use http://requestbin.net or a equivalent service to inspect the requests for demo purposes.

If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
