#!/usr/bin/env bash
# ==============================================================================
# CrowdSec Monitoring Script
# ==============================================================================
# Purpose: Check CrowdSec health and security status
# Usage: ./monitor-crowdsec.sh [--json|--quiet|--alerts]
# Part of NIST Hardening Suite
# ==============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
CSCLI_PATH="cscli"  # Will be found via PATH
CROWD_SEC_SERVICE="crowdsec"
BOUNCER_SERVICE="crowdsec-firewall-bouncer"
LOG_FILE="/var/log/crowdsec.log"
MAX_ALERTS_AGE_HOURS=24

# Functions
print_status() {
    local status=$1
    local message=$2
    
    case "$status" in
        "OK")
            echo -e "${GREEN}✅ ${message}${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  ${message}${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ ${message}${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  ${message}${NC}"
            ;;
    esac
}

check_service() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        print_status "OK" "Service $service is running"
        return 0
    else
        print_status "ERROR" "Service $service is not running"
        return 1
    fi
}

check_cscli() {
    if command -v "$CSCLI_PATH" &> /dev/null; then
        print_status "OK" "cscli is available"
        return 0
    else
        print_status "ERROR" "cscli not found"
        return 1
    fi
}

check_alerts() {
    local alerts_count
    alerts_count=$($CSCLI_PATH alerts list -o json 2>/dev/null | jq '. | length' 2>/dev/null || echo "0")
    
    if [[ "$alerts_count" -gt 0 ]]; then
        print_status "WARNING" "Found $alerts_count active security alert(s)"
        
        if [[ "${SHOW_ALERTS:-false}" == "true" ]]; then
            echo -e "\n${YELLOW}Recent alerts:${NC}"
            $CSCLI_PATH alerts list --since 24h
        fi
    else
        print_status "OK" "No active security alerts"
    fi
}

check_bouncer() {
    local bouncers
    bouncers=$($CSCLI_PATH bouncers list 2>/dev/null | grep -c "firewall-bouncer" || echo "0")
    
    if [[ "$bouncers" -gt 0 ]]; then
        print_status "OK" "Firewall bouncer is registered"
    else
        print_status "WARNING" "Firewall bouncer not registered"
    fi
}

check_collections() {
    local collections
    collections=$($CSCLI_PATH collections list 2>/dev/null | grep -c "crowdsecurity/linux" || echo "0")
    
    if [[ "$collections" -gt 0 ]]; then
        print_status "OK" "Security collections installed"
    else
        print_status "WARNING" "No security collections installed"
    fi
}

check_decisions() {
    local decisions_count
    decisions_count=$($CSCLI_PATH decisions list -o json 2>/dev/null | jq '. | length' 2>/dev/null || echo "0")
    
    if [[ "$decisions_count" -gt 0 ]]; then
        print_status "INFO" "Active decisions: $decisions_count (blocked IPs)"
    else
        print_status "OK" "No active blocking decisions"
    fi
}

check_metrics() {
    local metrics_port=6060
    if curl -s --max-time 5 "http://localhost:$metrics_port/metrics" &> /dev/null; then
        print_status "OK" "Metrics endpoint is accessible"
    else
        print_status "WARNING" "Metrics endpoint not accessible"
    fi
}

check_logs() {
    if [[ -f "$LOG_FILE" ]]; then
        local recent_errors
        recent_errors=$(grep -c "error\|ERROR" "$LOG_FILE" 2>/dev/null | tail -100 || echo "0")
        
        if [[ "$recent_errors" -gt 0 ]]; then
            print_status "WARNING" "Found $recent_errors error(s) in recent logs"
        else
            print_status "OK" "No recent errors in logs"
        fi
    else
        print_status "WARNING" "Log file not found: $LOG_FILE"
    fi
}

generate_report() {
    echo -e "\n${BLUE}=== CrowdSec Security Report ===${NC}"
    echo "Date: $(date)"
    echo "Host: $(hostname)"
    echo "IP: $(hostname -I 2>/dev/null | head -1 || echo 'N/A')"
    echo ""
    
    check_cscli
    check_service "$CROWD_SEC_SERVICE"
    check_service "$BOUNCER_SERVICE"
    check_bouncer
    check_collections
    check_alerts
    check_decisions
    check_metrics
    check_logs
}

generate_json_report() {
    $CSCLI_PATH status -o json 2>/dev/null || echo '{"error": "cscli not available"}'
}

show_usage() {
    cat << EOF
CrowdSec Monitoring Script - NIST Hardening Suite

Usage: $0 [OPTION]

Options:
  --json       Output JSON format (for monitoring integrations)
  --quiet      Only output errors and warnings
  --alerts     Show detailed alert information
  --status     Show cscli status (default)
  --help       Show this help message

Examples:
  $0                     # Full status report
  $0 --json              # JSON output for monitoring systems
  $0 --alerts            # Show detailed alerts


EOF
}

# Main execution
main() {
    local mode="report"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --json)
                generate_json_report
                exit 0
                ;;
            --quiet)
                exec 2>/dev/null
                mode="quiet"
                ;;
            --alerts)
                SHOW_ALERTS=true
                ;;
            --status)
                mode="report"
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
        shift
    done
    
    case "$mode" in
        "report")
            generate_report
            ;;
        "quiet")
            generate_report > /dev/null
            ;;
    esac
    
    echo -e "\n${BLUE}=== Monitoring Complete ===${NC}"
    echo "Monitoring complete. Refer to project documentation for extended monitoring options."
}

# Run main
main "$@"