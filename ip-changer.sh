#!/bin/dash

authEmail='<EMAIL>'
globalApiKey='<KEY>'
zoneIdentifier='<ZONE_KEY>'

# Use a domain that you are always going to host on your home server.
# The script will assume your clouldflareIp is from here.
homeHostedDomain='<HOME_DOMAIN>'

while true 
    do 
        currentIp=$(curl -s https://api64.ipify.org)
        response=$(curl -s --request GET \
                --url https://api.cloudflare.com/client/v4/zones/$zoneIdentifier/dns_records \
                --header "X-Auth-Email: $authEmail" \
                --header "X-Auth-Key: $globalApiKey")
                
        cloudflareIp=$(echo "$response" | jq -r '.result[] | select(.name == "'"${homeHostedDomain}"'") | .content')

        if [ "$cloudflareIp" != "$currentIp" ]; then
            for row in $(echo "$response" | jq -c '.result[]'); do
                # Extract and print relevant information from each record
                id=$(echo "$row" | jq -r '.id')
                name=$(echo "$row" | jq -r '.name')
                type=$(echo "$row" | jq -r '.type')
                content=$(echo "$row" | jq -r '.content')

                if [ "$content" = "$cloudflareIp" ]; then
                    echo "Record ID: $id"
                    echo "Name: $name"
                    echo "Type: $type"
                    echo "content: $content"

                    curl --request PUT \
                    --url https://api.cloudflare.com/client/v4/zones/$zoneIdentifier/dns_records/$id \
                    --header 'Content-Type: application/json' \
                    --header "X-Auth-Email: $authEmail" \
                    --header "X-Auth-Key: $globalApiKey" \
                    --data '{
                        "content": "'"${currentIp}"'",
                        "name": "'"${name}"'",
                        "type": "A",
                        "ttl": 1
                    }'
                fi
            done
            echo "Changing $cloudflareIp to $currentIp"
        fi
        sleep 300
        echo 'Checking for changed ip'
    done 
