#!/bin/sh
#
set -x

## Uninstall old release
sudo /usr/local/bin/k3s-uninstall.sh

## Install k3s and start it
curl -sfL https://get.k3s.io | sh - 

## Stop k3s
sudo systemctl stop k3s

## Copy new config
sudo cp k3s/config.yaml /etc/rancher/k3s/config.yaml

## Restart k3s
sudo systemctl start k3s