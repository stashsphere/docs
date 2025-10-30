# Hosting Guide

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
