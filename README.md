# certbot-azure
Docker image inheriting the certbot/certbot image having the azure-cli installed so that azure commands can be used in the hooks to perform DNS or HTTP validations. It comes with a few example scripts in the repo.

I know that certbot has a plugin framework and someone might have written an Azure plugin, but for my purpose the scripts and a scheduled execution of the docker is far enough. 

## Usage

Assuming that your scripts to perform azure-cli actions are located in /var/certbot-azure/scripts

```
docker run -it --rm --name certbot \
    -v "/var/certbot-azure/letsencrypt:/etc/letsencrypt" \
    -v "/var/certbot-azure/scripts:/var/scripts" \
    certbot-azure certonly --manual \
    --manual-auth-hook "/var/scripts/set-dns-record.sh" \
    --manual-cleanup-hook "/var/scripts/delete-dns-record.sh" \
    --deploy-hook "/var/scripts/update-ssl-cert.sh" \
    --disable-hook-validation \
    --preferred-challenges "dns-01" \
    --agree-tos \
    -d "example.com" \
    -d "*.example.com" \
    -m "mail@example.com" \
    --no-eff-email \
    --manual-public-ip-logging-ok \
    --renew-by-default
```

## Example scripts

### az-login.sh

To do the command line login you need to create a service principal and grant it contributor access to your DNS Zone and to your Application Gateway where you want to deploy the certificate.

The following Variables must be filled with your according values:

| Variable | Explanation |
| -- | -- |
|`AZ_SERVICE_PRINCIPAL_NAME`| The name in the GUID format of the application/Service Principal |  
|`AZ_SERVICE_PRINCIPAL_KEY`| One of the Access keys you have generated for the Service Principal | 
|`AZ_TENANT`| Your tenant id |

### delete-dns-record.sh AND set-dns-record.sh

The following Variables must be filled with your according values:

| Variable | Explanation |
| -- | -- |
| `AZURE_DNSZONE_RESOURCEGROUP` | Resource Group Name of your Azure DNS Zone resource |
| `AZURE_DNSZONE_RESOURCENAME` | Name of your Azure DNS Zone resource |

### update-ssl-cert.sh

The following Variables must be filled with your according values:

| Variable | Explanation |
| -- | -- |
| `CERT_PASSWD` | The password for the newly created pks file. Any value will work |
| `AZURE_CERT_NAME` | Name of certificate in Azure Application Gateway |
| `AZURE_APP_GW_RESOURCE_NAME` | Name of the Application Gateway Resource |
| `AZURE_APP_GW_RESOURCE_GROUP_NAME` | Name of the Application Gateway Resource Group |

Please understand that this is a pure UPDATE script it will not be able to initially DEPLOY the ssl certificate. For this a different deploy-hook script would be necessary.

The script will keep running until the _long running operation_ is committed by azure. Sometimes this takes very long. Even if the actual task to update the pfx file is already completed, azure refuses to commit. consider using the `--no-wait` in the `az network application-gateway ssl-cert update`command.

## Run it inside Azure Container instances

The container can of course be used inside Azure Container instances.

Therefore see the example azure deployment template `azure-resources/certbot-deployment.json`

- Create a new Resouce Group, or use the one where your Application Gateway resides (which you want to update). In the example the Resource Group is named "AppGateway".

- Create a storage account or use an exisiting one
- Create a new file share with the name `certbot-azure`
- Get the values for `storageAccountName` and `storageAccountKey` from the Portal website (_Account Keys_ section in the storage account configuration page) and update the `certbot-deployment.json` file accordingly.

Deploy with

```
az group deployment create --resource-group AppGateway --template-file certbot.json
```

As the deployment template has the restart policy 'Never' it will run only once and needs to be rerun any time you want to renew the certificate. This can be done either manually or using a scheduler. 

# Bi Monthly Trigger to renew SSL certificates by starting the certbot ACI Container Group

The azure Function `ScheduleCertRenewal` (`azure-resources/schedule-function-app`) uses the REST encapsulation (azure-arm-containerinstance) to start the defined ContainerGroup once every two months.

To edit and deploy use Visual Studio Code with the _Azure Functions_ extension installed. You will need to provide the following _Application Settings_:

| Setting | Description |
| --- | --- |
| SP_KEY | Access key of the Service Principal |
| SP_NAME | ClientId/Name of the Service Principal |
| TENNANT_ID | The Tennant Id, acquired from the Azure Portal |
| SUBSCRIPTION_ID | The Id od your Subscription |
| ACI_RESOURCEGROUP | The Resource Group name in which the container group is located which executes the certbot |
| ACI_CONTAINERGROUP | The name of the ACI Container Group |

to debug the function implementation and trigger locally, just provide the settings in the `local.settings.json` file in the schedule-function-app directory:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "<Storage Account Connection String>",
    "SP_KEY" : "<Service Principal Access Key>",
    "SP_NAME" : "<Service Principal Cient ID>",
    "TENNANT_ID" : "<Tennant ID>",
    "SUBSCRIPTION_ID" : "<Subscription ID>",
    "ACI_RESOURCEGROUP" : "<Resource Group Name>",
    "ACI_CONTAINERGROUP" : "<Certbot ACI Gontainer Group Name>",
    "FUNCTIONS_WORKER_RUNTIME": "node"
  }
}

```