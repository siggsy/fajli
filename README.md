# Fajli - a (secret) file generator for Nix

# About

**Fajli** is a program for generating and/or encrypting files per specification.
It aims to replace the need for tools like [sops](https://github.com/getsops/sops), by providing CLI for generating, editing and rekeying secrets.

# Main features

- Age encryption (symmetric and asymmetric)
- File generation using bash scripts
- DAG™ for specifying folder dependencies
- Simple end extensible interface

# Usage

This flake exposes `configure` function, which as a result gives package for `fajli`

```nix
inputs.fajli.configure {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    modules = [
        ({ lib, ... }:
        let
            recipients = [
                (lib.fajli.literal "age1tdzspj2xucz94nyr7wng576lcs2uux02hj0fs7a3n6l33ncuzyyq6cfqym")
                (lib.fajli.path "$HOME/age.pub")
            ];
        in
         {
            path = "vars";
            folders = {
                "your-secrets" = {
                    files = {
                        "public" = { age.enable = false; };
                        "secret" = { age.enable = true; inherit recipients; };
                    };

                    script = ''
                        echo "public var" > "$out/public"
                        echo "TOP SECRET" > "$out/private"
                    '';
                };
            };
        })
    ];
}
```

You can add this to your `packages` output in flakes and run `nix run .#fajli generate` which will produce the following in your project root:
```
vars
└──your-secrets
    ├── public
    └── secret.age
```

You can now edit these using `nix run .#fajli edit path-like`, where `path-like` can be either absolute path or relative path from `vars` directory. Some examples:

- `your-secrets/secret.age`
- `your-secrets/secret`
- `./vars/your-secrets/secret`
- ...

This allows you to use your shell's autocomplete.


# NixOS special module

As an example of extensibility, there is a `lib.fajli.modules.hosts` module, that provides an easy way to manage per-host and shared secrets, as well as simplified support for symmetric encryption.

It works by by first generating `host-keys` folder for each `host` that contains public and private keys, which are then used to encrypt other secrets.

Here is an example configuration:

```nix
{ pkgs, lib, ... }:
{
  imports = [
    lib.fajli.modules.hosts
  ];

  path = "vars";
  hosts = [
    "machine1"
    "machine2"
  ];

  # When using symmetric encryption, only identity files are used
  symmetricEncryption = true;

  # We have to specify "main" key, which we use to encrypt host-keys (and also all others)
  defaultIdentityFiles = [
    "$FAJLI_PROJ_ROOT/test/age.txt"
  ];

  # These folders will be generated for each host
  perHost = {
    "folder1" = {
      # We can also restrict for which hosts this folder should be generated
      # hosts = [ "machine1" ];

      files = {
        "file1" = {
          age.enable = false;
        };
        "file2" = {
          age.enable = true;
        };
      };

      script = ''
        echo "epik1" >> "$out/file1"
        echo "epik2" >> "$out/file2"
      '';
    };
  };

  # These folders will only be generated once and will be shared between hosts
  shared = {
    "shared1" = {
      files = {
        "file1" = {
          age.enable = false;
        };
        "file2" = {
          age.enable = true;
        };
      };

      script = ''
        echo "epik1" >> "$out/file1"
        echo "epik2" >> "$out/file2"
      '';
    };
  };
}
```

which produces the following structure:
```
vars
├── host-keys
│   ├── machine1
│   │   ├── private.age
│   │   └── public.age
│   └── machine2
│       ├── private.age
│       └── public.age
├── per-host
│   ├── machine1
│   │   └── folder1
│   │       ├── file1
│   │       └── file2.age
│   └── machine2
│       └── folder1
│           ├── file1
│           └── file2.age
└── shared
    └── shared1
        ├── file1
        └── file2.age
```

You can now use [agenix](https://github.com/ryantm/agenix) and to import these secrets.
If you're like me, and want to conditionally generate secrets for hosts, you can also pass extra parameters using `specialArgs` in `configure`. For example, you can pass your final nixos configurations:

```nix
configure {
    # ...
    specialArgs = {
      hostConfigs = builtins.mapAttrs (name: cfg: cfg.config) self.nixosConfigurations;
    };
    # ...
}
```

and use them as filter to only generate/encrypt secrets for hosts that need them:

```nix
{ hostConfigs, pkgs, lib, ... }:
let
  hostsWhere = pred: builtins.attrNames (lib.filterAttrs (host: cfg: pred cfg) hostConfigs);
in
{
  # ...
  perHost = {
    "secrets" = {
      hosts = hostsWhere (cfg: cfg.some.option.enable);
      # ...
    };
  }
}

```

For a real example see [my configuration](https://gitlab.com/siggsy/the-shire/-/blob/c3a617238a91864bcf421cde6267fd371c00509d/secrets/secrets.nix)


# Module options

see [generated docs](./docs/generated.md)


# Why

TODO
