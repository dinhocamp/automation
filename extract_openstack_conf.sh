#!/bin/bash

#remote_user="your_remote_username"
#remote_host="remote_host_ip_or_hostname"
#remote_script_path="/path/to/remote_script.sh"

extract_local_conf_values() {
    local_conf_file="/path/to/local.conf"
    
    if [ -f "$local_conf_file" ]; then
        admin_password=$(awk -F= '/ADMIN_PASSWORD/{print $2}' "$local_conf_file")
        database_password=$(awk -F= '/DATABASE_PASSWORD/{print $2}' "$local_conf_file")
        rabbit_password=$(awk -F= '/RABBIT_PASSWORD/{print $2}' "$local_conf_file")
        service_password=$(awk -F= '/SERVICE_PASSWORD/{print $2}' "$local_conf_file")
        ipv4_addrs_safe_to_use=$(awk -F= '/IPV4_ADDRS_SAFE_TO_USE/{print $2}' "$local_conf_file")
        logfile=$(awk -F= '/LOGFILE/{print $2}' "$local_conf_file")

        echo "ADMIN_PASSWORD=$admin_password"
        echo "DATABASE_PASSWORD=$database_password"
        echo "RABBIT_PASSWORD=$rabbit_password"
        echo "SERVICE_PASSWORD=$service_password"
        echo "IPV4_ADDRS_SAFE_TO_USE=$ipv4_addrs_safe_to_use"
        echo "LOGFILE=$logfile"
    else
        echo "Error: local.conf file not found."
    fi
}

extract_openrc_values() {
    openrc_file="/path/to/openrc"
    
    if [ -f "$openrc_file" ]; then
        source "$openrc_file"
        echo "OS_PROJECT_NAME=$OS_PROJECT_NAME"
        echo "OS_USERNAME=$OS_USERNAME"
        echo "OS_PASSWORD=$OS_PASSWORD"
        echo "HOST_IP=$HOST_IP"
        echo "SERVICE_HOST=$SERVICE_HOST"
        echo "OS_AUTH_URL=$OS_AUTH_URL"
    else
        echo "Error: openrc file not found."
    fi
}

main() {
    echo "Values extracted from local.conf:"
    extract_local_conf_values

    echo "Values extracted from openrc:"
    extract_openrc_values
}

#ssh "$remote_user@$remote_host" "$remote_script_path"

