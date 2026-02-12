#!/usr/bin/env bash
# ==============================================================================
# NIST Hardening Suite - Bootstrap Script
# ==============================================================================
# Purpose: Quick setup and validation for the NIST Hardening Suite
# Usage: ./setup.sh [--install|--validate|--help]
# ==============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_NAME="nist-hardening-suite"
REPO_URL="https://github.com/Miguel-DevOps/nist-hardening-suite.git"
ANSIBLE_MIN_VERSION="2.16"
PYTHON_MIN_VERSION="3.12"

# Functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Python
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        if [[ $(echo "$PYTHON_VERSION >= $PYTHON_MIN_VERSION" | bc -l 2>/dev/null) -eq 1 ]]; then
            print_success "Python $PYTHON_VERSION (>= $PYTHON_MIN_VERSION required)"
        else
            print_error "Python $PYTHON_VERSION found, but $PYTHON_MIN_VERSION+ required"
            return 1
        fi
    else
        print_error "Python3 not found"
        return 1
    fi
    
    # Check Ansible
    if command -v ansible &> /dev/null; then
        ANSIBLE_VERSION=$(ansible --version | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
        if [[ $(echo "$ANSIBLE_VERSION >= $ANSIBLE_MIN_VERSION" | bc -l 2>/dev/null) -eq 1 ]]; then
            print_success "Ansible $ANSIBLE_VERSION (>= $ANSIBLE_MIN_VERSION required)"
        else
            print_error "Ansible $ANSIBLE_VERSION found, but $ANSIBLE_MIN_VERSION+ required"
            return 1
        fi
    else
        print_warning "Ansible not found. Attempting to install..."
        install_ansible
    fi
    
    # Check ansible-vault
    if command -v ansible-vault &> /dev/null; then
        print_success "ansible-vault available"
    else
        print_error "ansible-vault not found (part of ansible-core)"
        return 1
    fi
    
    # Check SSH
    if [[ -f "$HOME/.ssh/id_ed25519" || -f "$HOME/.ssh/id_rsa" ]]; then
        print_success "SSH key found"
    else
        print_warning "No SSH key found in ~/.ssh/"
        print_info "Generate one with: ssh-keygen -t ed25519"
    fi
    
    print_success "All prerequisites satisfied"
}

install_ansible() {
    print_header "Installing Ansible"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            sudo apt update
            sudo apt install -y python3-pip
            pip3 install ansible-core==2.16.*
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3-pip
            pip3 install ansible-core==2.16.*
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y python3-pip
            pip3 install ansible-core==2.16.*
        else
            print_error "Unsupported package manager. Install ansible-core manually:"
            print_info "pip3 install ansible-core==2.16.*"
            return 1
        fi
    else
        print_error "Unsupported OS. Install ansible-core manually:"
        print_info "pip3 install ansible-core==2.16.*"
        return 1
    fi
    
    if command -v ansible &> /dev/null; then
        print_success "Ansible installed successfully"
    else
        print_error "Ansible installation failed"
        return 1
    fi
}

install_collections() {
    print_header "Installing Ansible Collections"
    
    if [[ -f "requirements.yml" ]]; then
        ansible-galaxy collection install -r requirements.yml
        print_success "Ansible collections installed"
    else
        print_error "requirements.yml not found"
        return 1
    fi
}

validate_inventory() {
    print_header "Validating Inventory"
    
    if [[ -f "inventory/hosts.ini" ]]; then
        print_success "inventory/hosts.ini exists"
        
        # Check for placeholder IPs
        if grep -q "100\.100\.100\|203\.0\.113" inventory/hosts.ini; then
            print_warning "Inventory contains placeholder IP addresses"
            print_info "Edit inventory/hosts.ini with your actual server IPs"
        fi
    else
        print_warning "inventory/hosts.ini not found"
        print_info "Copy the example: cp inventory/hosts.ini.example inventory/hosts.ini"
        print_info "Then edit with your server details"
    fi
}

