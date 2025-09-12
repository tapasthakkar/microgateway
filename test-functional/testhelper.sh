#
# Author: dkoroth@google.com
#

proxyBundleVersion="1"

API_PRODUCT_URL="https://api.enterprise.apigee.com/v1/o"
API_PROXY_URL="https://api.enterprise.apigee.com/v1/organizations"

CURL="curl -q -s"

function logError(){
    echo -e "[ERROR]: $*" >> $LOGFILE
}

function logInfo(){
    echo -e "[INFO]: $*" >> $LOGFILE
}

#
#
# Developer APIs 
# 
#

function listDevelopers() {

    local result=0
    local ret=0

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/developers" 
    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -D headers.txt -o listDevelopers.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully retrieved developer list with code $result"
    else
         logError "Failed to retrieve developer lists with code $result"
         ret=1
    fi

    rm -f listDevelopers.txt
    rm -f headers.txt

    return $ret

}

function createDeveloper() {

    local result=0
    local ret=0

    apiDeveloper="$1"

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/developers" 

    node substVars "templates/apideveloper-template.json" "devguy" "${apiDeveloper}" > "${apiDeveloper}".json

    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -X POST -d @"${apiDeveloper}".json -D headers.txt -o createDeveloper.txt > /dev/null 2>&1 ; ret=$?

    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 201 ]; then
         logInfo "Successfully created developer with code $result"
    else
         logError "Failed to create developer with code $result"
         ret=1
    fi

    rm -f "${apiDeveloper}".json
    rm -f createDeveloper.txt
    rm -f headers.txt

    return $ret

}

function listDeveloper() {

    local result=0
    local ret=0

    apiDeveloper="$1"

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/developers/${apiDeveloper}@google.com"
    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -D headers.txt -o listDeveloper.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully retrieved developer with code $result"
    else
         logError "Failed to retrieve developer list with code $result"
         ret=1
    fi

    rm -f listDeveloper.txt
    rm -f headers.txt

    return $ret

}

function deleteDeveloper() {

    local result=0
    local ret=0

    apiDeveloper="$1"

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/developers/${apiDeveloper}@google.com"
    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" -X DELETE ${apiProxyURL} -D headers.txt -o deleteDeveloper.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully deleted developer with code $result"
    else
         logError "Failed to delete developer with code $result"
         ret=1
    fi

    rm -f deleteDeveloper.txt
    rm -f headers.txt

    return $ret

}

#
#
# Developer Apps APIs 
# 
#

function listDeveloperApps() {

    local result=0
    local ret=0

    apiDeveloper="$1"

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/developers/${apiDeveloper}@google.com/apps"
    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -D headers.txt -o listDeveloperApps.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully retrieved developer app list with code $result"
    else
         logError "Failed to retrieve developer apps list with code $result"
         ret=1
    fi

    rm -f listDeveloperApps.txt
    rm -f headers.txt

    return $ret

}

function createDeveloperApp() {

    local result=0
    local ret=0

    apiDeveloper="$1"
    apiDeveloperApp="$2"
    apiProductName="$3"

    node substVars "templates/apideveloperapp-template.json" "productName" "${apiProductName}" "devAppName" "${apiDeveloperApp}" > "${apiDeveloperApp}".json

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/developers/${apiDeveloper}@google.com/apps" 

    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -X POST -d @${apiDeveloperApp}.json -D headers.txt -o createDeveloperApp.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 201 ]; then
         logInfo "Successfully created developer app with code $result"
    else
         logError "Failed to create developer app with code $result"
         ret=1
    fi

    rm -f createDeveloperApp.txt
    rm -f headers.txt

    return $ret
}


function listDeveloperApp() {

    local result=0
    local ret=0

    apiDeveloper="$1"
    apiDeveloperApp="$2"

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/developers/${apiDeveloper}@google.com/apps/${apiDeveloperApp}"
    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -D headers.txt -o listDeveloperApp.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully retrieved developer app with code $result"
    else
         logError "Failed to retrieve developer app with code $result"
         ret=1
    fi

    rm -f listDeveloperApp.txt
    rm -f headers.txt

    return $ret

}

