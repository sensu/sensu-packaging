# Windows Code Signing with DigiCert KeyLocker

## Overview

This repository contains the CircleCI pipeline configuration for building and signing Windows packages (`.exe`, `.msi`, `.nupkg`) for Sensu using DigiCert KeyLocker (Signing Manager).

**What's New**: 
- ✅ Migrated from legacy certificate signing to DigiCert KeyLocker
- ✅ Automated certificate management in CircleCI
- ✅ Secure credential storage using environment variables
- ✅ Full signature verification in CI/CD pipeline
- ✅ Enterprise-grade code signing infrastructure

---

## Quick Start

### For DevOps/CI Team

1. **First Time Setup**:
   - Follow [MIGRATION_CHECKLIST.md](./MIGRATION_CHECKLIST.md) (20-30 minutes)
   - Collect DigiCert credentials from organization
   - Configure CircleCI environment variables

2. **Deploy**:
   - Commit `.circleci/config.yml` changes
   - Trigger build to test
   - Monitor logs for successful signing

3. **Verify**:
   - Download signed artifacts
   - Run signature verification
   - Test Windows installation

### For Developers

1. **Building Locally**:
   - Follow repository's standard build instructions
   - No changes needed for local builds

2. **CI/CD Pipeline**:
   - Automatic signing happens in CircleCI
   - No developer action required
   - Review build logs to verify signing success

3. **Testing Signed Artifacts**:
   - Download MSI from CircleCI
   - Run Windows installation
   - Verify no signature warnings

---

## Architecture

