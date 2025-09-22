#!/bin/bash

# ─────────────────────────────────────────────
# Subdomain Enumeration Script
# ─────────────────────────────────────────────

# Show Title
echo "========================================"
echo " 🔍 Subdomain Enumeration Tool"
echo "========================================"

# Prompt for domain
read -p "Enter domain: " DOMAIN

# Exit if no domain entered
if [ -z "$DOMAIN" ]; then
    echo "❌ No domain entered. Exiting."
    exit 1
fi

# Output Paths
OUTPUT_DIR="${DOMAIN}_recon"
SUBS_FILE="$OUTPUT_DIR/all_subdomains.txt"
LIVE_FILE="$OUTPUT_DIR/live_subdomains.txt"
README_FILE="$OUTPUT_DIR/README.md"

# Create Output Folder
mkdir -p "$OUTPUT_DIR"

echo ""
echo "[*] Finding subdomains for: $DOMAIN"

# Subfinder + Amass
subfinder -d "$DOMAIN" -silent >> "$SUBS_FILE"
amass enum -passive -d "$DOMAIN" >> "$SUBS_FILE"

# Remove Duplicates
sort -u "$SUBS_FILE" -o "$SUBS_FILE"

echo "[*] Checking which subdomains are live..."
cat "$SUBS_FILE" | httpx -silent -no-color > "$LIVE_FILE"

# Display results
echo "========================================"
echo "📁 All Subdomains Found:"
cat "$SUBS_FILE"
echo "----------------------------------------"
echo "✅ Live Subdomains:"
cat "$LIVE_FILE"
echo "========================================"

# Ask for GitHub push
read -p "Do you want to push results to GitHub? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "👋 Exiting without pushing to GitHub."
    exit 0
fi

# Generate README.md
cat <<EOF > "$README_FILE"
# 🔍 Subdomain Recon for $DOMAIN

This directory contains the results of subdomain enumeration and live host checking for: \`$DOMAIN\`.

## 🧰 Tools Used
- [subfinder](https://github.com/projectdiscovery/subfinder)
- [amass](https://github.com/owasp-amass/amass)
- [httpx](https://github.com/projectdiscovery/httpx)

## 📄 Files
- \`all_subdomains.txt\` - All subdomains discovered
- \`live_subdomains.txt\` - Live subdomains verified using HTTP(S)

## 📅 Scan Date
- $(date)

## ⚠️ Disclaimer
Use responsibly. Do not scan domains without proper authorization.
EOF

# GitHub Push
cd "$OUTPUT_DIR"

if [ ! -d ".git" ]; then
    git init
    git remote add origin https://github.com/Amitha-ajith/live-subdomain  # ← Replace this!
fi

git add .
git commit -m "Added subdomain recon data for $DOMAIN"
git branch -M main
git push -u origin main

echo ""
echo "✅ Results pushed to GitHub successfully!"
