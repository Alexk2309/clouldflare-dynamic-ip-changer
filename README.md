# Dynamic DNS Update Script Documentation

## Overview

The provided script is a dynamic DNS (DDNS) update script written in the Dash shell. It is designed to run continuously and monitor changes in the public IP address of a home server. When the public IP address changes, it updates the corresponding DNS record on Cloudflare to ensure that the domain always points to the correct IP address.

## Requirements

Before using the script, ensure the following:

- **Dash Shell:** The script is written in the Dash shell (`/bin/dash`). Make sure Dash is installed on your system.

- **jq:** The script uses `jq` for JSON parsing. Ensure that `jq` is installed on your system. You can install it using your package manager (e.g., `apt-get install jq`).

- **API Key and Email:** Obtain your Cloudflare API key, Cloudflare account email, and the Zone Identifier for the domain you want to update. Replace `<EMAIL>`, `<KEY>`, and `<ZONE_KEY>` with your Cloudflare email, API key, and Zone Identifier, respectively.

- **Home Hosted Domain:** Set the `homeHostedDomain` variable to the domain hosted on your home server. The script assumes that the Cloudflare DNS record associated with this domain should be updated.

## Script Execution

The script runs in an infinite loop, periodically checking the public IP address of your home server and the corresponding Cloudflare DNS record. If a change is detected, it updates the DNS record with the new IP address.

### Variables

- **authEmail:** Your Cloudflare account email.
- **globalApiKey:** Your Cloudflare API key.
- **zoneIdentifier:** The Zone Identifier for the Cloudflare domain.
- **homeHostedDomain:** The domain hosted on your home server.

### Script Flow

1. **Retrieve Current IP:** Use the `curl` command to fetch the current public IP address from [https://api64.ipify.org](https://api64.ipify.org).

2. **Retrieve Cloudflare DNS Records:** Use the Cloudflare API to retrieve DNS records for the specified Zone Identifier. Extract the current IP address associated with the home-hosted domain.

3. **Check IP Change:** Compare the current IP with the Cloudflare-stored IP. If they differ, update the Cloudflare DNS record.

4. **Update Cloudflare Record:** Iterate through the Cloudflare DNS records. When the record matching the home-hosted domain is found, update it with the new IP address.

5. **Sleep and Repeat:** Sleep for 300 seconds (5 minutes) before checking for IP changes again. The loop continues indefinitely.

### Usage

1. Make the script executable: `chmod +x script_name.sh`

2. Run the script: `./script_name.sh`

3. Monitor the script output for IP changes and Cloudflare record updates.

## Important Notes

- **Security:** Keep your Cloudflare API key and email secure. Do not share them openly or hardcode them into publicly accessible scripts.

- **Logging:** Consider redirecting script output to a log file for historical tracking: `./script_name.sh >> ddns.log 2>&1`

- **Firewall Considerations:** Ensure that your firewall allows outgoing HTTP requests to the necessary APIs.

- **Script Customization:** Modify the script as needed, especially if you want to adapt it for different DNS providers or add more features.

By following these instructions and regularly monitoring the script's output, you can maintain an up-to-date DNS record for your home server, even if your ISP periodically changes your public IP address.


# Setting Up as a System Service (Systemd)

To ensure the Dynamic DNS update script runs continuously and automatically at system startup, you can set it up as a systemd service. Follow the steps below:

1. **Create a Service File**

   Create a systemd service file to define the service. For example, create a file named `ddns-update.service`:

   ```bash
   sudo nano /etc/systemd/system/ddns-update.service

2. Create a systemd unit file to define the service. For example, create a file named `ddns-update.service`:

    ```ini
    [Unit]
    Description=<NAME>
    After=network.target

    [Service]
    Type=simple
    Restart=always
    ExecStart=/path/to/the/script/

    [Install]
    WantedBy=multi-user.target

3. **Save and Close**

   Save the file and exit the text editor.


4. **Start the service**

    ```bash
    sudo systemctl start ddns-update.service

5. **Enable the script to start on boot**

    ```bash
    sudo systemctl enable ddns-update.service

6. **Reload systemd**

   Reload the systemd manager to read the newly created service file:

   ```bash
   sudo systemctl daemon-reload

# Viewing Logs
To view logs for your IP changer service, you can use journalctl:

View the entire log for the service:

```bash
sudo journalctl -u ddns-update.service

