param project string = 'fdproxy'
param environment string = 'dev'
param location string = resourceGroup().location
param backendBaseUrl1 string
param backendBaseUrl2 string

var tags = {
  project: project
  environment: environment
}

var seed = substring(uniqueString(resourceGroup().id), 0, 4)
var prefix = '${project}-${environment}-${seed}'
var resourceNames = {
  frontDoor: '${prefix}-fd'
  funcServicePlan: '${prefix}-asp'
  funcApp1: '${prefix}-func1'
  funcApp2: '${prefix}-func2'
  funcAppIns: '${prefix}-func-appins'
}

resource frontDoor 'Microsoft.Network/frontDoors@2020-05-01' = {
  name: resourceNames.frontDoor
  location: 'Global'
  properties: {
    backendPools: [
      {
        name: 'redirection-funcs'        
        properties: {
          loadBalancingSettings: {
            id: '${resourceId('Microsoft.Network/frontdoors', resourceNames.frontDoor)}/LoadBalancingSettings/loadBalancingSettings-${uniqueString(resourceGroup().id)}'
          }
          healthProbeSettings: {
            id: '${resourceId('Microsoft.Network/frontdoors', resourceNames.frontDoor)}/HealthProbeSettings/healthProbeSettings-${uniqueString(resourceGroup().id)}'
          }
          backends: [
            {
              address: funcApp1.outputs.hostName
              priority: 1
              httpPort: 80
              httpsPort: 443
              weight: 50
              backendHostHeader: funcApp1.outputs.hostName

            }
            {
              address: funcApp2.outputs.hostName
              priority: 1
              httpPort: 80
              httpsPort: 443
              weight: 50
              backendHostHeader: funcApp2.outputs.hostName
            }
          ]
        }
      }
    ]
    healthProbeSettings: [
      {
        name: 'healthProbeSettings-${uniqueString(resourceGroup().id)}'
        properties: {
          healthProbeMethod: 'HEAD'
          intervalInSeconds: 30
          path: '/'
          protocol: 'Https'
        }
      }
    ]
    loadBalancingSettings: [
      {
        name: 'loadBalancingSettings-${uniqueString(resourceGroup().id)}'
        properties: {
          sampleSize: 4
          additionalLatencyMilliseconds: 0
          successfulSamplesRequired: 2
        }
      }
    ]
    frontendEndpoints: [
      {
        name: '${resourceNames.frontDoor}-azurefd-net'
        properties: {
          hostName: '${resourceNames.frontDoor}.azurefd.net'
          sessionAffinityEnabledState: 'Disabled'
        }
      }
    ]
    routingRules:[
      {
        name: 'default-routing-rule'
        properties: {
          frontendEndpoints:[
            {
              id: '${resourceId('Microsoft.Network/frontdoors', resourceNames.frontDoor)}/FrontendEndpoints/${resourceNames.frontDoor}-azurefd-net'
            }
          ]
          patternsToMatch: [
            '/*'
          ]
          acceptedProtocols:[
            'Http'
            'Https'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol:'HttpsOnly'
            backendPool: {
              id: '${resourceId('Microsoft.Network/frontdoors', resourceNames.frontDoor)}/BackendPools/redirection-funcs'
            }
          }
        }
      }
    ]
  }
}

resource funcServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: resourceNames.funcServicePlan
  location: location
  tags: tags
  sku: {
    name: 'Y1'
    tier: 'Consumption'
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

module funcApp1 'modules/functionApp.module.bicep' = {
  name: 'funcApp1'
  params: {
    name: resourceNames.funcApp1
    appServicePlanId: funcServicePlan.id
    applicationInsightsKey: funcAppIns.outputs.instrumentationKey
    appSettings:[
      {
        name: 'BackendBaseUrl'
        value: backendBaseUrl1
      }
    ]
    tags: tags
  }
}

module funcApp2 'modules/functionApp.module.bicep' = {
  name: 'funcApp2'
  params: {
    name: resourceNames.funcApp2
    appServicePlanId: funcServicePlan.id
    applicationInsightsKey: funcAppIns.outputs.instrumentationKey
    appSettings:[
      {
        name: 'BackendBaseUrl'
        value: backendBaseUrl2
      }
    ]
    tags: tags
  }
}
