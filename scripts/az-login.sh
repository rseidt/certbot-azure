#!/bin/sh
AZ_SERVICE_PRINCIPAL_NAME="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
AZ_SERVICE_PRINCIPAL_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
AZ_TENANT="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
az login --service-principal -u $AZ_SERVICE_PRINCIPAL_NAME -p $AZ_SERVICE_PRINCIPAL_KEY --tenant $AZ_TENANT