function getDeveloperApiKey() {

    local result=0
    local ret=0

    apiKeysJson=" "
    apiDeveloper="$1"
    apiDeveloperApp="$2"

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/developers/${apiDeveloper}@google.com/apps/${apiDeveloperApp}"
    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -D headers.txt -o getDeveloperApiKey.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully retrieved developer api key with code $result"
          apiKeysJson=$(jq '.credentials[0] | {consumerKey, consumerSecret}' getDeveloperApiKey.txt)
    else
         logError "Failed to retrieve developer api key with code $result"
         ret=1
    fi

    rm -f getDeveloperApiKey.txt
    rm -f headers.txt
     # echo "$apiKeysJson" >&2
    echo "$apiKeysJson"

}

function getAuthToken() {
    local result=0
    local ret=0
    local accessToken=""

    # Check for required arguments
    if [ -z "$1" ] || [ -z "$2" ]; then
        logError "getAuthToken requires client_id and client_secret as arguments" >&2
        return 1
    fi

    local clientId="$1"
    local clientSecret="$2"
    local tokenURL="https://${MOCHA_ORG}-test.apigee.net/edgemicro-auth/token"

    # Construct the JSON payload safely
    local jsonData
    jsonData=$(printf '{"client_id":"%s","client_secret":"%s","grant_type":"client_credentials"}' "$clientId" "$clientSecret")

    # Make the curl request
    curl -s --request POST \
      --url "$tokenURL" \
      --header 'Content-Type: application/json' \
      --data "$jsonData" \
      -D getAuthToken_headers.txt \
      -o getAuthToken_response.txt
    ret=$?

    result=$(grep HTTP getAuthToken_headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 ] && [ "${result}" -eq 200 ]; then
         logInfo "Successfully retrieved auth token with code $result" >&2
         # Use jq to parse the access_token from the response body
         accessToken=$(jq -r '.access_token' getAuthToken_response.txt)
    else
         logError "Failed to retrieve auth token with code $result" >&2
         # Print the error response for debugging
         cat getAuthToken_response.txt >&2
         ret=1
    fi

    # Clean up temporary files
    rm -f getAuthToken_headers.txt getAuthToken_response.txt

    # Return the access token on stdout
    echo "$accessToken"
    return $ret
}

function deleteDeveloperApp() {

    local result=0
    local ret=0

    apiDeveloper="$1"
    apiDeveloperApp="$2"

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/developers/${apiDeveloper}@google.com/apps/${apiDeveloperApp}"
    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" -X DELETE ${apiProxyURL} -D headers.txt -o deleteDeveloperApp.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully delete developer app with code $result"
    else
         logError "Failed to delete developer app with code $result"
         ret=1
    fi

    rm -f deleteDeveloperApp.txt
    rm -f headers.txt

    return $ret

}

#
#
# API Proxy APIs
# 
#

function listAPIProxy() {

    local result=0
    local ret=0

    apiProxyName="$1"

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/apis/${apiProxyName}"
    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -D headers.txt -o listAPIProxy.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully retrieve API Proxy list with code $result"
    else
         logError "Failed to retrieve API Proxy list with code $result"
         ret=1
    fi

    rm -f listAPIProxy.txt
    rm -f headers.txt

    return $ret

}


function listAPIProxies() {

    local result=0
    local ret=0

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/apis" 

    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN"  ${apiProxyURL} -D headers.txt -o listAPIProxies.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully retrieve API Proxies list with code $result"
    else
         logError "Failed to retrieve API Proxies list with code $result"
         ret=1
    fi

    rm -f listAPIProxies.txt

    return $ret

}

function createAPIProxy() {

    local result=0
    local ret=0

    apiProxyName="$1"
    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/apis"

    node substVars "templates/apiproxy-template.json" "proxyName" "$apiProxyName" > "${apiProxyName}".json

    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN"  ${apiProxyURL} -X POST -d @"${apiProxyName}".json -D headers.txt -o createAPIProxy.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 201 ]; then
         logInfo "Successfully created API Proxy with code $result"
    else
         logError "Failed to create API Proxy with code $result"
         ret=1
    fi
    rm -f "${apiProxyName}".json
    rm -f createAPIProxy.txt
    rm -f headers.txt

    return $ret

}


