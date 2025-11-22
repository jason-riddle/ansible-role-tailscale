# OIDC Implementation Summary

## What Was Implemented

This implementation adds OpenID Connect (OIDC) authentication support for Tailscale in GitHub Actions, solving the 90-day auth key expiration problem mentioned in the issue.

## Key Features

1. **Automatic Auth Key Generation**: No manual secret rotation needed
2. **Backward Compatibility**: Falls back to static secrets if OIDC is not configured
3. **Zero Breaking Changes**: Existing workflows continue to work unchanged
4. **Security Enhanced**: Short-lived credentials that expire after use
5. **Fine-grained Control**: Support for repository, branch, and event-based restrictions

## Files Changed

### 1. `.github/workflows/ci.yml`
**Changes:**
- Added `permissions` block with `id-token: write` for OIDC token generation
- Added conditional OIDC token acquisition steps (lines 115-178)
- Updated test steps to use OIDC-generated keys with fallback to static secrets (lines 187-203)

**Flow:**
```
GitHub OIDC Token → Tailscale API Token → Ephemeral Auth Keys → Molecule Tests
                          ↓ (if OIDC not configured)
                    Static Secrets (existing behavior)
```

### 2. `README.md`
**Changes:**
- Added new section highlighting OIDC authentication feature
- Added link to setup documentation

### 3. `docs/OIDC_SETUP.md` (New)
**Purpose:**
Complete step-by-step guide for setting up OIDC authentication including:
- Tailscale Trust Credential configuration
- GitHub repository variables setup
- Subject pattern examples
- Troubleshooting guide
- Security best practices

### 4. `.github/workflows/example-oidc.yml` (New)
**Purpose:**
Standalone example workflow demonstrating OIDC integration that users can:
- Reference for their own implementations
- Test their OIDC configuration
- Use as a template for custom workflows

## How It Works

### Configuration (One-Time Setup)
1. User creates a Tailscale Trust Credential with OIDC type
2. User sets two GitHub repository variables:
   - `TS_OIDC_CLIENT_ID`: Tailscale OIDC client ID
   - `TS_OIDC_AUDIENCE`: Custom audience string

### Runtime (Per Workflow Run)
1. **Get OIDC Token**: GitHub Actions provides an OIDC token (JWT)
2. **Exchange Token**: Send JWT to Tailscale's token exchange endpoint
3. **Get API Token**: Receive short-lived Tailscale API token
4. **Generate Keys**: Use API token to create ephemeral auth keys
5. **Run Tests**: Pass auth keys to Molecule tests

### Fallback Behavior
If OIDC variables are not configured:
- OIDC steps are skipped (conditional execution)
- Workflow uses existing `TAILSCALE_AUTHKEY` and `TAILSCALE_OAUTH_CLIENT_SECRET` secrets
- No changes required for repositories not using OIDC

## Security Considerations

1. **Masked Secrets**: All tokens and keys are masked in logs using `::add-mask::`
2. **Short-lived Credentials**: Auth keys expire in 1 hour (3600 seconds)
3. **Ephemeral Nodes**: Generated keys create ephemeral nodes that auto-cleanup
4. **Conditional Execution**: OIDC steps only run when properly configured
5. **Error Handling**: Failed token exchanges prevent workflow continuation

## Benefits Over Static Secrets

| Aspect | Static Secrets | OIDC |
|--------|---------------|------|
| Expiration | 90 days max | Per workflow run |
| Rotation | Manual | Automatic |
| Security | Long-lived | Short-lived |
| Maintenance | Required | None |
| Access Control | Basic | Fine-grained |

## Migration Path

1. **Optional**: Existing workflows continue working with static secrets
2. **Gradual**: Repositories can enable OIDC at their own pace
3. **Reversible**: Can switch back to static secrets by removing variables
4. **Testing**: Example workflow allows testing before full migration

## API Endpoints Used

1. **GitHub OIDC**: `$ACTIONS_ID_TOKEN_REQUEST_URL`
   - Returns JWT with claims about the workflow run
   
2. **Tailscale Token Exchange**: `https://api.tailscale.com/api/v2/oauth/token-exchange`
   - Validates JWT and returns API token
   
3. **Tailscale Auth Key Generation**: `https://api.tailscale.com/api/v2/tailnet/-/keys`
   - Creates ephemeral, preauthorized auth keys with tags

## Testing Recommendations

1. **Setup OIDC** following `docs/OIDC_SETUP.md`
2. **Run Example Workflow** to verify configuration
3. **Monitor Logs** for successful token exchange
4. **Check Tailscale Admin** for node creation with correct tags
5. **Verify Cleanup** that ephemeral nodes are removed after tests

## References

- Issue: Automate Tailscale Auth Key Generation in GitHub Actions via OIDC / Workload Identity Federation
- Tailscale OIDC Docs: https://tailscale.com/kb/1581/workload-identity-federation
- GitHub OIDC Docs: https://docs.github.com/en/actions/concepts/security/openid-connect
