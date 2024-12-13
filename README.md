# Enhanced CDN Installation Script

An improved and modernized version of OneClickCDN, providing enterprise-grade CDN capabilities with advanced monitoring, security, and automation features.

## 🌐 What Is This?

This script creates CDN nodes that function similarly to Cloudflare's servers:
- Acts as an intermediary between clients and your origin server
- Caches content intelligently based on content type
- Provides automated SSL management
- Includes advanced monitoring and security features
- Supports multi-node deployment for global CDN coverage

## 🆕 Evolution from Original OneClickCDN

### Base Version (v0.1.0)
The original script provided:
- Basic Traffic Server installation
- Simple cache configuration
- Basic SSL management
- Limited error handling
- Manual monitoring

### Enhanced Version (v0.2.0)
The enhanced version introduces:

#### 💪 Core Improvements
- **Robust Error Handling**
  - Comprehensive error trapping
  - Detailed logging system
  - Graceful failure handling
  - System requirement validation

- **Security Hardening**
  - Secure default configurations
  - Enhanced SSL management
  - Security headers implementation
  - Proper permission handling
  - Secure compiler flags

- **Code Quality**
  - Modular architecture
  - Consistent coding style
  - Better documentation
  - Clear separation of concerns

#### 🚀 New Features

1. **Advanced Monitoring System**
   - Built-in Prometheus integration
   - Custom monitoring dashboard
   - Real-time performance metrics
   - Configurable alert thresholds
   - Historical data tracking

2. **Intelligent Cache Management**
   ```bash
   # Example of new cache rules
   ["images"]="jpg|jpeg|png|gif|webp:30d"
   ["static"]="css|js|woff|woff2:7d"
   ["api"]="json|xml:1h"
   ```
   - Dynamic cache sizing
   - Content-type based rules
   - Automatic optimization
   - Smart TTL management

3. **Automated SSL Management**
   - Certificate auto-renewal
   - SSL health monitoring
   - OCSP stapling
   - Backup and recovery

4. **Performance Optimization**
   ```bash
   # New kernel parameter optimizations
   net.core.somaxconn = 65536
   net.core.netdev_max_backlog = 65536
   net.ipv4.tcp_max_syn_backlog = 65536
   ```
   - Kernel tuning
   - Resource limit optimization
   - Network stack enhancements
   - System-level tweaks

## ⚠️ Important Prerequisites

### System Requirements
- **RAM**: 
  - 1.5GB for initial installation
  - 512MB minimum for running instance
  - SWAP recommended for low-RAM VPS during installation
- **CPU**: 1 core (2+ recommended)
- **Disk**: 20GB minimum
- **Network**: 1 IPv4 address
- **OS**: 
  - Ubuntu 20.04 LTS 64-bit (recommended)
  - Debian 10/11 64-bit
  - CentOS 7/8 64-bit

### ❌ Compatibility Warnings
Do NOT install any of the following as they are incompatible:
- Web servers (Apache, Nginx, LiteSpeed, Caddy)
- LAMP or LEMP stacks
- Admin panels (cPanel, DirectAdmin, BTcn, VestaCP)

### Special Notes
- CentOS 7: TLS 1.3 not supported due to OpenSSL version
- Fresh OS installation recommended
- Root access or sudo privileges required

## 📦 Installation

1. **Download the script**
   ```bash
   wget https://github.com/user/repo/raw/main/install-cdn.sh
   chmod +x install-cdn.sh
   ```

2. **Run the installation**
   ```bash
   sudo ./install-cdn.sh
   ```

3. **Configure options (optional)**
   ```bash
   # Enable all features
   export ENABLE_MONITORING=true
   export AUTO_SSL_RENEWAL=true
   export ENABLE_BROTLI=true
   ```

### Uninstallation
To completely remove the CDN and Traffic Server:
```bash
wget https://raw.githubusercontent.com/user/repo/master/uninstall.sh
sudo bash uninstall.sh
```

## 🌍 Building a CDN Cluster

Create a global CDN network by:
1. Running this script on multiple servers in different locations
2. Using GeoDNS with round robin/failover for traffic distribution
3. Managing configurations across nodes with the backup/restore feature

### Multi-Node Deployment
```bash
# On first node
./install-cdn.sh --backup config.tar.gz

# On other nodes
./install-cdn.sh --restore config.tar.gz
```

## ⚙️ Configuration

### Basic Configuration
```bash
# Set cache sizes
CONFIG proxy.config.cache.ram_cache.size INT 4096M
CONFIG proxy.config.cache.ram_cache_cutoff INT 4194304
```

### Advanced Features
```bash
# Enable HTTP/3
CONFIG proxy.config.http3.enabled INT 1

# Configure monitoring
CONFIG proxy.config.metrics.enabled INT 1
CONFIG proxy.config.metrics.port INT 9999
```

## 🔍 Monitoring

### Dashboard Access
- URL: http://localhost:9999/dashboard
- Metrics refresh: Every 30 seconds
- Historical data: 30 days

### Alert Thresholds
```bash
["cache_hit_ratio"]=85
["response_time"]=500
["error_rate"]=5
["disk_usage"]=90
```

## 🛡️ Security Features

1. **Headers**
   - HSTS
   - X-Content-Type-Options
   - X-Frame-Options
   - Content Security Policy

2. **SSL/TLS**
   - Auto-renewal
   - OCSP stapling
   - Modern cipher suites
   - Perfect forward secrecy

3. **Access Control**
   - Least privilege principle
   - Secure file permissions
   - Resource isolation

## 📊 Performance Tuning

### Cache Optimization
- Dynamic sizing
- Content-type rules
- Access pattern analysis
- Intelligent purging

### System Tuning
- Network stack optimization
- Kernel parameters
- Resource limits
- I/O optimization

## 🔄 Backup & Recovery

### Automatic Backups
```bash
# Create backup
./install-cdn.sh --backup config.tar.gz

# Restore from backup
./install-cdn.sh --restore config.tar.gz

# Quick recovery
./install-cdn.sh --quick-restore latest
```

## 📝 Logging

### Enhanced Logging System
```bash
# Example log output
[2024-01-01 12:00:00] [INFO] Cache optimization complete
[2024-01-01 12:00:01] [SUCCESS] SSL certificates renewed
```

## 🔧 Troubleshooting

### Common Issues
1. **Installation Fails**
   - Check RAM availability
   - Verify OS compatibility
   - Ensure clean installation

2. **SSL Issues**
   - Verify domain DNS
   - Check certificate paths
   - Confirm renewal permissions

3. **Performance Issues**
   - Review monitoring dashboard
   - Check cache hit ratio
   - Verify network configuration

## 🤝 Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Original OneClickCDN author: shc (https://qing.su)
- Traffic Server community
- All contributors

## 📞 Support

For support:
1. Open an issue on GitHub
2. Check the troubleshooting guide
3. Review the monitoring dashboard
4. Contact the maintainers

## 🔄 Version History

- v0.2.0 - Enhanced version with monitoring, security, and automation
- v0.1.0 - Original OneClickCDN script
