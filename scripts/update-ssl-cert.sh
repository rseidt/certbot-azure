#!/bin/sh
/var/scripts/az-login.sh

CERT_PASSWD="<Password of your choice>"
AZURE_CERT_NAME="<Name of certificate in Azure Application Gateway>"
AZURE_APP_GW_RESOURCE_NAME="<Name of the Application Gateway Resource>"
AZURE_APP_GW_RESOURCE_GROUP_NAME="<Name of the Application Gateway Resource Group>"

openssl pkcs12 -export -out $RENEWED_LINEAGE/pkcs12_cert.pfx -inkey $RENEWED_LINEAGE/privkey.pem -in $RENEWED_LINEAGE/cert.pem -certfile $RENEWED_LINEAGE/chain.pem -password pass:$CERT_PASSWD
az network application-gateway ssl-cert update -n $AZURE_CERT_NAME --gateway-name $AZURE_APP_GW_RESOURCE_NAME -g $AZURE_APP_GW_RESOURCE_GROUP_NAME --cert-file "$RENEWED_LINEAGE/pkcs12_cert.pfx" --cert-password $CERT_PASSWD