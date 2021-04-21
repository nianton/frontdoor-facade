param project string = 'fdproxy'
param environment string = 'dev'
param location string = resourceGroup().location

var tags = {
  project: 'fdproxy'
  environment: 'demo'
}

var prefix = '${project}-${environment}'
var resourceNames = {
  frontDoor: '${prefix}-fd'
  funcServicePlan: '${prefix}-asp'
  funcApp: '${prefix}-func'
  funcAppIns: '${prefix}-func-appins'
  funcStorage: 's${prefix}func'
}
var funcWorkerRuntime = 'dotnet'
var funcExtensionVersion = '~3'

resource frontDoor 'Microsoft.Network/frontDoors@2020-05-01' = {
  name: resourceNames.frontDoor
}

resource funcServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: resourceNames.funcServicePlan
  location: location
  tags: tags
  sku: {
    name: 'Y1'
    tier:'Consumption'
  }
}

module funcStorage './modules/storage.module.bicep' = {
  name: resourceNames.funcStorage
  params: {
    name: resourceNames.funcStorage
    location: location
    tags: tags
  }
}

module funcAppIns './modules/appInsights.module.bicep' = {
  name: resourceNames.funcAppIns
  params: {
    name: resourceNames.funcAppIns
    location: location
    tags: tags
    project: project
  }
}

resource funcApp 'Microsoft.Web/sites@2020-06-01' = {
  name: resourceNames.funcApp
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: funcServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: funcExtensionVersion
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '10.14.1'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: funcWorkerRuntime
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
          value: toLower(resourceNames.funcApp)
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: funcAppIns.outputs.instrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${funcAppIns.outputs.instrumentationKey}'
        }
      ]
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
