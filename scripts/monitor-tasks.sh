#!/bin/bash
# Monitor the status of the Ray Cluster tasks

echo "====================================="
echo " Ray Cluster Task Monitor            "
echo "====================================="

if ! command -v ray &> /dev/null; then
    echo "This script assumes the 'ray' CLI is available."
    echo "Executing via docker exec on the ray-head node..."
    docker exec -t ray-head ray status
else
    ray status
fi

echo ""
echo "=== Resource Summary ==="
docker exec -t ray-head python3 -c "import ray; ray.init(address='auto'); print(ray.cluster_resources())"

echo ""
echo "To view detailed task timelines and memory profiling, visit the Ray Dashboard at port 8265."
