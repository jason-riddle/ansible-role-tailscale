# Tailscale OIDC Authentication Setup for GitHub Actions

This guide explains how to configure OpenID Connect (OIDC) authentication for Tailscale in GitHub Actions, eliminating the need for manually rotating 90-day expiring auth keys.

## Overview

OIDC-based authentication enables GitHub Actions to automatically generate short-lived Tailscale auth keys for each CI run without storing long-lived secrets. This provides:

- **No manual secret rotation** - Auth keys are generated just-in-time for each workflow run
- **Enhanced security** - Short-lived credentials that expire after use
- **Fine-grained access control** - Restrict access by repository, branch, event type, or actor
- **Zero maintenance** - No more expired auth key CI failures

## How It Works

1. GitHub Actions requests an OIDC token from `https://token.actions.githubusercontent.com`
2. The OIDC token (a signed JWT) is sent to Tailscale's token exchange endpoint
3. Tailscale verifies the token signature and claims against your Trust Credential configuration
4. Tailscale returns a short-lived API token
5. The API token is used to generate ephemeral auth keys for the CI run

## Prerequisites

- A Tailscale account with admin access
- A GitHub repository with Actions enabled
- The repository using this ansible-role-tailscale for CI tests

## Step 1: Configure Tailscale Trust Credential

1. Log in to the [Tailscale Admin Console](https://login.tailscale.com/admin/)
2. Navigate to **Settings** → **Keys** → **Trust Credentials**
3. Click **Add trust credential**
4. Configure the following:

   - **Name**: `github-actions-ansible-role-tailscale` (or any descriptive name)
   - **Type**: OpenID Connect
   - **Issuer**: `https://token.actions.githubusercontent.com`
   - **Audience**: Choose a custom audience value (e.g., `tailscale-ci`)
   - **Subject Pattern**: `repo:your-org/your-repo:*` (replace with your repository path)
     - For more restrictive access, use patterns like:
       - `repo:your-org/your-repo:ref:refs/heads/main` (only main branch)
       - `repo:your-org/your-repo:pull_request` (only PRs)

5. **Optional**: Add custom claim restrictions for enhanced security:
   - `repository = your-org/your-repo` (limit to specific repository)
   - `ref = refs/heads/main` (limit to main branch pushes)
   - `event_name = push` (exclude workflow_dispatch events)
   - `actor = your-github-username` (limit to specific user)

6. Click **Create** to save the trust credential
7. Copy the **Client ID** - you'll need this for GitHub configuration

### Example Subject Patterns

```
# Allow all workflow types in the repository
repo:jason-riddle/ansible-role-tailscale:*

# Only allow pushes to main branch
repo:jason-riddle/ansible-role-tailscale:ref:refs/heads/main

# Only allow pull requests
repo:jason-riddle/ansible-role-tailscale:pull_request

# Allow specific branch patterns
repo:jason-riddle/ansible-role-tailscale:ref:refs/heads/feature/*
```

## Step 2: Configure GitHub Repository Variables

These variables are **not secrets** and can be safely stored as repository variables (not secrets).

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions** → **Variables** tab
3. Add the following repository variables:

   - **Name**: `TS_V2_OIDC_CLIENT_ID`
   - **Value**: The Client ID from Step 1
   
   - **Name**: `TS_V2_OIDC_AUDIENCE`
   - **Value**: The same audience value you configured in Tailscale (e.g., `tailscale-ci`)

## Step 3: Configure Workflow Permissions

The CI workflow (`.github/workflows/ci.yml`) already includes the required permissions:

```yaml
permissions:
  contents: read      # Required for actions/checkout
  id-token: write     # Required for OIDC token generation
```

## Step 4: Tag Configuration in Tailscale ACL

Ensure your Tailscale ACL policy includes the `tag:github-actions` tag used by the workflow:

```json
{
  "tagOwners": {
    "tag:github-actions": ["autogroup:admin"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["tag:github-actions"],
      "dst": ["*:*"]
    }
  ]
}
```

## Verification

Once configured, your GitHub Actions workflows will automatically:

1. Acquire an OIDC token from GitHub
2. Exchange it for a Tailscale API token
3. Generate ephemeral auth keys
4. Use those keys for CI testing

Check the workflow logs to see the OIDC token exchange in action:
- Look for the "Get GitHub OIDC token" step
- Verify the "Exchange OIDC token for Tailscale API token" step succeeds
- Confirm the "Generate ephemeral Tailscale auth key" step completes

## Fallback to Static Secrets

The workflow maintains backward compatibility. If OIDC variables are not configured, it will fall back to using:
- `TS_V2_AUTHKEY` secret (for the `up` test)
- `TS_V2_OAUTH_CLIENT_SECRET` secret (for the `up-with-oauth` test)

This allows for gradual migration to OIDC authentication.

## Troubleshooting

### "Failed to get Tailscale API token"

- Verify the `TS_V2_OIDC_CLIENT_ID` matches the Client ID from Tailscale
- Verify the `TS_V2_OIDC_AUDIENCE` matches the audience configured in Tailscale
- Check that the Trust Credential subject pattern matches your repository path

### "Failed to generate auth key"

- Ensure the API token has the required permissions
- Verify the tag `tag:github-actions` exists in your Tailscale ACL
- Check Tailscale admin console audit logs for detailed error messages

### OIDC steps are being skipped

- Verify both `TS_V2_OIDC_CLIENT_ID` and `TS_V2_OIDC_AUDIENCE` are set as repository variables
- Check that the variables are not set as secrets (they should be variables)
- Ensure the workflow has `id-token: write` permission

## Security Best Practices

1. **Use restrictive subject patterns** - Limit access to specific repositories, branches, or event types
2. **Add custom claim restrictions** - Further restrict access based on workflow context
3. **Monitor Tailscale audit logs** - Review token exchanges and auth key generation
4. **Rotate trust credentials periodically** - While not required, consider rotating for defense in depth
5. **Use ephemeral nodes** - The workflow generates ephemeral auth keys that automatically clean up nodes

## Additional Resources

- [Tailscale OIDC Workload Identity Federation](https://tailscale.com/kb/1581/workload-identity-federation)
- [Tailscale Trust Credentials Documentation](https://tailscale.com/kb/1623/trust-credentials)
- [GitHub Actions OIDC Security](https://docs.github.com/en/actions/concepts/security/openid-connect)
- [GitHub OIDC Custom Claims Reference](https://docs.github.com/en/actions/reference/openid-connect-reference)
- [Tailscale GitHub OIDC Blog Post](https://tailscale.com/blog/oidc-github-actions/)
