#!/bin/bash
set -e

if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <HEAD_NODE_IP> <TIER_TAG: always-on|heavy-compute> <NUM_CPUS> <SHM_GB>"
    echo "Example (Heavy Node): $0 192.168.10.5 tier_heavy_compute 80 150"
    exit 1
fi

export HEAD_NODE_IP=$1
export RAY_TIER=$2
export NUM_CPUS=$3
SHM_SIZE_GB=$4

echo "====================================="
echo " Starting Ray Worker Node            "
echo " Connecting to Head: $HEAD_NODE_IP   "
echo " Tier: $RAY_TIER                     "
echo " CPUs: $NUM_CPUS                     "
echo "====================================="

# Navigate to the docker directory
cd "$(dirname "$0")/../docker"

# Export ShmSize for docker compose dynamically
export SHM_SIZE="${SHM_SIZE_GB}g"

# Spin up the Worker container
docker compose -f docker-compose-worker.yml up -d

echo "Ray Worker Node started successfully."
