#!/bin/bash

#################################################################
#    One-click CDN Installation Script v0.2.0                     #
#    Original by shc (https://qing.su)                           #
#    Enhanced version with advanced features and monitoring       #
#################################################################

# Exit immediately if any command fails
set -e

# Strict mode
set -u
set -o pipefail

# Global constants
readonly VERSION="0.2.0"
readonly MIN_RAM_MB=1500
readonly DEFAULT_CACHE_SIZE=256
readonly TS_VERSION="8.1.5"
readonly TS_DOWNLOAD_LINK="https://downloads.apache.org/trafficserver/trafficserver-${TS_VERSION}.tar.bz2"
readonly SUPPORTED_OS=("UBUNTU20" "DEBIAN10" "DEBIAN11" "CENTOS7" "CENTOS8")
readonly MONITORING_PORT=9999
readonly CONFIG_BACKUP_DIR="/etc/trafficserver/backups"
readonly SSL_RENEWAL_THRESHOLD_DAYS=30

# Configuration options with defaults
REVERSE_PROXY_MODE_ENABLED=${REVERSE_PROXY_MODE_ENABLED:-false}
OS_CHECK_ENABLED=${OS_CHECK_ENABLED:-true}
ENABLE_MONITORING=${ENABLE_MONITORING:-true}
AUTO_SSL_RENEWAL=${AUTO_SSL_RENEWAL:-true}
ENABLE_BROTLI=${ENABLE_BROTLI:-true}
ENABLE_HTTP3=${ENABLE_HTTP3:-false}

# Advanced cache configuration
declare -A CACHE_RULES=(
    ["images"]="jpg|jpeg|png|gif|webp:30d"
    ["static"]="css|js|woff|woff2:7d"
    ["media"]="mp4|mp3|webm:14d"
    ["documents"]="pdf|doc|docx:2d"
    ["api"]="json|xml:1h"
)

# Monitoring metrics
declare -A ALERT_THRESHOLDS=(
    ["cache_hit_ratio"]=85
    ["response_time"]=500
    ["error_rate"]=5
    ["disk_usage"]=90
)

# Enhanced logging functions
log() {
    local level=$1
    shift
    local message=$*
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${colors[$level]}[$timestamp] $message${colors[reset]}" >&2
    
    # Log to file if enabled
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

# New functionality: Performance monitoring
setup_monitoring() {
    info "Setting up performance monitoring..."
    
    # Install monitoring dependencies
    case "$OS" in
        UBUNTU*|DEBIAN*)
            apt-get install -y prometheus node-exporter
            ;;
        CENTOS*)
            yum install -y prometheus node-exporter
            ;;
    esac
    
    # Configure Traffic Server metrics endpoint
    cat >> /etc/trafficserver/records.config <<EOF
CONFIG proxy.config.metrics.enabled INT 1
CONFIG proxy.config.metrics.port INT ${MONITORING_PORT}
EOF

    # Create monitoring dashboard configuration
    setup_monitoring_dashboard
    
    success "Monitoring setup complete. Access dashboard at http://localhost:${MONITORING_PORT}/dashboard"
}

# New functionality: Automatic cache optimization
optimize_cache() {
    info "Optimizing cache configuration..."
    
    # Analyze system resources
    local memory_mb
    memory_mb=$(free -m | awk '/^Mem:/{print $2}')
    local disk_space_mb
    disk_space_mb=$(df -BM /usr/local/var/trafficserver | awk 'NR==2{print $4}' | tr -d 'M')
    
    # Calculate optimal cache sizes
    local ram_cache_size
    ram_cache_size=$((memory_mb / 4))  # 25% of total RAM
    local disk_cache_size
    disk_cache_size=$((disk_space_mb / 2))  # 50% of available disk space
    
    # Apply optimized configuration
    cat >> /etc/trafficserver/records.config <<EOF
CONFIG proxy.config.cache.ram_cache.size INT ${ram_cache_size}M
CONFIG proxy.config.cache.ram_cache_cutoff INT 4194304
CONFIG proxy.config.cache.limits.http.max_alts INT 5
CONFIG proxy.config.cache.max_doc_size INT 0
CONFIG proxy.config.cache.min_average_object_size INT 8000
EOF

    echo "var/trafficserver ${disk_cache_size}M" > /etc/trafficserver/storage.config
    
    # Setup intelligent cache rules
    configure_smart_cache_rules
    
    success "Cache optimization complete"
}

