# Server Monitoring Dashboard

A comprehensive server monitoring solution using Prometheus, Grafana, and node_exporter. Monitor CPU, memory, disk, and network metrics across multiple servers with a beautiful dashboard and alerting system.

## Features

- 📊 **Real-time Monitoring**: CPU, RAM, disk, network metrics
- 📈 **Beautiful Dashboards**: Pre-configured Grafana dashboard
- 🚨 **Smart Alerts**: CPU, memory, disk space, and instance down alerts
- 🐳 **Docker-based**: Easy deployment with Docker Compose
- 🔧 **Easy Management**: Simple scripts for start, stop, restart
- 📡 **Scalable**: Add unlimited remote servers

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Ubuntu/Debian system (or any Linux with Docker support)
- Ports available: 3000 (Grafana), 9090 (Prometheus), 9093 (AlertManager), 9100 (Node Exporter)

### Installation

1. **Clone or download this repository**

```bash
cd /path/to/server-monitoring-dashboard
```

2. **Start the monitoring stack**

```bash
./scripts/start.sh
```

3. **Access Grafana**

Open your browser and go to: http://localhost:3000

- Username: `admin`
- Password: `admin` (you'll be prompted to change it)

4. **View the dashboard**

The "Server Monitoring Dashboard" will be automatically available in Grafana.

## Project Structure

```
server-monitoring-dashboard/
├── docker-compose.yml              # Docker services configuration
├── prometheus/
│   ├── prometheus.yml              # Prometheus configuration
│   └── alerts.yml                  # Alert rules
├── grafana/
│   └── provisioning/
│       ├── datasources/
│       │   └── prometheus.yml      # Auto-configure Prometheus datasource
│       └── dashboards/
│           ├── default.yml         # Dashboard provider
│           └── server-monitoring.json  # Main dashboard
├── alertmanager/
│   └── alertmanager.yml            # Alert notification configuration
├── scripts/
│   ├── start.sh                    # Start monitoring stack
│   ├── stop.sh                     # Stop monitoring stack
│   ├── restart.sh                  # Restart monitoring stack
│   ├── cleanup.sh                  # Remove all data and containers
│   └── logs.sh                     # View service logs
└── README.md
```

## Management Scripts

### Start the stack
```bash
./scripts/start.sh
```

### Stop the stack
```bash
./scripts/stop.sh
```

### Restart the stack
```bash
./scripts/restart.sh
```

### View logs
```bash
# All services
./scripts/logs.sh

# Specific service
./scripts/logs.sh prometheus
./scripts/logs.sh grafana
./scripts/logs.sh node-exporter
./scripts/logs.sh alertmanager
```

### Cleanup (removes all data)
```bash
./scripts/cleanup.sh
```

## Adding Remote Servers

To monitor remote servers, you need to:

### 1. Install node_exporter on remote servers

**On each remote server**, run:

```bash
# Download and install node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.7.0.linux-amd64*
```

**Create systemd service** (`/etc/systemd/system/node_exporter.service`):

```ini
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \
  --collector.filesystem.mount-points-exclude='^/(dev|proc|run|sys|mnt|media|tmp)($|/)' \
  --collector.netclass.ignored-devices='^(veth|docker|br-).*'

[Install]
WantedBy=multi-user.target
```

**Create user and start service**:

```bash
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```

**Verify it's running**:

```bash
curl http://localhost:9100/metrics
```

### 2. Configure Prometheus to scrape remote servers

Edit `prometheus/prometheus.yml` and add your servers under the `node-exporter-remote` job:

```yaml
  - job_name: 'node-exporter-remote'
    static_configs:
      - targets: ['192.168.1.100:9100']
        labels:
          instance: 'web-server-1'
          environment: 'production'
      - targets: ['192.168.1.101:9100']
        labels:
          instance: 'database-server'
          environment: 'production'
      - targets: ['10.0.0.50:9100']
        labels:
          instance: 'app-server-1'
          environment: 'staging'
```

### 3. Reload Prometheus configuration

```bash
# Reload without restart
curl -X POST http://localhost:9090/-/reload

# Or restart the stack
./scripts/restart.sh
```

### 4. Verify in Grafana

Go to the dashboard and you should see your new servers appearing in the graphs!

## Firewall Configuration

If you need to open ports on remote servers:

```bash
# Ubuntu/Debian with ufw
sudo ufw allow 9100/tcp

# CentOS/RHEL with firewalld
sudo firewall-cmd --permanent --add-port=9100/tcp
sudo firewall-cmd --reload
```

## Default Alerts

The system includes pre-configured alerts for:

- **High CPU Usage**: Warning at 80%, Critical at 95%
- **High Memory Usage**: Warning at 80%, Critical at 95%
- **Low Disk Space**: Warning at 20%, Critical at 10%
- **Instance Down**: Alert if server is unreachable for 2+ minutes
- **High Network Traffic**: Warning if receiving > 100 MB/s

## Configuring Alert Notifications

Edit `alertmanager/alertmanager.yml` to configure notifications:

### Email Notifications

```yaml
receivers:
  - name: 'default'
    email_configs:
      - to: 'admin@example.com'
        from: 'alertmanager@example.com'
        smarthost: 'smtp.example.com:587'
        auth_username: 'alertmanager@example.com'
        auth_password: 'your-password'
```

### Slack Notifications

```yaml
receivers:
  - name: 'default'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
        channel: '#alerts'
        title: 'Alert: {{ .GroupLabels.alertname }}'
```

After editing, restart the stack:

```bash
./scripts/restart.sh
```

## Accessing Services

- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **AlertManager**: http://localhost:9093
- **Node Exporter**: http://localhost:9100/metrics

## Customizing the Dashboard

The dashboard is auto-provisioned but can be edited in Grafana:

1. Go to the dashboard
2. Click the ⚙️ (Settings) icon
3. Make your changes
4. Click "Save Dashboard"

To make changes permanent, export the JSON and replace `grafana/provisioning/dashboards/server-monitoring.json`.

## Troubleshooting

### Services won't start

```bash
# Check Docker is running
docker info

# Check logs
./scripts/logs.sh

# Check port conflicts
netstat -tlnp | grep -E '3000|9090|9093|9100'
```

### Can't access Grafana

```bash
# Check if Grafana is running
docker ps | grep grafana

# Check Grafana logs
./scripts/logs.sh grafana
```

### Remote server not showing up

```bash
# Test connection to remote server
curl http://REMOTE_IP:9100/metrics

# Check Prometheus targets
# Go to http://localhost:9090/targets

# Reload Prometheus config
curl -X POST http://localhost:9090/-/reload
```

### Data retention

Prometheus keeps data for 30 days by default. To change this, edit `docker-compose.yml`:

```yaml
command:
  - '--storage.tsdb.retention.time=90d'  # Keep for 90 days
```

## Security Considerations

For production use:

1. **Change default passwords** (Grafana admin)
2. **Use HTTPS** with reverse proxy (nginx/traefik)
3. **Restrict access** with firewall rules
4. **Use authentication** for Prometheus/AlertManager
5. **Secure node_exporter** endpoints (firewall or VPN)

## Next Steps / Phase 2

This Phase 1 setup can be extended with:

- **Log aggregation** (Loki + Promtail)
- **Blackbox monitoring** (HTTP/HTTPS/TCP checks)
- **Custom application metrics**
- **Database monitoring** (PostgreSQL, MySQL exporters)
- **Docker monitoring** (cAdvisor)
- **NGINX monitoring** (NGINX exporter)

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Node Exporter Guide](https://github.com/prometheus/node_exporter)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)

## License

MIT License - Feel free to use and modify as needed.

## Support

For issues or questions, refer to the official documentation or create an issue in the repository.
