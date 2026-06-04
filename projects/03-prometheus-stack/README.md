# Project 03 — Prometheus Observability Stack

## What this project does
A full production-grade monitoring stack running on GCP using Docker Compose.

## Stack
| Tool | Purpose | Port |
|---|---|---|
| Prometheus | Metrics collection and storage | 9090 |
| Grafana | Metrics visualization | 3000 |
| Alertmanager | Alert routing | 9093 |
| Node Exporter | VM system metrics | 9100 |

## Infrastructure
- GCE VM (e2-medium) inside devops-vpc public subnet
- Firewall rules for each tool
- Docker Compose for container orchestration
- Grafana dashboard ID 1860 for Node Exporter metrics

## Alert Rules
- High CPU Usage > 80% for 2 minutes
- High Memory Usage > 85% for 2 minutes  
- High Disk Usage > 85% for 5 minutes
- Instance Down > 1 minute

## How to run
```bash
docker compose up -d
docker compose ps
```
