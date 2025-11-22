# Quick Start: OIDC Authentication for Tailscale

This is a quick reference guide for setting up OIDC authentication. For complete details, see [OIDC_SETUP.md](OIDC_SETUP.md).

## What You Get

✅ No more manual auth key rotation (90-day limit eliminated)
✅ Short-lived credentials generated per CI run
✅ Enhanced security with automatic cleanup
✅ Zero maintenance overhead

## 5-Minute Setup

### Step 1: Create Tailscale Trust Credential

1. Go to [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys)
2. Click **Trust Credentials** → **Add trust credential**
3. Configure:
   ```
   Type: OpenID Connect
   Issuer: https://token.actions.githubusercontent.com
   Audience: tailscale-ci (choose any name)
   Subject: repo:YOUR-ORG/YOUR-REPO:*
   ```
4. Copy the **Client ID**

### Step 2: Configure GitHub Variables

1. Go to your repository → **Settings** → **Secrets and variables** → **Actions** → **Variables**
2. Add two variables:
   ```
   TS_V2_OIDC_CLIENT_ID = <paste Client ID from Step 1>
   TS_V2_OIDC_AUDIENCE = tailscale-ci (same as Step 1)
   ```

### Step 3: Update Tailscale ACL

Add to your Tailscale ACL policy:

```json
{
  "tagOwners": {
    "tag:github-actions": ["autogroup:admin"]
  }
}
```

### Step 4: Test It

Run your CI workflow and verify:
- "Get GitHub OIDC token" step succeeds
- "Exchange OIDC token for Tailscale API token" step succeeds
- "Generate ephemeral Tailscale auth key" step succeeds
- Molecule tests complete successfully

## That's It! 🎉

Your CI now generates auth keys automatically. No more expired keys, no more manual rotation.

## Fallback Behavior

If OIDC variables are not set, the workflow automatically falls back to using:
- `TS_V2_AUTHKEY` secret (for `up` test)
- `TS_V2_OAUTH_CLIENT_SECRET` secret (for `up-with-oauth` test)

This means you can migrate gradually without breaking existing workflows.

## Troubleshooting

**OIDC steps are skipped?**
- Check that both `TS_V2_OIDC_CLIENT_ID` and `TS_V2_OIDC_AUDIENCE` are set as **Variables** (not Secrets)

**"Failed to get Tailscale API token"?**
- Verify Client ID matches Tailscale Trust Credential
- Verify Audience matches Tailscale Trust Credential
- Check subject pattern includes your repository path

**"Failed to generate auth key"?**
- Verify `tag:github-actions` exists in Tailscale ACL
- Check Tailscale admin console audit logs for details

## Need Help?

- **Complete Guide**: [OIDC_SETUP.md](OIDC_SETUP.md)
- **Example Workflow**: [.github/workflows/example-oidc.yml](../.github/workflows/example-oidc.yml)
- **Implementation Details**: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
- **Tailscale Docs**: https://tailscale.com/kb/1581/workload-identity-federation

## Security Notes

- ✅ All tokens are masked in logs
- ✅ Auth keys expire in 1 hour
- ✅ Nodes are ephemeral (auto-cleanup)
- ✅ Fine-grained access control via OIDC claims
- ✅ No long-lived secrets stored
