#!/bin/sh
./az-login.sh

AZURE_DNSZONE_RESOURCEGROUP="<Resource Group Name of your Azure DNS Zone resource>"
AZURE_DNSZONE_RESOURCENAME="<Name of your Azure DNS Zone resource>"

az network dns record-set txt delete -g "appgateway" -z "seidt.org" -n "_acme-challenge" --yes