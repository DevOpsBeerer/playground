#!/bin/bash
#
# Script to get Load Balancer IP and generate DNS records for DevOpsBeerer playground
# This script only displays the DNS records - it does NOT create them automatically
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
KUBECONFIG_PATH="/etc/rancher/k3s/k3s.yaml"
INGRESS_NAMESPACE="ingress-nginx"
INGRESS_SERVICE="ingress-nginx-controller"

echo -e "${BOLD}${BLUE}=== DevOpsBeerer DNS Records Generator ===${NC}\n"

# Check if k3s is running
if ! systemctl is-active --quiet k3s; then
    echo -e "${RED}Error: K3s is not running. Please start k3s first.${NC}"
    echo "Run: sudo systemctl start k3s"
    exit 1
fi

# Check if kubeconfig exists
if [ ! -f "$KUBECONFIG_PATH" ]; then
    echo -e "${RED}Error: Kubeconfig not found at $KUBECONFIG_PATH${NC}"
    exit 1
fi

echo -e "${YELLOW}Retrieving Load Balancer IP...${NC}"

# Get the load balancer IP
LB_IP=""
EXTERNAL_IP=""

# Try to get external IP from ingress controller service
EXTERNAL_IP=$(k3s kubectl get service $INGRESS_SERVICE -n $INGRESS_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

# If no external IP, try to get node IP (for NodePort services)
if [ -z "$EXTERNAL_IP" ] || [ "$EXTERNAL_IP" = "null" ]; then
    echo -e "${YELLOW}No external LoadBalancer IP found, checking for NodePort...${NC}"

    # Get node IP
    NODE_IP=$(k3s kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}' 2>/dev/null || echo "")

    if [ -n "$NODE_IP" ]; then
        EXTERNAL_IP="$NODE_IP"
        echo -e "${YELLOW}Using Node IP: $EXTERNAL_IP${NC}"
    fi
fi

# If still no IP, try localhost
if [ -z "$EXTERNAL_IP" ] || [ "$EXTERNAL_IP" = "null" ]; then
    echo -e "${YELLOW}No external IP found, using localhost (127.0.0.1)${NC}"
    EXTERNAL_IP="127.0.0.1"
fi

LB_IP="$EXTERNAL_IP"

echo -e "${GREEN}Load Balancer IP: $LB_IP${NC}\n"

# Get all ingress hostnames
echo -e "${YELLOW}Retrieving ingress hostnames...${NC}"

HOSTNAMES=$(k3s kubectl get ingress --all-namespaces -o jsonpath='{range .items[*]}{.spec.rules[*].host}{"\n"}{end}' 2>/dev/null | sort -u | grep -v '^$' || echo "")

if [ -z "$HOSTNAMES" ]; then
    echo -e "${YELLOW}No ingress hostnames found, using default DevOpsBeerer domains...${NC}"
    HOSTNAMES="sso.devopsbeerer.local
api.devopsbeerer.local
devopsbeerer.local
admin.devopsbeerer.local"
fi

echo -e "${BLUE}Found hostnames:${NC}"
echo "$HOSTNAMES" | while read -r hostname; do
    if [ -n "$hostname" ]; then
        echo "  - $hostname"
    fi
done

echo ""

# Generate DNS records
echo -e "${BOLD}${GREEN}=== DNS Records to Add ===${NC}\n"

echo -e "${BOLD}For /etc/hosts (Linux/Mac):${NC}"
echo "# DevOpsBeerer Playground - Add these lines to /etc/hosts"
echo "$HOSTNAMES" | while read -r hostname; do
    if [ -n "$hostname" ]; then
        echo "$LB_IP $hostname"
    fi
done

echo ""

echo -e "${BOLD}For Windows hosts file (C:\\Windows\\System32\\drivers\\etc\\hosts):${NC}"
echo "# DevOpsBeerer Playground - Add these lines to hosts file"
echo "$HOSTNAMES" | while read -r hostname; do
    if [ -n "$hostname" ]; then
        echo "$LB_IP $hostname"
    fi
done

echo ""

echo -e "${BOLD}For DNS Server (BIND format):${NC}"
echo "; DevOpsBeerer Playground DNS Records"
echo "$HOSTNAMES" | while read -r hostname; do
    if [ -n "$hostname" ]; then
        # Extract subdomain and domain
        if [[ "$hostname" == *.* ]]; then
            subdomain=$(echo "$hostname" | cut -d'.' -f1)
            domain=$(echo "$hostname" | cut -d'.' -f2-)
            echo "$subdomain IN A $LB_IP"
        else
            echo "$hostname IN A $LB_IP"
        fi
    fi
done

echo ""

echo -e "${BOLD}For Router/Local DNS (dnsmasq format):${NC}"
echo "# DevOpsBeerer Playground - Add to dnsmasq configuration"
echo "$HOSTNAMES" | while read -r hostname; do
    if [ -n "$hostname" ]; then
        echo "address=/$hostname/$LB_IP"
    fi
done

echo ""

# Generate copy-paste commands
echo -e "${BOLD}${YELLOW}=== Quick Copy-Paste Commands ===${NC}\n"

echo -e "${BOLD}Linux/Mac - Add to /etc/hosts:${NC}"
echo "sudo tee -a /etc/hosts << EOF"
echo "# DevOpsBeerer Playground"
echo "$HOSTNAMES" | while read -r hostname; do
    if [ -n "$hostname" ]; then
        echo "$LB_IP $hostname"
    fi
done
echo "EOF"

echo ""

echo -e "${BOLD}Windows PowerShell (Run as Administrator):${NC}"
echo "Add-Content -Path C:\\Windows\\System32\\drivers\\etc\\hosts -Value @'"
echo "# DevOpsBeerer Playground"
echo "$HOSTNAMES" | while read -r hostname; do
    if [ -n "$hostname" ]; then
        echo "$LB_IP $hostname"
    fi
done
echo "'@"

echo ""

# Verification section
echo -e "${BOLD}${BLUE}=== Verification Commands ===${NC}\n"

echo -e "${BOLD}Test DNS resolution:${NC}"
echo "$HOSTNAMES" | head -1 | while read -r hostname; do
    if [ -n "$hostname" ]; then
        echo "nslookup $hostname"
        echo "# Should return: $LB_IP"
    fi
done

echo ""

echo -e "${BOLD}Test HTTP connectivity:${NC}"
echo "$HOSTNAMES" | head -1 | while read -r hostname; do
    if [ -n "$hostname" ]; then
        echo "curl -k https://$hostname"
        echo "# Should return a response (ignore SSL warnings for self-signed certs)"
    fi
done

echo ""

# Additional information
echo -e "${BOLD}${YELLOW}=== Important Notes ===${NC}\n"
echo "1. This script does NOT automatically create DNS records"
echo "2. You need to manually add the records to your chosen DNS method"
echo "3. For local testing, /etc/hosts is the simplest option"
echo "4. For network-wide access, configure your router's DNS or local DNS server"
echo "5. SSL certificates are self-signed - browsers will show security warnings"
echo "6. Run this script again if you redeploy the ingress controller"

echo ""
echo -e "${GREEN}DNS records generated successfully!${NC}"
echo -e "${YELLOW}Choose your preferred method above and copy the appropriate records.${NC}"
