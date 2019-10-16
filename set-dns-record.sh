#!/bin/sh
az login --service-principal -u $AZ_SERVICE_PRINCIPAL_NAME -p $AZ_SERVICE_PRINCIPAL_KEY --tenant $AZ_TENANT
az network dns record-set txt add-record -g $AZURE_DNSZONE_RESOURCEGROUP -z $AZURE_DNSZONE_RESOURCENAME -n "_acme-challenge" -v $CERTBOT_VALIDATION
sleep 20