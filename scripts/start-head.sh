#!/bin/bash
set -e

echo "====================================="
echo " Starting Ray Head Node on VMware    "
echo "====================================="

# Navigate to the docker directory
cd "$(dirname "$0")/../docker"

# Spin up the Head container
docker compose -f docker-compose-head.yml up -d

echo ""
echo "Ray Head Node is spinning up."
echo "Dashboard will be accessible at http://$(hostname -I | awk '{print $1}'):8265"
echo "Monitor tasks using: docker logs -f ray-head"
