#!/bin/bash
# Description: This script gracefully drains tasks from heavy-compute workers
# It should be triggered at 5:45 AM, giving tasks 15 minutes to complete or reschedule
# before the underlying VMware VMs are shut down at 6:00 AM.

echo "================================================="
echo " Initiating Graceful Drain of Heavy Compute Node "
echo "================================================="

# Retrieve the Node IP of this machine
NODE_IP=$(hostname -I | awk '{print $1}')

# Step 1: Ray stop graceful command
# This stops accepting new tasks and waits for ongoing tasks to finish
echo "[Time: $(date)] Stopping Ray processes gracefully..."
docker exec ray-worker ray stop --graceful

# Step 2: Shutdown the container after Ray has drained
echo "[Time: $(date)] Tearing down Docker container..."
cd "$(dirname "$0")/../docker"
docker compose -f docker-compose-worker.yml down

echo "[Time: $(date)] Node successfully drained and Ray worker stopped."
echo "VM is now safe to be powered off."
