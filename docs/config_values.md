# Config Values

The config of StashSphere consists of nested values that are represented as YAML.
It may be distributed across multiple files to split the config from secrets.
When executing the backend binary this may look like this:

```bash
backend serve --conf config.yaml --conf secrets.yaml
```

## Example config

This is an example config

*config.yaml*:

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
  - http://stash.example.com
  - http://api.stash.example.com
  own:
  - http://stash.example.com
frontendUrl:  "https://stash.example.com"
instanceName: "Example StashSphere"
```

*secrets.yaml*:

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
A new key can be generated using the command `backend genkey`.

## Image Store Path

You may omit `image.path` and `image.cachePath` which will result in a `image_store`
and `image_cache` directory created in the working directory of StashSphere.
Furthermore StashSphere will honor `STATE_DIRECTORY` and `CACHE_DIRECTORY`
environment variables.
