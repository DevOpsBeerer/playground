#!/bin/sh
#
set -x

## Uninstall old release
sudo /usr/local/bin/k3s-uninstall.sh

## Copy new config
sudo mkdir -p /etc/rancher/k3s/
sudo cp k3s/config.yaml /etc/rancher/k3s/config.yaml

## Install k3s and start it
curl -sfL https://get.k3s.io | sh -
