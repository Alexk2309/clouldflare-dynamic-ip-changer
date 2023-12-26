#!/bin/dash

authEmail='<EMAIL>'
globalApiKey='<KEY>'
zoneIdentifier='<ZONE_KEY>'

while true 
    do 
        currentIp=$(curl -s https://api64.ipify.org)
        lastIp=$(head -n 1 old_ip.txt)

        if [ "$lastIp" != "$currentIp" ]; then
            response=$(curl -s --request GET \
                --url https://api.cloudflare.com/client/v4/zones/$zoneIdentifier/dns_records \
                --header "X-Auth-Email: $authEmail" \
                --header "X-Auth-Key: $globalApiKey")

            for row in $(echo "$response" | jq -c '.result[]'); do
                # Extract and print relevant information from each record
                id=$(echo "$row" | jq -r '.id')
                name=$(echo "$row" | jq -r '.name')
                type=$(echo "$row" | jq -r '.type')
                content=$(echo "$row" | jq -r '.content')

                if [ "$content" = "$lastIp" ]; then
                    echo "Record ID: $id"
                    echo "Name: $name"
                    echo "Type: $type"
                    echo "content: $content"

                    curl --request PUT \
                    --url https://api.cloudflare.com/client/v4/zones/bf4d5da37b541a982eb63cda1be2a90f/dns_records/$id \
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
            echo "$currentIp" >| old_ip.txt
        fi
        sleep 300
        echo 'Checking for changed ip'
    done 

        
