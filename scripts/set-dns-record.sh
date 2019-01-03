#!/bin/sh
./az-login.sh

AZURE_DNSZONE_RESOURCEGROUP="<Resource Group Name of your Azure DNS Zone resource>"
AZURE_DNSZONE_RESOURCENAME="<Name of your Azure DNS Zone resource>"

az network dns record-set txt add-record -g $AZURE_DNSZONE_RESOURCEGROUP -z $AZURE_DNSZONE_RESOURCENAME -n "_acme-challenge" -v $CERTBOT_VALIDATION
sleep 20