# Agent notes

## 1Password

Vault **1Password** is secrets only, not config. Charts use item **titles**, never UUIDs.

- Titles: `{provider}.{kind}` — `github.ghcr-pull`, `cloudflare.api-token`
- Single token: field `credential` (ESO `title/credential`)
- Key pairs keep named fields (`access_key_id` / `secret_access_key`, …)
- Usernames, hostnames, replica counts: Helm values
