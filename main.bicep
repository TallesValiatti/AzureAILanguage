// az group create --name rg-app-eastus --location eastus 
// az deployment group create --name ai-language --resource-group rg-app-eastus --template-file main.bicep
// az group delete --name rg-app-eastus

@description('Default location')
param defaultLocation string = resourceGroup().location

@description('AI language service name')
param aiLanguageName string = 'ai-language-app-${defaultLocation}'

@description('storage account Name')
param staName string = 'staapp${defaultLocation}'


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: staName
  location: defaultLocation
  sku: {
    name: 'Standard_ZRS'
  }
  kind: 'Storage'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource aiLanguage 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: aiLanguageName
  location: defaultLocation
  sku: {
    name: 'F0'
  }
  kind: 'TextAnalytics'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    restore: true
    apiProperties: {}
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    userOwnedStorage: [
      {
        resourceId: storageAccount.id
      }
    ]
    publicNetworkAccess: 'Enabled'
  }
}

resource storageAccountBlob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            'https://language.cognitive.azure.com'
          ]
          allowedMethods: [
            'DELETE'
            'GET'
            'POST'
            'OPTIONS'
            'PUT'
          ]
          maxAgeInSeconds: 500
          exposedHeaders: [
            '*'
          ]
          allowedHeaders: [
            '*'
          ]
        }
      ]
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}
