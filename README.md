# Enterprise Ray Cluster Deployment on VMware

This repository demonstrates a production-grade, highly optimized deployment of a [Ray](https://www.ray.io/) cluster using Docker and shell scripts. The infrastructure is built on a VMware virtualization platform backed by elite enterprise hardware, carefully balancing continuous availability with massive scheduled compute power.

## 🏗 Infrastructure Architecture

The underlying virtualization platform is **VMware**, running on premium data center hardware:
- **Processors:** Intel Xeon Platinum 8180 CPUs
- **Memory:** DDR4 2933 MHz RAM
- **Storage:** VMware vSAN powered by Samsung PM1653 Enterprise NVMe SSDs
- **Network:** 4x 10Gbps fiber network ensuring ultra-low latency and colossal throughput between VMs

### Node Specifications

The Ray cluster spans 6 Ubuntu Virtual Machines divided into two performance tiers:

#### Heavy Compute Nodes (3 VMs)
- **Resources:** 80 Cores, 350GB RAM, 1TB SSD (per VM)
- **Schedule:** Operational from 6:00 PM to 6:00 AM
- **Purpose:** Used for intensive, large-scale distributed training and high-throughput batch processing during off-peak hours.

#### Always-On Core Nodes (3 VMs)
- **Resources:** 32 Cores, 110GB RAM, 400GB SSD (per VM)
- **Schedule:** 24/7 Continuous Uptime
- **Purpose:** Hosts the Ray Head node and critical Worker nodes to ensure cluster availability, maintain the Ray Dashboard, and serve continuous low-latency inference workloads.

## ✨ Key Features

- **Automated Deployment:** Deploy the Ray Head and Worker nodes efficiently using structured `docker-compose` setups optimized for host networking.
- **Graceful Preemption & Task Draining:** Automated shell scripts to gracefully drain Ray tasks from the Heavy Compute nodes before their scheduled 6:00 AM shutdown. This ensures zero data loss and prevents interrupted distributed workloads.
- **Cluster Monitoring and Dashboarding:** Exposes the highly-detailed Ray Dashboard for real-time memory, object store, and task profiling.
- **Resource Tagging:** Custom Ray resource tags (`tier: always-on`, `tier: heavy-compute`) for intelligent actor scheduling.

## 📂 Repository Structure

- `docker/` - Contains the Docker Compose definitions for Head and Worker nodes.
- `scripts/` - Shell automation scripts.
  - `start-head.sh` - Bootstraps the main Ray Head Node.
  - `start-worker.sh` - Bootstraps Ray Worker Nodes with appropriate labels.
  - `drain-heavy-nodes.sh` - Safely cordons and drains tasks from the 80-core VMs.
  - `monitor-tasks.sh` - Queries the Ray cluster for active/queued tasks.

## 🚀 Deployment Guide

### 1. Launch the Ray Head Node
Run this on one of the 32-core Always-On VMs:
```bash
cd scripts/
./start-head.sh
```
*The Ray dashboard will be available at `http://<HEAD_NODE_IP>:8265`.*

### 2. Launch the Always-On Workers
Run this on the remaining two 32-core VMs:
```bash
cd scripts/
./start-worker.sh <HEAD_NODE_IP> always-on 32 110
```

### 3. Launch the Heavy Compute Workers (At 6:00 PM)
Run this via `cron` or automation on the three 80-core VMs:
```bash
cd scripts/
./start-worker.sh <HEAD_NODE_IP> heavy-compute 80 350
```

### 4. Graceful Draining (At 5:45 AM)
Before the 80-core VMs are powered down at 6:00 AM, the cron job executes the draining script to migrate tasks efficiently:
```bash
cd scripts/
./drain-heavy-nodes.sh
```

## 🛑 Stopping the Cluster

To stop the Ray cluster components, execute the following steps:

### 1. Stop Heavy Compute Workers (if active)
Run this on the three 80-core VMs:
```bash
cd docker/
docker-compose -f docker-compose-worker.yml down
```

### 2. Stop Always-On Workers
Run this on the two 32-core worker VMs:
```bash
cd docker/
docker-compose -f docker-compose-worker.yml down
```

### 3. Stop Ray Head Node
Run this on the 32-core Head Node VM:
```bash
cd docker/
docker-compose -f docker-compose-head.yml down
```

## 📊 Monitoring

You can access the Ray Dashboard at `http://<HEAD_NODE_IP>:8265`. 
For CLI task monitoring, simply execute:
```bash
./scripts/monitor-tasks.sh
```
## 📋 Prerequisites

Before deploying the Ray cluster, ensure the following are installed and configured on your VMware Virtual Machines:

- **Operating System:** Ubuntu 20.04 LTS or newer
- **Docker:** Latest stable version. Follow the official Docker documentation for installation.
- **Docker Compose:** Latest stable version. Usually installed with Docker Desktop or as a separate package.
- **SSH Access:** Configured SSH access between your control machine and all Ray VMs for script execution.