### Signing Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                     CircleCI Build Job                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Checkout source code                                       │
│     └─ Clone repository                                        │
│                                                                 │
│  2. Build binaries                                             │
│     ├─ Build sensu-agent.exe (x86, x64)                        │
│     └─ Build sensuctl.exe (x86, x64)                           │
│                                                                 │
│  3. Setup DigiCert Credentials                                 │
│     ├─ Read environment variables (SM_API_KEY, etc.)          │
│     ├─ Decode Base64 certificate                               │
│     └─ Create PKCS#11 configuration                            │
│                                                                 │
│  4. Install DigiCert Tools                                     │
│     ├─ Download SMCTL (Signing Manager Controller)             │
│     └─ Install DigiCert One Signing Manager Tools              │
│                                                                 │
│  5. Sync Certificates                                          │
│     ├─ Connect to DigiCert ONE                                 │
│     ├─ Retrieve keypair certificate                            │
│     └─ Sync to Windows certificate store                       │
│                                                                 │
│  6. Sign Executables                                           │
│     ├─ Sign sensu-agent.exe (x86)                              │
│     ├─ Sign sensu-agent.exe (x64)                              │
│     ├─ Sign sensuctl.exe (x86)                                 │
│     └─ Sign sensuctl.exe (x64)                                 │
│                                                                 │
│  7. Build MSI Packages                                         │
│     ├─ Generate MSI for x86                                    │
│     └─ Generate MSI for x64                                    │
│                                                                 │
│  8. Sign MSI Packages                                          │
│     ├─ Sign *.msi files in dist/msi/en-US/                     │
│     └─ Verify all signatures                                   │
│                                                                 │
│  9. Create Chocolatey Packages                                 │
│     ├─ Copy signed MSI to choco tools                          │
│     └─ Generate .nupkg (Chocolatey package)                    │
│                                                                 │
│  10. Upload Artifacts                                          │
│      ├─ Store MSI files                                        │
│      ├─ Store NUPKG (Chocolatey)                               │
│      └─ Upload to S3/artifact repository                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Component Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                      CircleCI Environment                         │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │          Windows Executor (Server 2019/2022)               │  │
│  │                                                            │  │
│  │  ┌─────────────────────────────────────────────────────┐   │  │
│  │  │   DigiCert One Signing Manager Tools                │   │  │
│  │  │   - SMCTL.exe (Signing Manager Controller)           │   │  │
│  │  │   - smpkcs11.dll (PKCS#11 library)                   │   │  │
│  │  │   - Supporting libraries                             │   │  │
│  │  └─────────────────────────────────────────────────────┘   │  │
│  │                          ↕ (signs)                         │  │
│  │  ┌─────────────────────────────────────────────────────┐   │  │
│  │  │           Windows Certificate Store                  │   │  │
│  │  │  - Synced from DigiCert keypair                     │   │  │
│  │  │  - Used by SMCTL for signing                        │   │  │
│  │  └─────────────────────────────────────────────────────┘   │  │
│  │                          ↕ (signs via)                     │  │
│  │  ┌─────────────────────────────────────────────────────┐   │  │
│  │  │  Artifacts to Sign                                   │   │  │
│  │  │  - sensu-agent.exe (x86/x64)                         │   │  │
│  │  │  - sensuctl.exe (x86/x64)                            │   │  │
│  │  │  - *.msi files                                       │   │  │
│  │  └─────────────────────────────────────────────────────┘   │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                                ↕
┌──────────────────────────────────────────────────────────────────┐
│                      DigiCert ONE Portal                          │
│                                                                  │
│  - Stores private keys in secure HSM                             │
│  - Manages keypairs and certificates                             │
│  - Authenticates via SM_API_KEY + client certificate             │
│  - Performs actual signing operation                             │
│  - Returns signed artifacts                                      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Security Model

```
┌─────────────────────────────────────────────────────────────────┐
│                     Security Flow                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 1. Credentials Storage                                          │
│    ├─ CircleCI encrypts environment variables at rest           │
│    └─ Values masked in logs (shown as ••••••)                   │
│                                                                 │
│ 2. API Authentication (Multi-factor)                            │
│    ├─ Factor 1: SM_API_KEY (API key authentication)             │
│    └─ Factor 2: SM_CLIENT_CERT_FILE + password                 │
│       (Client certificate authentication)                       │
│                                                                 │
│ 3. Private Key Protection                                       │
│    ├─ Private key never leaves DigiCert HSM                     │
│    ├─ Only DigiCert performs actual signing                     │
│    └─ SMCTL acts as client interface                            │
│                                                                 │
│ 4. Network Security                                             │
│    ├─ TLS encryption to DigiCert (configurable via              │
│    │  SM_TLS_SKIP_VERIFY)                                       │
│    └─ Certificate pinning recommended for production            │
│                                                                 │
│ 5. Audit Trail                                                  │
│    ├─ DigiCert logs all signing operations                      │
│    ├─ CircleCI logs signing steps                               │
│    └─ Signed artifacts are timestamped                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
certificate/
├── .circleci/
│   └── config.yml              # Updated CircleCI pipeline configuration
├── wix/
│   ├── sensu-go-agent/         # MSI project for agent
│   └── sensu-go-cli/           # MSI project for CLI
├── choco/
│   ├── sensu-go-agent/         # Chocolatey package for agent
│   └── sensu-go-cli/           # Chocolatey package for CLI
├── scripts/
│   ├── test-digicert-setup.sh  # Verify DigiCert integration
│   └── ...
├── DIGICERT_SETUP.md           # Detailed setup & troubleshooting
├── MIGRATION_CHECKLIST.md      # Step-by-step migration guide
└── README.md                   # This file
```

---

## CircleCI Pipeline Changes

### New Commands

#### `setup-digicert-credentials`
Initializes DigiCert environment:
- Creates temporary directory for credentials
- Decodes Base64 certificate
- Downloads DigiCert Signing Manager Tools
- Installs SMCTL and supporting libraries
- Creates PKCS#11 configuration file

```yaml
- setup-digicert-credentials
```

#### `digicert-sync-certificates`
Syncs DigiCert keypair to Windows certificate store:
- Authenticates to DigiCert ONE
- Retrieves keypair certificate
- Imports to Windows certificate store
- Enables signtool/SMCTL to use the certificate

```yaml
- digicert-sync-certificates
```

#### `sign-artifact-with-digicert`
Signs files/folders and verifies signatures:
- Supports single files or folders with wildcards
- Automatically signs all supported file types
- Verifies each signature after signing
- Reports success/failure with details

```yaml
- sign-artifact-with-digicert:
    file_path: "C:\\path\\to\\artifact.exe"
    keypair_alias: "sensu-code-signing"
```

### Updated Job: `build-windows-packages`

The job now includes DigiCert signing automatically:

1. **Fetch binaries** - Downloads pre-built executables
2. **Setup DigiCert** - Installs tools and credentials
3. **Sync certificates** - Imports keypair to certificate store
4. **Sign executables** - Digitally signs .exe files
5. **Build MSI packages** - Generates installation packages
6. **Sign packages** - Digitally signs .msi files
7. **Create Chocolatey packages** - Builds distribution packages
8. **Upload artifacts** - Stores signed packages

---

## Environment Variables

Required environment variables in CircleCI project settings:

| Variable | Description | Example |
|----------|-------------|---------|
| `SM_API_KEY` | DigiCert API key | `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |
| `SM_CLIENT_CERT_FILE_B64` | Base64-encoded PKCS#12 certificate | `MIIDXTCCAk...` |
| `SM_CLIENT_CERT_PASSWORD` | Password for client certificate | `your-cert-password` |
| `SM_HOST` | DigiCert ONE endpoint | `https://clientauth.one.digicert.com` |
| `SM_KEYPAIR_ALIAS` | DigiCert keypair alias/name | `sensu-code-signing` |
| `SM_TLS_SKIP_VERIFY` | Skip TLS verification (dev only) | `false` |

If these secrets are stored in 1Password, use the vault values when creating the CircleCI environment variables. Do not store secret values in source control.

See [DIGICERT_SETUP.md](./DIGICERT_SETUP.md) for detailed setup instructions.

---

## Signing Process Details

### What Gets Signed

- **Executables**: `sensu-agent.exe`, `sensuctl.exe` (x86 and x64)
- **MSI Packages**: Windows installer packages (x86 and x64)
- **Chocolatey**: `.nupkg` files (built from signed MSI)

### Signing Algorithm

- **Algorithm**: RSA with SHA-256 digest
- **Timestamp**: Added by DigiCert timestamp service
- **Tool**: SMCTL (Signing Manager Controller)

### Verification

After signing, each artifact is verified:

```powershell
smctl sign verify --input="path\to\file.exe"
```

Expected output:
```
File: path\to\file.exe
Status: Verified
Signer: [DigiCert Certificate Name]
Timestamp: [Timestamp from DigiCert]
```

---

## Testing & Validation

### Local Testing (Optional)

```bash
# On Windows with DigiCert tools installed:

# 1. Test SMCTL installation
smctl --version

# 2. Sync certificates
smctl windows certsync --keypair-alias=sensu-code-signing

# 3. Test signing
smctl sign --keypair-alias=sensu-code-signing --input="C:\path\to\test.exe"

# 4. Verify signature
smctl sign verify --input="C:\path\to\test.exe"
```

### CI/CD Testing

```bash
# Run setup test script
bash scripts/test-digicert-setup.sh

# Verify environment variables are set
# Check DigiCert connectivity
# Validate certificate encoding
```

### End-to-End Validation

1. Trigger CircleCI build
2. Monitor logs for successful completion
3. Download artifacts
4. Verify signatures:
   ```powershell
   signtool verify /pa "C:\Downloads\sensu-agent.exe"
   ```
5. Test Windows installation of MSI
6. Verify no signature warnings

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| "API key not authorized" | Check API key is correct and active in DigiCert |
| "Certificate not found" | Verify Base64 encoding and certificate password |
| "Keypair alias not found" | Double-check alias spelling (case-sensitive) |
| "SMCTL installation failed" | Check Windows executor disk space and permissions |
| "Signature verification failed" | Ensure certificate is in Production category |

See [DIGICERT_SETUP.md](./DIGICERT_SETUP.md#troubleshooting) for detailed troubleshooting guide.

---

## Migration from Legacy Signing

### What Changed

| Aspect | Before (Legacy) | After (DigiCert) |
|--------|---|---|
| **Certificate Storage** | Encrypted local file (`codesign-cert.p12.enc`) | DigiCert HSM (secure cloud) |
| **Private Key** | Stored in repository (encrypted) | Never stored locally, stays in HSM |
| **Signing Tool** | signtool.exe (Windows SDK) | SMCTL (DigiCert) |
| **Authentication** | File-based decryption | Multi-factor (API key + cert) |
| **Audit Trail** | Limited to CircleCI logs | Full audit in DigiCert portal |
| **Key Rotation** | Manual, risky process | Managed by DigiCert |

### Migration Steps

1. **Setup DigiCert** - Create account and credentials (see MIGRATION_CHECKLIST.md)
2. **Configure CircleCI** - Add environment variables (see DIGICERT_SETUP.md)
3. **Deploy** - Commit updated `.circleci/config.yml`
4. **Test** - Trigger build and verify signed artifacts
5. **Cleanup** - Remove legacy certificate files (when confident)

---

## Maintenance

### Regular Tasks

- **Monthly**: Review DigiCert signing audit trail
- **Quarterly**: Test credential rotation
- **Annually**: Renew API key and client certificate
- **As Needed**: Update SMCTL version when new releases available

### Monitoring

- Watch CircleCI build logs for signing errors
- Monitor DigiCert ONE for any security alerts
- Track certificate expiration dates
- Review failed signing attempts

---

## Support & Documentation

- **DigiCert Documentation**: https://docs.digicert.com/en/digicert-keylocker/
- **SMCTL Command Manual**: https://docs.digicert.com/en/digicert-keylocker/smctl-command-manual.html
- **CircleCI Integration**: https://docs.digicert.com/en/software-trust-manager/ci-cd-integrations-and-deployment-pipelines/scripts/circleci.html
- **Setup Guide**: See [DIGICERT_SETUP.md](./DIGICERT_SETUP.md)
- **Migration Guide**: See [MIGRATION_CHECKLIST.md](./MIGRATION_CHECKLIST.md)

---

## Security Considerations

### Best Practices

✅ **DO:**
- Keep API keys and passwords in CircleCI environment variables
- Rotate credentials annually
- Monitor DigiCert audit logs
- Test in non-production first
- Use organization-level contexts for sensitive variables

❌ **DON'T:**
- Commit credentials to version control
- Share environment variable values via chat/email
- Use development certificates for production
- Skip TLS verification in production
- Leave default API key expiration unchanged

---

## Frequently Asked Questions

**Q: Why migrate from legacy signing?**
A: Legacy certificates expire, DigiCert discontinued support, and KeyLocker provides better security and key management.

**Q: Is signing automatic?**
A: Yes! Once CircleCI environment variables are configured, signing happens automatically in every build.

**Q: Can developers sign locally?**
A: Yes, they can install DigiCert tools locally and use SMCTL to sign files using the same keypair.

**Q: What if a build fails to sign?**
A: Check CircleCI logs for error details. Most issues are credential-related. See [DIGICERT_SETUP.md](./DIGICERT_SETUP.md) troubleshooting section.

**Q: How long does signing add to build time?**
A: ~3-5 minutes (includes tool download, installation, and signing all artifacts).

**Q: Can we revert to legacy signing?**
A: Yes, the old `.circleci/config.yml` can be recovered from git history if needed, but legacy certificate has expired.

---

## Release Notes

### Version 1.0 (May 2026)
- ✅ Initial DigiCert KeyLocker integration
- ✅ Automated signing for Windows executables and MSI packages
- ✅ Full signature verification in CI/CD
- ✅ Comprehensive documentation and setup guides
- ✅ Removed legacy certificate-based signing

---

**Last Updated**: May 2026  
**Maintained By**: Security & DevOps Team  
**Status**: ✅ Production Ready
