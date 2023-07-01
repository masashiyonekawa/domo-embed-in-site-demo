#!/bin/bash
BASE_URL="https://api.domo.com"
ACCESS_TOKEN_URL=$BASE_URL"/oauth/token?grant_type=client_credentials&scope=dashboard"
EMBED_TOKEN_URL=$BASE_URL"/v1/stories/embed/auth"
EMBED_HOST="https://public.domo.com"

CLIENT_ID=$1
CLIENT_SECRET=$2
EMBED_ID=$3

B64VAL=`echo -n $CLIENT_ID:$CLIENT_SECRET | base64`
B64VAL2=`echo -n $B64VAL | sed 's/ //g'`
echo $B64VAL2

curl=`cat <<EOS
  curl --location "$ACCESS_TOKEN_URL"
  --verbose
  --header 'Authorization: Basic $B64VAL2'
  --header 'Accept: */*'
EOS`

ACCESS_TOKEN=$(eval ${curl} | jq ".access_token" -r)

curl=`cat <<EOS
  curl --location "$EMBED_TOKEN_URL"
  --verbose
  --header 'Authorization: Bearer $ACCESS_TOKEN'
  --header 'Accept: application/json'
  --header 'Content-Type: application/json'
  --data '{
    "sessionLength": 1440,
    "authorizations": [
      {
        "token": "$EMBED_ID",
        "permissions": [
          "READ",
          "FILTER",
          "EXPORT"
        ],
        "filters": []
      }
    ]
  }'
EOS`

EMBED_TOKEN=$(eval ${curl} | jq ".authentication" -r)

cat <<EOF > index.html 
<html>
<body>
<form id="form" action="$EMBED_HOST/embed/pages/$EMBED_ID" method="post">
<input type="hidden" name="embedToken" value="$EMBED_TOKEN">
</form>
<script>document.forms[0].submit();</script>
</body>
</html>
EOF