function listAPIProxy() {

    local result=0
    local ret=0

    apiProxyName="$1"
    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/apis/${apiProxyName}"

    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -D headers.txt -o listAPIProxy.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully retrieve API Proxy list with code $result"
    else
         logError "Failed to retrieve API Proxy list with code $result"
         ret=1
    fi

    rm -f listAPIProxy.txt
    rm -f headers.txt

    return $ret

}

function updateAPIProxy() {

    local result=0
    local ret=0

    apiProxyName="$1"
    apiProxyBundle="$2"
    apiProxyBundleRevision="$3"

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/apis/${apiProxyName}/revisions/${apiProxyBundleRevision}" 

    ${CURL} -H "Content-Type: multipart/form-data" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN"  ${apiProxyURL} -X POST -F "file=@${apiProxyBundle}" -D headers.txt -o updateAPIProxy.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | grep -v 100 | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully updated API Proxy with code $result"
    else
         logError "Failed to update API Proxy with code $result"
         ret=1
    fi

    rm -f updateAPIProxy.txt
    rm -f headers.txt

    return $ret

}

function deployAPIProxy() {

    local result=0
    local ret=0

    apiProxyName="$1"
    envName="$2"
    apiProxyBundleRevision="$3"

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/environments/${envName}/apis/${apiProxyName}/revisions/${apiProxyBundleRevision}/deployments" 

    ${CURL} -H "Content-Type: application/x-www-form-urlencoded" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -X POST -D headers.txt -o deployAPIProxy.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully deployed API Proxy with code $result"
    else
         logError "Failed to deploy API Proxy with code $result"
         ret=1
    fi

    rm -f deployAPIProxy.txt
    rm -f headers.txt

    return $ret

}

function undeployAPIProxy() {

    local result=0
    local ret=0

    apiProxyName="$1"
    envName="$2"
    apiProxyBundleRevision="$3"

    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/environments/${envName}/apis/${apiProxyName}/revisions/${apiProxyBundleRevision}/deployments" 

    ${CURL} -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -X DELETE -D headers.txt -o undeployAPIProxy.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully undeployed API Proxy with code $result"
    else
         logError "Failed to undeploy API Proxy with code $result"
         ret=1
    fi

    rm -f undeployAPIProxy.txt
    rm -f headers.txt

    return $ret

}

function deleteAPIProxy() {

    local result=0
    local ret=0

    apiProxyName="$1"
    apiProxyURL="${API_PROXY_URL}/${MOCHA_ORG}/apis/${apiProxyName}"

    ${CURL} -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${apiProxyURL} -X DELETE -D headers.txt -o deleteAPIProxy.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully deleted API Proxy with code $result"
    else
         logError "Failed to delete API Proxy with code $result"
         ret=1
    fi

    rm -f deleteAPIProxy.txt
    rm -f headers.txt

    return $ret

}

