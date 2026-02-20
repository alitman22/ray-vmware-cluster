#!/bin/bash
set -e

if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <HEAD_NODE_IP> <TIER_TAG: always-on|heavy-compute> <NUM_CPUS> <MEMORY_GB>"
    echo "Example (Heavy Node): $0 192.168.10.5 heavy-compute 80 350"
    exit 1
fi

export HEAD_NODE_IP=$1
export RAY_TIER=$2
export NUM_CPUS=$3
MEMORY_GB=$4

# Convert MEMORY_GB to MEMORY_MB for Ray
export MEMORY_MB=$(echo "scale=0; $MEMORY_GB * 1024" | bc)

echo "====================================="
echo " Starting Ray Worker Node            "
echo " Connecting to Head: $HEAD_NODE_IP   "
echo " Tier: $RAY_TIER                     "
echo " CPUs: $NUM_CPUS                     "
echo " Memory (GB): $MEMORY_GB             "
echo "====================================="

# Navigate to the docker directory
cd "$(dirname "$0")/../docker"

# Spin up the Worker container
docker compose -f docker-compose-worker.yml up -d

echo "Ray Worker Node started successfully."
