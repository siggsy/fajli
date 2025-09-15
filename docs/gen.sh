#!/usr/bin/env bash

out=$(nix build .#docs --print-out-paths --no-link)


cp "$out/"* .
chmod +w hosts.md
chmod +w main.md
