#!/usr/bin/env bash

set -xe

SUBSCRIPTION_ID="CyberScot-Prd"
SHORTHAND_NAME="cscot"
SHORTHAND_ENV="prd"
SHORTHAND_LOCATION="uks"
GITLAB_ORG="cyber-scot"
GITLAB_REPO="terraform-ci-cd-glue"

print_success() {
    lightcyan='\033[1;36m'
    nocolor='\033[0m'
    echo -e "${lightcyan}$1${nocolor}"
}

print_error() {
    lightred='\033[1;31m'
    nocolor='\033[0m'
    echo -e "${lightred}$1${nocolor}"
}

print_alert() {
    yellow='\033[1;33m'
    nocolor='\033[0m'
    echo -e "${yellow}$1${nocolor}"
}

title_case_convert() {
    sed 's/.*/\L&/; s/[a-z]*/\u&/g' <<<"$1"
}

upper_case_convert() {
    sed -e 's/\(.*\)/\U\1/' <<< "$1"
}

lower_case_convert() {
    sed -e 's/\(.*\)/\L\1/' <<< "$1"
}

lowerConvertedShorthandName="$(lower_case_convert $SHORTHAND_NAME)"
lowerConvertedShorthandEnv="$(lower_case_convert $SHORTHAND_ENV)"
lowerConvertedShorthandLocation="$(lower_case_convert $SHORTHAND_LOCATION)"

titleConvertedShorthandName="$(title_case_convert $SHORTHAND_NAME)"
titleConvertedShorthandEnv="$(title_case_convert $SHORTHAND_ENV)"
titleConvertedShorthandLocation="$(title_case_convert $SHORTHAND_LOCATION)"

RESOURCE_GROUP_NAME="rg-${lowerConvertedShorthandName}-${lowerConvertedShorthandLocation}-${lowerConvertedShorthandEnv}-mgmt"
KEYVAULT_NAME="kv-${lowerConvertedShorthandName}-${lowerConvertedShorthandLocation}-${lowerConvertedShorthandEnv}-mgmt-01"

export DEBIAN_FRONTEND=noninteractive

#Checks if Azure-CLI is installed
if [[ ! $(command -v az) ]] ;
then
    print_error "You must install Azure CLI to use this script" && exit 1
else
    print_success "Azure-CLI is installed!, continuing" && sleep 2s
fi

if [ "$(az account show)" ]; then
    print_success "You are logged in!, continuing"
else
    print_error "You need to logged in to run this script" && exit 1
fi

#az login --service-principal \
# -u ${ARM_CLIENT_ID} \
# -p ${ARM_CLIENT_SECRET} \
# -t ${ARM_TENANT_ID}

az account set --subscription "${SUBSCRIPTION_ID}" && \
subId=$(az account show --query id -o tsv)
appId=$(az ad app create --display-name gitlab-oidc --query appId -o tsv)
svp=$(az ad sp create --id $appId --query appId -o tsv)
objectId=$(az ad app show --id $appId --query id -o tsv)

cat <<EOF > body.json
{
  "name": "gitlab-federated-identity",
  "issuer": "https://gitlab.com",
  "subject": "project_path:${GITLAB_ORG}/${GITLAB_REPO}:ref_type:branch:ref:main",
  "description": "GitLab service account federated identity",
  "audiences": [
    "https://gitlab.com"
  ]
}
EOF

az rest --method POST --uri "https://graph.microsoft.com/beta/applications/$objectId/federatedIdentityCredentials" --body @body.json
az role assignment create --assignee $appId --role Reader --scope /subscriptions/$subId
appId=$(az ad app list --display-name gitlab-oidc --query '[0].appId' -o tsv)
az role assignment create --assignee $appId --role "Key Vault Secrets User" --scope /subscriptions/$subId
