# DigiCert KeyLocker Integration for Windows Code Signing

## Overview

This document explains how to configure DigiCert KeyLocker (Signing Manager) for automated code signing of Windows `.exe` and `.msi` artifacts in the CircleCI pipeline.

## Prerequisites

1. **DigiCert ONE Account**: Access to DigiCert ONE portal (https://one.digicert.com)
2. **API Key**: Valid DigiCert API key with code signing permissions
3. **Client Certificate**: Client authentication certificate (in PKCS#12 format)
4. **Keypair**: Configured keypair in DigiCert ONE for code signing
5. **Certificate Profile**: Production certificate profile for Windows code signing

## Step 1: Create DigiCert Credentials

### 1.1 Create API Key

1. Log in to DigiCert ONE (https://one.digicert.com)
2. Navigate to **Profile** → **Admin Profile**
3. Scroll to **API Keys** section
4. Click **Create API Key**
5. Provide a descriptive name (e.g., "CircleCI Code Signing")
6. Set an expiration date
7. Click **Create**
8. **Copy the API key** - it will only be displayed once
9. Save this securely; you'll need it for CircleCI environment variables

### 1.2 Create Client Authentication Certificate

1. In DigiCert ONE, navigate to **Profile** → **Admin Profile**
2. Scroll to **Client Authentication Certificates** section
3. Click **Create Client Authentication Certificate**
4. Provide a descriptive nickname (e.g., "CircleCI Client Cert")
5. Select an expiration date
6. Select preferred encryption and signature hash algorithms (recommend SHA-256)
7. Click **Generate Certificate**
8. **Download the certificate** (`.p12` file)
9. **Save the password** - it will only be displayed once
10. Store both the certificate file and password securely

### 1.3 Create/Retrieve Keypair

1. Navigate to **DigiCert Software Trust Manager** → **Keypairs**
2. Either:
   - **Create a new keypair**: Click **Create Keypair**, select RSA, provide a name/alias
   - **Use existing keypair**: Note the keypair alias
3. Ensure a valid **code signing certificate** is associated with the keypair
4. Copy the **keypair alias** (e.g., `sensu-code-signing`)

## Step 2: Prepare Certificate for CircleCI

### 2.1 Encode Certificate to Base64

Convert your PKCS#12 certificate to Base64 format for secure storage in CircleCI:

```bash
# macOS/Linux
base64 -i certificate.p12 > certificate_base64.txt

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Out-File -Path certificate_base64.txt
```

**Keep this Base64 content secure** - treat it like a password.

## Step 3: Configure CircleCI Environment Variables

Navigate to your CircleCI project settings and add the following environment variables:

| Variable Name | Value | Description |
|---|---|---|
| `SM_API_KEY` | Your DigiCert API key | Used to authenticate with DigiCert API |
| `SM_CLIENT_CERT_FILE_B64` | Base64-encoded certificate | Base64 string of your PKCS#12 certificate |
| `SM_CLIENT_CERT_PASSWORD` | Certificate password | Password for the PKCS#12 certificate |
| `SM_HOST` | `https://clientauth.one.digicert.com` | DigiCert HOST endpoint |
| `SM_KEYPAIR_ALIAS` | Your keypair alias | Name of the keypair in DigiCert (e.g., `sensu-code-signing`) |
| `SM_TLS_SKIP_VERIFY` | `false` | Set to `true` only for testing/debugging |

### Steps to Add Environment Variables in CircleCI:

1. Go to **CircleCI Dashboard** → **Projects**
2. Select your project
3. Click **Project Settings** (gear icon)
4. Go to **Environment Variables**
5. Click **Add Environment Variable**
6. Enter each variable name and value
7. Click **Add Variable**

**Security Note**: All values are encrypted in CircleCI and masked in logs.

### Using 1Password for Secrets

If your DigiCert credentials are stored in 1Password:

- Use your 1Password vault as the source of truth for these secrets.
- Copy each value from the 1Password item into the corresponding CircleCI environment variable.
- Do not commit the raw secrets or Base64 certificate to source control.

Recommended 1Password field mapping:

| 1Password Field | CircleCI Variable |
|---|---|
| DigiCert API Key | `SM_API_KEY` |
| DigiCert Client Cert (Base64) | `SM_CLIENT_CERT_FILE_B64` |
| DigiCert Client Cert Password | `SM_CLIENT_CERT_PASSWORD` |
| DigiCert Host | `SM_HOST` |
| DigiCert Keypair Alias | `SM_KEYPAIR_ALIAS` |
| TLS Skip Verify | `SM_TLS_SKIP_VERIFY` |

## Step 4: Update CircleCI Pipeline

The CircleCI configuration has been updated with:

### New Commands

- **`setup-digicert-credentials`**: Downloads DigiCert tools, decodes certificate, creates PKCS#11 config
- **`digicert-sync-certificates`**: Syncs DigiCert keypair certificates to Windows certificate store
- **`sign-artifact-with-digicert`**: Signs files/folders using DigiCert SMCTL and verifies signatures

### Updated Job: `build-windows-packages`

The job now:
1. Checks out code
2. Downloads and builds binaries
3. Sets up DigiCert credentials and tools
4. Syncs certificates to Windows certificate store
5. Signs `.exe` files with DigiCert
6. Builds MSI packages
7. Signs `.msi` files with DigiCert
8. Creates and publishes Chocolatey packages

## Step 5: Verify Configuration

### 5.1 Test DigiCert Connection

Before running a full build, you can test the configuration by triggering a build and monitoring the logs.

Look for successful completion of these steps:
- ✅ DigiCert tools downloaded
- ✅ DigiCert tools installed
- ✅ Client certificate decoded
- ✅ PKCS#11 configuration created
- ✅ Certificate synced to Windows store
- ✅ Artifacts signed successfully
- ✅ Signatures verified

### 5.2 Verify Signed Artifacts

Once the build completes, you can verify signatures on the generated artifacts:

#### On Windows (using SMCTL)

```powershell
# Verify a signed EXE
smctl sign verify --input "path\to\sensu-agent.exe"

# Verify a signed MSI
smctl sign verify --input "path\to\sensu-agent.msi"
```

#### Using signtool (Windows SDK)

```powershell
signtool verify /pa "path\to\sensu-agent.exe"
signtool verify /pa "path\to\sensu-agent.msi"
```

#### On macOS/Linux (using smctl)

```bash
smctl sign verify --input "path/to/sensu-agent.exe"
smctl sign verify --input "path/to/sensu-agent.msi"
```

## Signing Process Details

### Files Signed in the Pipeline

The pipeline automatically signs:

1. **32-bit binaries**: `target/windows_386/sensu-agent.exe` or `sensu-cli.exe`
2. **64-bit binaries**: `target/windows_amd64/sensu-agent.exe` or `sensu-cli.exe`
3. **MSI packages**: `dist/msi/en-US/*.msi` files
   - Signed packages are copied to Chocolatey tools directory
   - Chocolatey packages (`.nupkg`) are created

### Signing Command

The pipeline uses the SMCTL signing command:

```powershell
smctl sign --keypair-alias=$KEYPAIR_ALIAS --input=$FILE_PATH
```

### Signature Verification

After each signing operation, signatures are verified:

```powershell
smctl sign verify --input=$FILE_PATH
```

## Troubleshooting

### Issue: "API key not authorized"

**Solution**: Verify your API key is correct and has appropriate permissions in DigiCert ONE.

### Issue: "Certificate not found"

**Solution**: 
- Verify `SM_CLIENT_CERT_FILE_B64` is properly encoded
- Confirm certificate password matches `SM_CLIENT_CERT_PASSWORD`
- Check certificate has not expired

### Issue: "Keypair alias not found"

**Solution**:
- Verify keypair alias matches exactly (case-sensitive)
- Confirm keypair exists in DigiCert ONE
- Check keypair has an associated code signing certificate

### Issue: "SMCTL tools installation failed"

**Solution**:
- Check CircleCI Windows executor has sufficient disk space
- Verify API key allows tool download access
- Check DigiCert download URL is accessible

### Issue: "Signature verification failed"

**Solution**:
- Ensure certificate has required code signing capabilities
- Verify the file was successfully signed (check signing command output)
- Confirm the certificate is valid and not revoked

### Debugging

Enable additional logging by adding to CircleCI step:

```powershell
$env:DEBUG = "true"
$smctlPath = "C:\Program Files\DigiCert\DigiCert One Signing Manager Tools\smctl.exe"
& $smctlPath healthcheck
```

## References

- [DigiCert KeyLocker Documentation](https://docs.digicert.com/en/digicert-keylocker.html)
- [SMCTL Command Reference](https://docs.digicert.com/en/digicert-keylocker/smctl-command-manual.html)
- [CircleCI Integration Guide](https://docs.digicert.com/en/software-trust-manager/ci-cd-integrations-and-deployment-pipelines/scripts/circleci.html)
- [Sign Binaries with SMCTL](https://docs.digicert.com/en/digicert-keylocker/code-signing/sign-with-digicert-signing-tools/sign-binaries-with-smctl.html)

## Security Best Practices

1. **Never commit credentials** to version control
2. **Use CircleCI Contexts** for sensitive organization-wide variables
3. **Rotate API keys** periodically
4. **Monitor certificate expiration dates** and renew before expiry
5. **Review signing logs** for anomalies
6. **Use organization-level variables** for production credentials
7. **Implement certificate pinning** for additional security

## Migration Notes

### From Legacy Signing

The pipeline has been migrated from the previous signing method:

- **Old**: Decrypted local certificate → imported to certificate store → signtool signing
- **New**: DigiCert KeyLocker API → SMCTL CLI → secure signing → signature verification

Benefits:
- ✅ No local certificate storage
- ✅ Centralized key management in DigiCert
- ✅ Audit trail for all signing operations
- ✅ Automatic certificate rotation support
- ✅ Better security posture
- ✅ Modern, actively supported approach

### Deprecated Files

The following files are no longer needed:
- `codesign-cert.p12.enc` (encrypted certificate)
- `DECRYPTION_SECRET_2023` environment variable
- `DECRYPTION_SALT_2023` environment variable
- `sensu/signtool` orb usage

## Contact & Support

For issues with:
- **DigiCert KeyLocker**: Contact DigiCert support
- **CircleCI Pipeline**: Review this document or contact your CI/CD team
- **Code Signing**: Consult internal security policies

---

Last Updated: May 2026
DigiCert KeyLocker Version: Latest
CircleCI Version: 2.1
