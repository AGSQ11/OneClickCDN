# Enhanced OneClickCDN

An improved and modernized version of OneClickCDN, providing enterprise-grade CDN capabilities with advanced monitoring, security, and automation features. This script allows you to quickly set up and manage CDN nodes using Apache Traffic Server.

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

#### 🚀 New Features

1. **Advanced Monitoring System**
   - Built-in Prometheus integration
   - Custom monitoring dashboard
   - Real-time performance metrics
   - Configurable alert thresholds

2. **Intelligent Cache Management**
   ```bash
   # Example of new cache rules
   ["images"]="jpg|jpeg|png|gif|webp:30d"
   ["static"]="css|js|woff|woff2:7d"
   ["api"]="json|xml:1h"
   ```

3. **Automated SSL Management**
   - Certificate auto-renewal
   - SSL health monitoring
   - OCSP stapling
   - Backup and recovery

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
   wget https://raw.githubusercontent.com/AGSQ11/OneClickCDN/master/OneClickCDN.sh && sudo bash OneClickCDN.sh
   ```

2. **Access menu (after installation)**
   ```bash
   sudo bash OneClickCDN.sh
   ```

3. **Uninstallation**
   ```bash
   wget https://raw.githubusercontent.com/AGSQ11/OneClickCDN/master/uninstall.sh && sudo bash uninstall.sh
   ```

## 🌍 Building a CDN Cluster

Create a global CDN network by:
1. Running this script on multiple servers in different locations
2. Using GeoDNS with round robin/failover for traffic distribution
3. Managing configurations across nodes with the backup/restore feature

## ⚙️ Key Features

### SSL Management
- Support for custom SSL certificates
- Free Let's Encrypt SSL integration
- Automated certificate management
- SSL health monitoring

### Cache Management
- Intelligent content caching
- Cache purging capabilities
- Dynamic cache optimization
- Content-type based rules

### Monitoring & Maintenance
- Performance metrics tracking
- Health monitoring
- Automated backups
- Easy configuration management

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
   - Review cache settings
   - Check origin server connectivity
   - Verify network configuration

## 📜 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Original OneClickCDN author: shc (https://qing.su)
- Traffic Server community
- All contributors

## 📞 Support

For support:
1. Open an issue on [GitHub](https://github.com/AGSQ11/OneClickCDN/issues)
2. Check the troubleshooting guide
3. Review previous issues

## 🔄 Version History

- v0.2.0 - Enhanced version with monitoring, security, and automation
- v0.1.0 - Original OneClickCDN script

## Update Log

|Date|Version|Changes|
|---|---|---|
|07/19/2020|v0.0.1|Script created|
|07/20/2020|v0.0.2|Add Debian 10 support; add systemd service|
|07/21/2020|v0.0.3|Add CentOS 7/8 support; add uninstall script|
|07/25/2020|v0.0.4|Add function to remove website; fix bugs; add colored display|
|07/28/2020|v0.0.5|Add function to purge cache by URLs; fix bugs and typos|
|12/12/2021|v0.1.0|Add Debian 11 support; add backup and restore function|
|Current|v0.2.0|Enhanced version with monitoring, security, and automation|
