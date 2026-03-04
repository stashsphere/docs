# Hosting Guide

## General

This guide will use several domain names for example, we suggest to use
a similar setup to avoid common problems such as serving the API from
the same domain as the web application.

- example.com - your main domain
- stash.example.com - this is what users will navigate to in their browsers
- api.stash.example.com - the API is served from here

### Secrets

StashSphere allows to chain multiple `.yaml` files. That way config values can be
separated from secrets.
Other values are provided using raw `.yaml` files which need to be
written & deployed manually or with tools like `colmena`.

The `.yaml` file above might look like this

```yaml
auth:
  privateKey: "3LX1ULUk+Uqm1uFpQoPcb8k8JqOp5K1KfYWs7LrFGQrWNmOQz/JcqYx5Z/vRGodTs/XFjZs/xjwc5eEMTq03Bw"
invites:
  enabled: true
  code: "letmein"
email:
  backend: "smtp"
  fromAddr: "StashSphere <noreply@example.com>"
  user: "noreply@example.com"
  password: "123"
  host: "mail.example.com"
  port: 587
```

### Security

StashSphere uses cookies for authentication. By default, the sensitive cookies are
stored as [`Secure Cookies`](https://developer.mozilla.org/en-US/docs/Web/Security/Practical_implementation_guides/Cookies#secure).
This is requires `https` which is strongly advised for production environments anyway.
Of course in development scenarios this is usually not desired, you can can therefore
disable as follows.

```yaml
auth:
  disableSecureCookies: true
```

Furthermore most cookies are `http-only` to protect credentials leaking into
the frontend.
Note that all authentication cookies have their non-authenticating sibling
that contain the same information (JWT) but do not authenticate the user,
instead they are used by the frontend to determine the login status.

### OpenID Connect

OpenID Connect support can enabled by adding

```yaml
baseUrl: "https://api.stash.example.com"
auth:
  oidc:
    enabled: true
    providers:
      - name: "dex"
        display_name: "Dex"
        issuer_url: "https://id.example.com/dex"
        client_id: "StashSphere"
        client_secret: "StashSecure"
        scopes:
          - "openid"
          - "profile"
          - "email"
```

Make sure that you set `baseURL` properly as this is used to construct
the callback URI.

You can have both internal accounts and external accounts (OIDC) at the same time.
Should an external account with the same E-Mail address try to login to an existing
internal account, the user will be additionally prompted for the internal password.
This prevents account stealing by controlling an external account.

Note that no invite logic is implemented for OIDC accounts, all users
that have access to the application on the identity provider can create
and account and login.

#### Auth0

Enter the following URIs in the Auth0 management application:

**Application Login URI**: `https://stash.example.com/user/login`

**Allowed Callback URI**: `https://api.stash.example.com/api/auth/oidc/auth0/callback`

**Allowed Web Origins**: `https://stash.example.com`

In the config, add the following values:

```yaml
auth:
  oidc:
    enabled: true
    providers:
      - name: "auth0"
        display_name: "Auth0"
        issuer_url: "https://your-tentant.auth0.com/"
        client_id: "your_client_id"
        client_secret: "your_client_secret"
        scopes:
          - "openid"
          - "profile"
          - "email"
```

Be sure to include the trailing `/` in the `issuer_url`.

### User Management

User accounts are mostly self-managed, a user can

- create an account
- change the password (with knowledge of the current one)
- delete the account

Passwords resets via E-Mail are not implemented yet.

Admins can use the CLI command `stashsphere resetpassword` to force-reset a password
of an user and furthermore `stashsphere delete-user` to delete an account.

### Account Deletion

Account deletion is not immediate in order to prevent accidental actions. Instead,
the account is marked and is purged after a configurable amount of time (`userDeletion.gracePeriodMinutes`).

Accounts are deleted completely, all entities that belonged to the user are purged.

## Linux - Generic

### Requirements Backend

- libmagic / file
- go version >= 1.22
- libc (libmusl should work but not tested)

### Requirements Frontend

- pnpm
- TypeScript

### Obtain the source

The main repository is [github.com/stashsphere/stashsphere](https://github.com/stashsphere/stashsphere).
Currently it is rolling release until version `1.0.0` aka first stable release.

### Building the Backend

Build the backend binary with `go build -o stashsphere`, place resulting
binary in a directory of your choice, e.g. `/usr/local/bin/stashsphere`.

### Building the Frontend

Build the frontend using `pnpm build`. The resulting web application is in `/dist`.
Serve these files using a webserver.
Create a new file named `config.json` in the web root with the following content:

```json
{
  "apiHost":"https://api.stash.example.com"
}
```

This file will be used by the frontend to determine which API is responsible
for this instance.

### Running

- Create a new database and user for the application in a PostgreSQL instance.
- Create config files for the application, see [Config Values](/config_values)
  for more information.
- Be sure to generate a new private key using `stashsphere genkey` and paste it
  into the config.
- Use `stashsphere migrate` to migrate the database.
- Run the backend using `stashsphere serve`.

StashSphere comes without TLS/SSL support, you may listen locally and
use a reverse proxy for TLS/SSL.

A systemd service unit may look like this

```systemd
[Unit]
After=network.target postgresql.service

[Service]
CacheDirectory=stashsphere
DynamicUser=true
ExecStart=/usr/local/bin/stashsphere serve --conf /etc/stashsphere/stashsphere-secrets.yaml --conf /etc/stashsphere/settings.yaml
ExecStartPre=/usr/local/bin/stashsphere migrate --conf /etc/stashsphere/stashsphere-secrets.yaml --conf /etc/stashsphere/settings.yaml
MemoryDenyWriteExecute=true
PrivateDevices=true
ProtectSystem=strict
Restart=always
RestrictAddressFamilies=AF_INET
RestrictAddressFamilies=AF_INET6
RestrictAddressFamilies=AF_UNIX
RestrictNamespaces=true
RestrictSUIDSGID=true
RuntimeDirectory=stashsphere
StateDirectory=stashsphere
User=stashsphere

[Install]
WantedBy=multi-user.target
```

## NixOS

### Without flakes

Integrate the repository using `npins`, `niv` or `lon`.
Then add the corresponding overlay:

```nix
{ config, pkgs, ... }:
{
    nixpkgs.overlays = [
        import (sources.stashsphere + "/nix/overlay.nix")
    ];
}
```

and the module:

```nix
{
    imports = [
      (sources.stashsphere + "/backend/nix/module.nix")
    ];
}
```

### With flakes

TODO

### Configure the module

```nix
{
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "stashsphere" ];
    ensureUsers = [
      {
        name = "stashsphere";
        ensureDBOwnership = true;
      }
    ];
  };

  services.stashsphere = {
    enable = true;
    usesLocalPostgresql = true;
    settings = {
      listenAddress = ":3004";
      database = {
        host = "/run/postgresql";
        sslmode = "disable";
      };
      domains = {
        cookieDomain = "stash.example.com";
        allowed = [ "https://api.stash.example.com" "https://stash.example.com" ];
      };
      frontendUrl = "https://stash.example.com";
      baseUrl = "https://api.stash.example.com";
      instanceName = "StashSphere";
    };
    configFiles = ["/private/stashsphere-secrets.yaml"];
  };
}
```

### Colmena example

```nix
{
  deployment.keys = {
    "stashsphere-secrets.yaml" = {
      keyFile = ./stashsphere-secrets.yaml;
      destDir = "/private";
      user = "stashsphere";
      group = "root";
      permissions = "640";
      uploadAt = "post-activation";
    };
  };
}
```

## Docker

Build the docker container

```bash
podman build .
```

Create a full config `.yaml` and bind mount it to the container.
Furthermore, bind mount a volume for the image store. Be sure to correctly
point to it.

TODO: write `docker-compose.yml`
