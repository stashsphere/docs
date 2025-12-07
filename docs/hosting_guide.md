# Hosting Guide

## General

This guide will use several domain names for example, we suggest to use
a similar setup to avoid common problems such as serving the API from
the same domain as the web application.

- example.com - your main domain
- stash.example.com - this is what users will navigate to in their browsers
- api.stash.example.com - the API is served from here

## Linux - Generic

### Requirements Backend

- libmagic / file
- go version >= 1.22
- libc (libmusl should work but not tested)

### Requirements Frontend

- pnpm
- TypeScript

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
      (sources.stashsphere + "/nix/module.nix")
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
        api = "stash.example.com";
        allowed = [ "https://api.stash.example.com" "https://stash.example.com" ];
      };
      frontendUrl = "https://stash.example.com";
      instanceName = "StashSphere";
    };
    configFiles = ["/private/stashsphere-secrets.yaml"];
  };
}
```

### Secrets

StashSphere allows to chain multiple `.yaml` files. That way config values can be
separated from secrets.
`services.stashsphere.settings` contains only config values.
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
