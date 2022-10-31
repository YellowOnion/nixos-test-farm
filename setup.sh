#!/usr/bin/env bash


if [[ ! -v 1 ]]; then
    echo "please supply a name for the new machine"
    exit 1
fi
nixos-generate-config --root /mnt --dir ./tmp-config

# Replace host name.
sed -i 's/# networking.hostName = "nixos";/ networking.hostName = "'$1'";/' ./tmp-config/configuration.nix

# import common.nix
sed -i '/^      ./hardware-configuration.nix.*/a \        ./common.nix' ./tmp-config/configuration.nix

mv ./tmp-config/configuration.nix "./$1.nix"
mv ./tmp-config/hardware-configuration.nix "./$1-hw.nix"

ln -s "$1.nix" configuration.nix
ln -s "$1-hw.nix" hardware-configuration.nix
