#!/bin/bash

# ─────────────────────────────────────────────
# 🌐 Subdomain Finder with Live Check
# ─────────────────────────────────────────────

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Spinner animation
spin() {
    local -a marks=( '/' '-' '\' '|' )
    while :; do
        for m in "${marks[@]}"; do
            printf "\r[$m] $1"
            sleep 0.1
        done
    done
}

# Show Title
clear
echo -e "${CYAN}"
echo "==============================================="
echo " 🔍 SUBDOMAIN ENUMERATION & LIVE CHECK TOOL"
echo "==============================================="
echo -e "${NC}"

# Prompt for domain
read -p "$(echo -e ${YELLOW}Enter domain:${NC} ) " DOMAIN

# Check input
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}❌ No domain entered. Exiting.${NC}"
    exit 1
fi

# Set output paths
OUTPUT_DIR="${DOMAIN}_recon"
SUBS_FILE="$OUTPUT_DIR/all_subdomains.txt"
LIVE_FILE="$OUTPUT_DIR/live_subdomains.txt"
mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}[*] Finding subdomains for: $DOMAIN${NC}"

# Start spinner in background
spin "Running subfinder and amass..." &
SPIN_PID=$!
trap "kill $SPIN_PID 2>/dev/null" EXIT

# Run subdomain tools
subfinder -d "$DOMAIN" -silent >> "$SUBS_FILE" 2>/dev/null
amass enum -passive -d "$DOMAIN" >> "$SUBS_FILE" 2>/dev/null
sort -u "$SUBS_FILE" -o "$SUBS_FILE"

# Stop spinner
kill $SPIN_PID &>/dev/null
wait $SPIN_PID 2>/dev/null
echo -e "\r✅ Subdomain enumeration completed.            "

# Check live subdomains
echo -e "${BLUE}[*] Checking which subdomains are live...${NC}"

spin "Running httpx on discovered subdomains..." &
SPIN_PID=$!
trap "kill $SPIN_PID 2>/dev/null" EXIT

cat "$SUBS_FILE" | httpx -silent -no-color > "$LIVE_FILE" 2>/dev/null

# Stop spinner
kill $SPIN_PID &>/dev/null
wait $SPIN_PID 2>/dev/null
echo -e "\r✅ Live subdomain check completed.            "

# Display results
echo ""
echo -e "${CYAN}==============================================="
echo "📁 Subdomains Found:"
echo -e "===============================================${NC}"
cat "$SUBS_FILE"
echo ""
echo -e "${GREEN}==============================================="
echo "✅ Live Subdomains:"
echo -e "===============================================${NC}"
cat "$LIVE_FILE"
echo ""

# Done
echo -e "${YELLOW}🎉 Scan complete! Results saved in '${OUTPUT_DIR}' folder.${NC}"
