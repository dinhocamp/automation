#!/bin/bash

# Remote target details
#remote_user="your_remote_username"
#remote_host="remote_host_ip_or_hostname"
#remote_script_path="/path/to/remote_script.sh"

# Function to extract values from local.conf
extract_local_conf_values() {
    local_conf_file="/home/stack/devstack/local.conf"
    echo "extracting ..."
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

# Function to extract values from openrc
extract_openrc_values() {
    openrc_file="/home/stack/devstack/openrc"
    
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

# Main function
main() {
    echo "Values extracted from local.conf:"
    extract_local_conf_values

    echo "Values extracted from openrc:"
    extract_openrc_values
# Set OpenStack environment variables
export OS_AUTH_URL='http://10.10.17.245/identity'
export OS_PROJECT_ID='24530fc06fe14406bcec4743a9fb97d7'
export OS_PROJECT_NAME="demo"
export OS_USER_DOMAIN_NAME="Default"
#if [ -z "$OS_USER_DOMAIN_NAME" ]; then unset OS_USER_DOMAIN_NAME; fi
export OS_PROJECT_DOMAIN_ID="default"
#if [ -z "$OS_PROJECT_DOMAIN_ID" ]; then unset OS_PROJECT_DOMAIN_ID; fi
#unset OS_TENANT_ID
#unset OS_TENANT_NAME
export OS_USERNAME="admin"
echo THE OS_USERNAME IS  $OS_USERNAME
# Prompt for OpenStack password
#echo "Please enter your OpenStack Password for project $OS_PROJECT_NAME as user $OS_USERNAME:"
OS_PASSWORD_INPUT=secret
export OS_PASSWORD=$OS_PASSWORD_INPUT

# Set other optional variables
export OS_REGION_NAME="RegionOne"
#if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3

echo "OpenStack environment variables set for $OS_PROJECT_NAME project."

export OS_CLIENT_CONFIG_FILE=clouds.yaml
export OS_CLOUD=openstack
}
main