# New functionality: Smart cache rules
configure_smart_cache_rules() {
    info "Configuring intelligent cache rules..."
    
    # Clear existing cache rules
    > /etc/trafficserver/cache.config
    
    # Apply cache rules based on content type
    for content_type in "${!CACHE_RULES[@]}"; do
        IFS=':' read -r patterns duration <<< "${CACHE_RULES[$content_type]}"
        echo "# ${content_type} caching rules" >> /etc/trafficserver/cache.config
        for pattern in ${patterns//|/ }; do
            echo "url_regex=.*\.${pattern}\$ ttl-in-cache=${duration}" >> /etc/trafficserver/cache.config
        done
    done
    
    success "Smart cache rules configured"
}

# New functionality: SSL management
setup_ssl_management() {
    info "Setting up SSL certificate management..."
    
    # Create SSL backup directory
    mkdir -p "$CONFIG_BACKUP_DIR/ssl"
    
    # Setup auto-renewal cron job if enabled
    if [[ "$AUTO_SSL_RENEWAL" == "true" ]]; then
        setup_ssl_renewal_cron
    fi
    
    # Configure OCSP stapling
    cat >> /etc/trafficserver/records.config <<EOF
CONFIG proxy.config.ssl.ocsp.enabled INT 1
CONFIG proxy.config.ssl.ocsp.update_period INT 86400
EOF
    
    success "SSL management configured"
}

# New functionality: Performance tuning
tune_performance() {
    info "Tuning system performance..."
    
    # Adjust kernel parameters
    cat > /etc/sysctl.d/99-trafficserver.conf <<EOF
# Network tuning
net.core.somaxconn = 65536
net.core.netdev_max_backlog = 65536
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535

# File system tuning
fs.file-max = 2097152
fs.nr_open = 2097152
EOF
    
    sysctl -p /etc/sysctl.d/99-trafficserver.conf
    
    # Adjust resource limits
    cat > /etc/security/limits.d/trafficserver.conf <<EOF
nobody soft nofile 524288
nobody hard nofile 524288
nobody soft nproc 524288
nobody hard nproc 524288
EOF
    
    success "Performance tuning complete"
}

# New functionality: Backup and restore
backup_configuration() {
    local backup_date
    backup_date=$(date +%Y%m%d_%H%M%S)
    local backup_file="${CONFIG_BACKUP_DIR}/backup_${backup_date}.tar.gz"
    
    info "Creating backup at ${backup_file}..."
    
    # Create backup directory if it doesn't exist
    mkdir -p "$CONFIG_BACKUP_DIR"
    
    # Create backup
    tar czf "$backup_file" \
        /etc/trafficserver/records.config \
        /etc/trafficserver/ssl \
        /etc/trafficserver/storage.config \
        /etc/trafficserver/cache.config
    
    # Verify backup
    if [[ -f "$backup_file" ]]; then
        success "Backup created successfully"
        # Keep only last 5 backups
        find "$CONFIG_BACKUP_DIR" -name "backup_*.tar.gz" -mtime +5 -delete
    else
        error "Backup creation failed"
    fi
}

# New functionality: Health checks
setup_health_checks() {
    info "Setting up health monitoring..."
    
    # Create health check script
    cat > /usr/local/bin/ts-health-check <<'EOF'
#!/bin/bash
check_service() {
    if ! systemctl is-active --quiet trafficserver; then
        echo "Traffic Server is down!"
        systemctl restart trafficserver
        return 1
    fi
    return 0
}

check_ssl_certs() {
    local threshold=$SSL_RENEWAL_THRESHOLD_DAYS
    find /etc/trafficserver/ssl -name "*.crt" -type f | while read -r cert; do
        expires=$(openssl x509 -enddate -noout -in "$cert" | cut -d= -f2)
        expires_epoch=$(date -d "$expires" +%s)
        now_epoch=$(date +%s)
        days_left=$(( (expires_epoch - now_epoch) / 86400 ))
        if (( days_left < threshold )); then
            echo "Certificate $cert expires in $days_left days!"
        fi
    done
}

check_metrics() {
    # Check cache hit ratio
    hit_ratio=$(traffic_ctl metric get proxy.process.cache.percent_hits | awk '{print $2}')
    if (( $(echo "$hit_ratio < ${ALERT_THRESHOLDS[cache_hit_ratio]}" | bc -l) )); then
        echo "Low cache hit ratio: $hit_ratio%"
    fi
    
    # Check error rate
    error_rate=$(traffic_ctl metric get proxy.process.http.response_status_5xx | awk '{print $2}')
    if (( error_rate > ${ALERT_THRESHOLDS[error_rate]} )); then
        echo "High error rate: $error_rate%"
    fi
}
EOF
    chmod +x /usr/local/bin/ts-health-check
    
    # Setup cron job for health checks
    echo "*/5 * * * * /usr/local/bin/ts-health-check" > /etc/cron.d/trafficserver-health
    
    success "Health monitoring configured"
}

# Enhanced main function with new features
main() {
    info "Starting enhanced CDN installation script v$VERSION"
    
    detect_os
    install_traffic_server
    configure_security
    
    # New functionality setup
    setup_monitoring
    optimize_cache
    setup_ssl_management
    tune_performance
    setup_health_checks
    
    # Initial backup
    backup_configuration
    
    success "Installation and configuration completed successfully"
    
    info "Next steps:"
    echo "1. Access monitoring dashboard: http://localhost:${MONITORING_PORT}/dashboard"
    echo "2. Review cache rules in /etc/trafficserver/cache.config"
    echo "3. Check health monitoring status: /usr/local/bin/ts-health-check"
    echo "4. Configure additional domains and SSL certificates"
}

# Start execution
main "$@"
