param name string
param appServicePlanId string
param location string = resourceGroup().location
param workerRuntime string = 'dotnet'
param extensionVersion string = '~3'
param tags object = {}
param applicationInsightsKey string
param appSettings array = []

var funcStorageName = '${name}st'

module funcStorage './storage.module.bicep' = {
  name: funcStorageName
  params: {
    name: funcStorageName
    location: location
    tags: tags
  }
}

resource funcApp 'Microsoft.Web/sites@2020-06-01' = {
  name: name
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlanId
    siteConfig: {
      appSettings: union([
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: extensionVersion
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '10.14.1'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: workerRuntime
        }
        {
          name: 'AzureWebJobsDashboard'
          value: funcStorage.outputs.connectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: funcStorage.outputs.connectionString
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: funcStorage.outputs.connectionString
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(name)
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${applicationInsightsKey}'
        }
      ], appSettings)
    }
    httpsOnly: true
    clientAffinityEnabled: false
  }
  tags: tags
}


resource funcAppSourceControl 'Microsoft.Web/sites/sourcecontrols@2020-06-01' = {
  name: '${funcApp.name}/web'
  properties: {
    branch: 'main'
    repoUrl: 'https://github.com/nianton/frontdoor-facade'
    isManualIntegration: true
  }
}

output hostName string = funcApp.properties.defaultHostName
