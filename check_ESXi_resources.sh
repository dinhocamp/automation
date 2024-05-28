#!/bin/bash

check_physical_memory() {
    esxcli hardware memory get | grep Physical | awk '{print $3/1024^3 " GB"}'
}

check_cpu_info() {
    esxcli hardware cpu list
}

check_storage_info() {
    echo "Storage Adapters:"
    esxcli storage core adapter list

    echo "Storage Devices:"
    esxcli storage core device list
}

echo "Checking Physical Memory:"
check_physical_memory

echo "Checking CPU Information:"
check_cpu_info

echo "Checking Storage Information:"
check_storage_info
