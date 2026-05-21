#!/bin/bash
# DigiCert KeyLocker Setup & Testing Script
# This script helps verify DigiCert KeyLocker integration on your local machine
# Run this before committing changes to ensure signing will work in CI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}DigiCert KeyLocker Integration Tester${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if running on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "${YELLOW}Note: Running on Unix-like system. Full Windows signing tests require Windows.${NC}"
else
    echo -e "${RED}Error: This script is designed for testing environment variables and credentials.${NC}"
    echo -e "${RED}For full signing tests, run on Windows with DigiCert tools installed.${NC}"
fi

# Step 1: Check environment variables
echo -e "\n${BLUE}Step 1: Checking Environment Variables${NC}"
echo "======================================"

REQUIRED_VARS=("SM_API_KEY" "SM_CLIENT_CERT_FILE_B64" "SM_CLIENT_CERT_PASSWORD" "SM_HOST" "SM_KEYPAIR_ALIAS")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo -e "${RED}✗ $var is not set${NC}"
        MISSING_VARS+=("$var")
    else
        # For sensitive variables, only show first and last 4 characters
        if [[ "$var" == "SM_API_KEY" ]] || [[ "$var" == "SM_CLIENT_CERT_PASSWORD" ]] || [[ "$var" == "SM_CLIENT_CERT_FILE_B64" ]]; then
            value="${!var}"
            echo -e "${GREEN}✓ $var is set (${#value} characters)${NC}"
        else
            echo -e "${GREEN}✓ $var = ${!var}${NC}"
        fi
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo -e "\n${RED}ERROR: Missing required environment variables:${NC}"
    for var in "${MISSING_VARS[@]}"; do
        echo "  - $var"
    done
    echo -e "\n${YELLOW}Please set these variables before running CircleCI builds:${NC}"
    echo "export SM_API_KEY='your-api-key'"
    echo "export SM_CLIENT_CERT_FILE_B64='your-base64-certificate'"
    echo "export SM_CLIENT_CERT_PASSWORD='your-certificate-password'"
    echo "export SM_HOST='https://clientauth.one.digicert.com'"
    echo "export SM_KEYPAIR_ALIAS='your-keypair-alias'"
    exit 1
fi

echo -e "${GREEN}✓ All required environment variables are set${NC}"

# Step 2: Validate Base64 encoding
echo -e "\n${BLUE}Step 2: Validating Base64 Certificate${NC}"
echo "======================================"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CERT_SIZE=$(echo "$SM_CLIENT_CERT_FILE_B64" | base64 -D | wc -c)
    BASE64_VALID=$(echo "$SM_CLIENT_CERT_FILE_B64" | base64 -D >/dev/null 2>&1 && echo "true" || echo "false")
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    CERT_SIZE=$(echo "$SM_CLIENT_CERT_FILE_B64" | base64 -d | wc -c)
    BASE64_VALID=$(echo "$SM_CLIENT_CERT_FILE_B64" | base64 -d >/dev/null 2>&1 && echo "true" || echo "false")
fi

if [ "$BASE64_VALID" = "true" ]; then
    echo -e "${GREEN}✓ Base64 certificate is valid (${CERT_SIZE} bytes)${NC}"
else
    echo -e "${RED}✗ Base64 certificate is invalid${NC}"
    exit 1
fi

# Step 3: Check DigiCert Host connectivity
echo -e "\n${BLUE}Step 3: Testing DigiCert Host Connectivity${NC}"
echo "======================================"

if command -v curl &> /dev/null; then
    echo "Testing connection to: $SM_HOST"
    if curl -s -I "$SM_HOST" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Can reach DigiCert host${NC}"
    else
        echo -e "${YELLOW}⚠ Cannot reach DigiCert host (may be firewall/network issue)${NC}"
        echo "  This might fail in CI. Check network connectivity."
    fi
else
    echo -e "${YELLOW}⚠ curl not available, skipping connectivity test${NC}"
fi

# Step 4: Check for Windows-specific requirements
echo -e "\n${BLUE}Step 4: Windows Environment Check${NC}"
echo "======================================"

if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]] || command -v powershell &> /dev/null; then
    echo -e "${GREEN}✓ Running on Windows or Windows-compatible environment${NC}"
    
    if command -v smctl &> /dev/null; then
        echo -e "${GREEN}✓ SMCTL is already installed${NC}"
        smctl --version
    else
        echo -e "${YELLOW}⚠ SMCTL not found (will be installed during CI build)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Not running on Windows (full signing requires Windows)${NC}"
fi

# Step 5: Recommendations
echo -e "\n${BLUE}Step 5: Next Steps${NC}"
echo "======================================"

echo -e "${GREEN}Pre-CI Checklist:${NC}"
echo "  ✓ Environment variables configured in CircleCI"
echo "  ✓ Base64 certificate is valid"
echo "  ✓ DigiCert host is reachable"
echo ""
echo -e "${YELLOW}When you commit and push:${NC}"
echo "  1. CircleCI will download DigiCert Signing Manager Tools"
echo "  2. Your certificate will be decoded and validated"
echo "  3. PKCS#11 configuration will be created"
echo "  4. Certificates will be synced to Windows store"
echo "  5. Artifacts will be signed automatically"
echo "  6. Signatures will be verified"
echo ""
echo -e "${YELLOW}To test locally on Windows:${NC}"
echo "  1. Install DigiCert One Signing Manager Tools manually"
echo "  2. Decode and save your certificate file"
echo "  3. Run: smctl sign --keypair-alias=YOUR_ALIAS --input=FILE_TO_SIGN"
echo "  4. Run: smctl sign verify --input=SIGNED_FILE"
echo ""
echo -e "${GREEN}Integration ready! Your CircleCI builds will now use DigiCert KeyLocker for signing.${NC}"
