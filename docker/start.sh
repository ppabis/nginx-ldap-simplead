#!/bin/bash

# Exit on any error
set -e

if [ ! -d "nginx-ldap-auth-service" ]; then
  git clone https://github.com/ppabis/nginx-ldap-auth-service
fi

# Get SSM parameters
echo "Fetching SSM parameters..."
AD_DNS_IP=$(aws ssm get-parameter --name "/nginx-ldap/ad-dns-ip" --query "Parameter.Value" --output text)
AD_NAME=$(aws ssm get-parameter --name "/nginx-ldap/ad-server-name" --query "Parameter.Value" --output text)
AD_PASSWORD=$(aws ssm get-parameter --name "/nginx-ldap/ad-admin-password" --with-decryption --query "Parameter.Value" --output text)

# Export environment variables
export LDAP_URI="ldap://${AD_DNS_IP}"
export LDAP_BASEDN="DC=$(echo ${AD_NAME} | sed 's/\./,DC=/g')"
export LDAP_BINDDN="CN=Administrator,CN=Users,$(echo ${AD_NAME} | sed 's/\./,DC=/g')"
export LDAP_PASSWORD="${AD_PASSWORD}"
export LDAP_GROUP="CN=webservice,CN=Users,DC=auth,DC=company,DC=internal"

# Start docker-compose
echo "Starting docker-compose..."
docker-compose up -d

echo "Services started successfully!" 