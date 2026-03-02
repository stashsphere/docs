# Config Values

The config of StashSphere consists of nested values that are represented as YAML.
It may be distributed across multiple files to split the config from secrets.
When executing the backend binary this may look like this:

```bash
backend serve --conf config.yaml --conf secrets.yaml
```

## Example config

This is an example config

_config.yaml_:

```yaml
database:
  user: "stashsphere"
  name: "stashsphere"
  host: "127.0.0.1"
listenAddress: ":8081"
image:
  path: "/var/lib/stashsphere/images"
  cachePath: "/var/lib/stashsphere/cache"
invites:
  enabled: false
domains:
  allowed:
    - https://stash.example.com
    - https://api.stash.example.com
  cookieDomain: stash.example.com
frontendUrl: "https://stash.example.com"
baseUrl: "https://api.stash.example.com"
instanceName: "Example StashSphere"
auth:
  disableSecureCookies: true
  oidc:
    enabled: false
userDeletion:
  gracePeriodMinutes: 180
```

_secrets.yaml_:

```yaml
auth:
  privateKey: "Ntfv8wiEuAhDcQyJRE4p3fSqLRBxhImY/H1DnEAO4RnkKQrWLyVAOZQIcDNiVKRywOrUJwZry67H+vK1cc6BDw"
email:
  backend: "smtp"
  fromAddr: "StashSphere <noreply@example.com>"
  user: "noreply@example.com"
  password: "secret"
  host: "mail.example.com"
  port: 587
```

## auth.privateKey

This key is used to sign JWT tokens to be served as cookies.
A new key can be generated using the command `stashsphere genkey`.

## Image Store Path

You may omit `image.path` and `image.cachePath` which will result in a `image_store`
and `image_cache` directory created in the working directory of StashSphere.
Furthermore StashSphere will honor `STATE_DIRECTORY` and `CACHE_DIRECTORY`
environment variables.

## URL Configuration

StashSphere uses multiple URLs for different purposes.

### frontendUrl

The URL where users access the web interface in their browser.

**Used for**: Email links

**Example**: `"https://stash.example.com"`

### baseUrl

The public URL where the backend API is accessible.

**Used for**: OIDC callback URLs (`{baseUrl}/api/auth/oidc/{provider}/callback`)

**Example**: `"https://api.stash.example.com"`

### domains.allowed

Array of origins allowed to make CORS requests to the API. Include both frontend
and API URLs.

**Example**:

```yaml
domains:
  allowed:
    - "https://stash.example.com"
    - "https://api.stash.example.com"
```

### domains.api

deprecated, see `domains.cookieDomain`

### domains.cookieDomain

Domain used for setting authentication cookies. For split subdomains (e.g., stash.example.com
and api.stash.example.com), use the parent domain to allow cookie sharing.

Example: `"stash.example.com"` (not `"api.stash.example.com"`)