setup_secrets() {
    print_header "Setting Up Encrypted Secrets"
    
    if [[ -f "group_vars/all/secrets.yml" ]]; then
        print_success "secrets.yml already exists"
        print_info "To edit: ansible-vault edit group_vars/all/secrets.yml"
        return 0
    fi
    
    if [[ -f "group_vars/all/secrets.yml.example" ]]; then
        print_info "Copying example secrets file..."
        cp group_vars/all/secrets.yml.example group_vars/all/secrets.yml
        
        print_warning "Secrets file created but NOT encrypted"
        print_info "To encrypt: ansible-vault encrypt group_vars/all/secrets.yml"
        print_info "Required secrets:"
        echo "  - vault_github_token (GitHub Personal Access Token)"
        echo "  - tailscale_auth_key (Tailscale auth key)"
        echo "  - docker_version_map (Docker version mapping)"
    else
        print_error "secrets.yml.example not found"
        return 1
    fi
}

validate_playbooks() {
    print_header "Validating Ansible Playbooks"
    
    if [[ -f "site.yml" ]]; then
        ansible-playbook site.yml --syntax-check
        print_success "site.yml syntax valid"
    else
        print_error "site.yml not found"
        return 1
    fi
    
    if [[ -f "stacks.yml" ]]; then
        ansible-playbook stacks.yml --syntax-check
        print_success "stacks.yml syntax valid"
    else
        print_warning "stacks.yml not found (optional)"
    fi
}

show_next_steps() {
    print_header "Next Steps"
    
    echo -e "${GREEN}1.${NC} Edit inventory/hosts.ini with your server IPs"
    echo -e "${GREEN}2.${NC} Configure secrets:"
    echo -e "   ${BLUE}ansible-vault edit group_vars/all/secrets.yml${NC}"
    echo -e "${GREEN}3.${NC} Run full hardening:"
    echo -e "   ${BLUE}ansible-playbook -i inventory/hosts.ini site.yml --ask-vault-pass${NC}"
    echo -e "${GREEN}4.${NC} Deploy applications:"
    echo -e "   ${BLUE}ansible-playbook -i inventory/hosts.ini stacks.yml --ask-vault-pass${NC}"
    echo -e "\n${YELLOW}Need help?${NC}"
    echo -e "📚 Documentation: https://github.com/Miguel-DevOps/nist-hardening-suite"
    echo -e "💼 Professional services: See documentation for details."
}

run_validation() {
    print_header "Running Complete Validation"
    
    check_prerequisites
    install_collections
    validate_inventory
    setup_secrets
    validate_playbooks
    
    print_success "Validation complete!"
    show_next_steps
}

show_help() {
    cat << EOF
NIST Hardening Suite - Bootstrap Script

Usage: ./setup.sh [OPTION]

Options:
  --install    Install prerequisites and collections
  --validate   Run complete validation (default)
  --help       Show this help message

Examples:
  ./setup.sh --install   # Install Ansible and collections
  ./setup.sh --validate  # Validate setup and show next steps
  ./setup.sh             # Same as --validate

Environment:
  This script sets up the NIST Hardening Suite for first use.
  It checks prerequisites, installs dependencies, and validates configuration.

Business Model:
  The hardening script is FREE (MIT licensed).
  Extended monitoring and compliance auditing services available.
EOF
}

# Main execution
main() {
    local mode="validate"
    
    # Parse arguments
    if [[ $# -gt 0 ]]; then
        case "$1" in
            --install)
                mode="install"
                ;;
            --validate)
                mode="validate"
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    fi
    
    print_header "NIST Hardening Suite Bootstrap"
    print_info "Mode: $mode"
    print_info "Repository: $REPO_NAME"
    print_info "Business Model: Open Source Code, Optional Monitoring Services"
    echo ""
    
    case "$mode" in
        install)
            check_prerequisites
            install_collections
            print_success "Installation complete!"
            ;;
        validate)
            run_validation
            ;;
    esac
    
    echo -e "\n${GREEN}=== Bootstrap Complete ===${NC}"
}

# Run main function with all arguments
main "$@"