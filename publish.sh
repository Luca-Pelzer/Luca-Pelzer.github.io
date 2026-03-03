#!/bin/bash
#
# Hugo Blog Publish Script
# Location: /var/www/engels-blog/publish.sh
#
# Usage:
#   ./publish.sh          - Build the site with minification
#   ./publish.sh server   - Start Hugo server for live preview
#   ./publish.sh restart  - Restart Hugo server if running
#   ./publish.sh status   - Check Hugo server status
#

set -e

HUGO_BIN="/usr/local/bin/hugo"
SITE_DIR="/var/www/engels-blog"
PUBLIC_DIR="${SITE_DIR}/public"
SERVICE_NAME="hugo-server"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Build the Hugo site with minification
build_site() {
    log_info "Building Hugo site with minification..."
    cd "${SITE_DIR}"
    
    # Clean public directory
    if [ -d "${PUBLIC_DIR}" ]; then
        log_info "Cleaning existing public directory..."
        rm -rf "${PUBLIC_DIR}"
    fi
    
    # Build with minification
    if "${HUGO_BIN}" --minify; then
        log_success "Site built successfully!"
        
        # Show build stats
        local page_count=$(find "${PUBLIC_DIR}" -name "*.html" | wc -l)
        local total_size=$(du -sh "${PUBLIC_DIR}" | cut -f1)
        
        echo ""
        log_info "Build Statistics:"
        echo "  - HTML pages: ${page_count}"
        echo "  - Total size: ${total_size}"
        echo "  - Output dir: ${PUBLIC_DIR}"
        
        return 0
    else
        log_error "Build failed! Check the errors above."
        return 1
    fi
}

# Start Hugo server for live preview
start_server() {
    log_info "Starting Hugo server for live preview..."
    cd "${SITE_DIR}"
    
    # Check if systemd service is running
    if systemctl is-active --quiet "${SERVICE_NAME}" 2>/dev/null; then
        log_warning "Hugo server is already running as a systemd service."
        log_info "Use 'systemctl status ${SERVICE_NAME}' to check status."
        log_info "Use './publish.sh restart' to restart the server."
        return 0
    fi
    
    log_info "Starting Hugo server on http://0.0.0.0:1313"
    log_info "Press Ctrl+C to stop the server."
    echo ""
    
    "${HUGO_BIN}" server \
        --bind 0.0.0.0 \
        --port 1313 \
        --baseURL "http://localhost:1313" \
        --disableFastRender \
        --navigateToChanged
}

# Restart Hugo server (systemd service)
restart_server() {
    log_info "Restarting Hugo server..."
    
    if systemctl is-active --quiet "${SERVICE_NAME}" 2>/dev/null; then
        systemctl restart "${SERVICE_NAME}"
        log_success "Hugo server restarted."
        systemctl status "${SERVICE_NAME}" --no-pager
    else
        log_warning "Hugo server systemd service is not running."
        log_info "Starting the service..."
        systemctl start "${SERVICE_NAME}"
        log_success "Hugo server started."
    fi
}

# Check Hugo server status
check_status() {
    log_info "Checking Hugo server status..."
    
    if systemctl is-active --quiet "${SERVICE_NAME}" 2>/dev/null; then
        log_success "Hugo server is running."
        systemctl status "${SERVICE_NAME}" --no-pager
    else
        log_warning "Hugo server is not running."
        log_info "Start with: systemctl start ${SERVICE_NAME}"
        log_info "Or run: ./publish.sh server"
    fi
}

# Show usage
show_usage() {
    echo "Hugo Blog Publish Script"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  (none)    Build the site with minification (default)"
    echo "  server    Start Hugo server for live preview (port 1313)"
    echo "  restart   Restart Hugo server systemd service"
    echo "  status    Check Hugo server status"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./publish.sh           # Build the site"
    echo "  ./publish.sh server    # Start live preview server"
    echo "  ./publish.sh restart   # Restart the systemd service"
}

# Main
case "${1:-build}" in
    build|"" )
        build_site
        ;;
    server)
        start_server
        ;;
    restart)
        restart_server
        ;;
    status)
        check_status
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        log_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
