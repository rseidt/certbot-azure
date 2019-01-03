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