function createAPIProxyBundle() {

    local result=0
    local ret=0

    apiProxyName="$1"
    proxyPrefix="edgemicro_proxy"

    mkdir -p apiproxy
    cp -rf templates/apiproxy_template/* apiproxy/
    mv apiproxy/$proxyPrefix.xml apiproxy/$apiProxyName.temp.xml
    mv apiproxy/proxies/default.xml apiproxy/proxies/default.temp.xml
    mv apiproxy/targets/default.xml apiproxy/targets/default.temp.xml
    sed "s,${proxyPrefix},${apiProxyName},g" apiproxy/$apiProxyName.temp.xml > apiproxy/$apiProxyName.xml
    sed "s,${proxyPrefix},${apiProxyName},g" apiproxy/proxies/default.temp.xml > apiproxy/proxies/default.xml
    sed "s,TARGET_URL,${proxyTargetUrl},g" apiproxy/targets/default.temp.xml > apiproxy/targets/default.xml
    rm -f apiproxy/$apiProxyName.temp.xml
    rm -f apiproxy/proxies/default.temp.xml
    rm -f apiproxy/targets/default.temp.xml
    zip -q -r ${apiProxyName}.zip apiproxy/
    rm -rf apiproxy/

    if [ ! -f ${apiProxyName}.zip ]; then
         logError "Failed to create API Proxy Bundle ${apiProxyName}.zip"
         ret=1
    else
         logInfo "Successfully created API Proxy Bundle ${apiProxyName}.zip"
         ret=0
    fi

    return $ret

}

#
#
# Product APIs
# 
#

function listAPIProducts() {

    local result=0
    local ret=0

    productURL="${API_PRODUCT_URL}/${MOCHA_ORG}/apiproducts"
    ${CURL} -q -s -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${productURL} -D headers.txt -o listAPIProducts.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully retrieved API Products list with code $result"
    else
         logError "Failed to retrieve API Products list with code $result"
         ret=1
    fi

    rm -f listAPIProducts.txt
    rm -f headers.txt

    return $ret

}

function createAPIProduct() {

    local result=0
    local ret=0

    apiProductName="$1"
    apiProxyName="$2"
    apiProxyNameQuota="$3"

    # --- LOG 1: Print the arguments passed to the function ---
    logInfo "--- Creating API Product ---" >&2
    logInfo "Product Name: ${apiProductName}" >&2
    logInfo "Proxy Name 1: ${apiProxyName}" >&2
    logInfo "Proxy Name 2: ${apiProxyNameQuota}" >&2

    # Generate the JSON payload
    node substVars "templates/apiproduct-template.json" \
        "proxyName" "${apiProxyName}" \
        "productName" "${apiProductName}" \
        "quotaProxyName" "${apiProxyNameQuota}"  >  "${apiProductName}".json

    # --- LOG 2: Print the exact JSON payload that will be sent ---
    logInfo "Generated JSON payload:" >&2

    productURL="${API_PRODUCT_URL}/${MOCHA_ORG}/apiproducts"

    # --- LOG 3: Show the URL being called ---
    logInfo "Sending POST request to: ${productURL}" >&2

    ${CURL} -q -s -H "Content-Type:application/json" -X POST -d @"${apiProductName}".json -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${productURL} -D headers.txt -o createAPIProduct.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 201 ]; then
         logInfo "Successfully created API Product with code $result" >&2
    else
         logError "Failed to create API Product with code $result" >&2
         logError "--- API Error Response ---" >&2
         cat createAPIProduct.txt >&2
         logError "--------------------------" >&2
         ret=1
    fi

    rm -f createAPIProduct.txt
    rm -f headers.txt

    return $ret
}

function listAPIProduct() {

    local result=0
    local ret=0

    apiProductName="$1"

    productURL="${API_PRODUCT_URL}/${MOCHA_ORG}/apiproducts/${apiProductName}"
    ${CURL} -q -s -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${productURL} -D headers.txt -o listAPIProduct.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully retrieved API Product list with code $result"
    else
         logError "Failed to retrieve API Product list with code $result"
         ret=1
    fi

    rm -f listAPIProduct.txt
    rm -f headers.txt

    return $ret

}

function deleteAPIProduct() {

    local result=0
    local ret=0

    apiProductName="$1"
    productURL="${API_PRODUCT_URL}/${MOCHA_ORG}/apiproducts/${apiProductName}"

    ${CURL} -q -s -H "Content-Type:application/json" -H "Authorization: Bearer $MOCHA_BEARER_TOKEN" ${productURL} -X DELETE -D headers.txt -o deleteAPIProduct.txt > /dev/null 2>&1 ; ret=$?
    result=$(grep HTTP headers.txt | cut -d ' ' -f2)
    if [ ${ret} -eq 0 -a ${result} -eq 200 ]; then
         logInfo "Successfully deleted API Product with code $result"
    else
         logError "Failed to delete API Product with code $result"
         ret=1
    fi

    rm -f deleteAPIProduct.txt
    rm -f headers.txt

    return $ret

}

reloadMicrogatewayNow() {
  EMG_KEY=$(cat edgemicro.configure.txt | grep "key:" | cut -d ' ' -f8)
  EMG_SECRET=$(cat edgemicro.configure.txt | grep "secret:" | cut -d ' ' -f8)
  if [ -z $EMG_KEY -o -z $EMG_SECRET ]; then
     result=1
     logError "Failed to retrieve emg key and secret from edgemicro.configure.txt"
     return $result
  fi

  $EDGEMICRO reload -o $MOCHA_ORG -e $MOCHA_ENV -k $EMG_KEY -s $EMG_SECRET > /dev/null 2>&1
  result=$?
  if [ $result -ne 0 ]; then
       logError "Failed to reload EMG with status $result"
  else
       logInfo "Successfully reloaded EMG with status $result"
  fi

  sleep 10
}