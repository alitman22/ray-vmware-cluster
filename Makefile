# Makefile for Ray VMware Cluster Management

.PHONY: start-head start-worker-always-on start-worker-heavy-compute stop-head stop-worker monitor drain status help

# Variables
HEAD_NODE_IP ?= $(shell hostname -I | awk '{print $$1}')
MEMORY_GB_ALWAYS_ON = 110
MEMORY_GB_HEAVY = 350
CPUS_ALWAYS_ON = 32
CPUS_HEAVY = 80

help:
	@echo "Ray Cluster Management Commands:"
	@echo "  make start-head                  Start the Ray Head Node"
	@echo "  make start-worker-always-on      Start Always-On Worker (32 cores)"
	@echo "  make start-worker-heavy-compute  Start Heavy Compute Worker (80 cores)"
	@echo "  make stop-head                   Stop the Ray Head Node"
	@echo "  make stop-worker                 Stop the Ray Worker"
	@echo "  make monitor                     Show cluster status and resource usage"
	@echo "  make drain                       Gracefully drain heavy-compute worker"
	@echo "  make status                      Show running docker containers"

start-head:
	./scripts/start-head.sh

start-worker-always-on:
	./scripts/start-worker.sh $(HEAD_NODE_IP) always-on $(CPUS_ALWAYS_ON) $(MEMORY_GB_ALWAYS_ON)

start-worker-heavy-compute:
	./scripts/start-worker.sh $(HEAD_NODE_IP) heavy-compute $(CPUS_HEAVY) $(MEMORY_GB_HEAVY)

stop-head:
	cd docker && docker compose -f docker-compose-head.yml down

stop-worker:
	cd docker && docker compose -f docker-compose-worker.yml down

monitor:
	./scripts/monitor-tasks.sh

drain:
	./scripts/drain-heavy-nodes.sh

status:
	docker ps --filter name=ray
