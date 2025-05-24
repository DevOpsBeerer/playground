#!/bin/sh
#
set -x

## Install the API
k3s kubectl create ns devopsbeerer-api
k3s kubectl apply -f deployments/api

## Install the frontoffice
k3s kubectl create ns devopsbeerer-frontoffice
k3s kubectl apply -f deployments/frontoffice
