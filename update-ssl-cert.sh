#!/bin/sh
CERT_PASSWD="iqdcert4voith"

az login --service-principal -u $AZ_SERVICE_PRINCIPAL_NAME -p $AZ_SERVICE_PRINCIPAL_KEY --tenant $AZ_TENANT
openssl pkcs12 -export -out $RENEWED_LINEAGE/pkcs12_cert.pfx -inkey $RENEWED_LINEAGE/privkey.pem -in $RENEWED_LINEAGE/cert.pem -certfile $RENEWED_LINEAGE/chain.pem -password pass:$CERT_PASSWD
az network application-gateway ssl-cert update -n $AZURE_CERT_NAME --gateway-name $AZURE_APP_GW_RESOURCE_NAME -g $AZURE_APP_GW_RESOURCE_GROUP_NAME --cert-file "$RENEWED_LINEAGE/pkcs12_cert.pfx" --cert-password $CERT_PASSWD