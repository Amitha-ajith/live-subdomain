#!/bin/bash

# ─────────────────────────────────────────────
# Subdomain Recon Tool
# ─────────────────────────────────────────────
echo "========================================"
echo " 🔍 Subdomain Enumeration Tool"
echo "========================================"

# Prompt for domain
read -p "Enter domain: " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "❌ No domain entered. Exiting."
    exit 1
fi

# Set output paths
OUTPUT_DIR="${DOMAIN}_recon"
SUBS_FILE="$OUTPUT_DIR/all_subdomains.txt"
LIVE_FILE="$OUTPUT_DIR/live_subdomains.txt"
README_FILE="$OUTPUT_DIR/README.md"
REPO_DIR="$OUTPUT_DIR"

# Create directory
mkdir -p "$OUTPUT_DIR"

# Find subdomains
echo "[*] Finding subdomains for: $DOMAIN"
subfinder -d "$DOMAIN" -silent >> "$SUBS_FILE"
amass enum -passive -d "$DOMAIN" >> "$SUBS_FILE"

# Remove duplicates
sort -u "$SUBS_FILE" -o "$SUBS_FILE"

# Check live subdomains
echo "[*] Checking which subdomains are live..."
cat "$SUBS_FILE" | httpx -silent -no-color > "$LIVE_FILE"

# Display results on screen
echo "========================================"
echo "📁 Subdomain Results:"
cat "$SUBS_FILE"
echo "----------------------------------------"
echo "✅ Live Subdomains:"
cat "$LIVE_FILE"
echo "========================================"

# Ask user if they want to continue
read -p "Do you want to push this to GitHub? (y/n): " ANSWER

if [[ "$ANSWER" != "y" && "$ANSWER" != "Y" ]]; then
    echo "👋 Exiting without pushing to GitHub."
    exit 0
fi

# Create README
cat <<EOF > "$README_FILE"
# Subdomain Recon for $DOMAIN

This repo contains subdomain enumeration results for: \`$DOMAIN\`

## Tools Used
- subfinder
- amass
- httpx

## Files
- \`all_subdomains.txt\`: All subdomains found.
- \`live_subdomains.txt\`: Live subdomains verified via HTTP.
EOF

# Git logic
cd "$REPO_DIR"

if [ ! -d ".git" ]; then
    git init
    git remote add origin <YOUR_GITHUB_REPO_URL>  # ← Replace this!
fi

git add .
git commit -m "Added recon data for $DOMAIN"
git push -u origin master

echo "✅ Recon data pushed to GitHub!"
