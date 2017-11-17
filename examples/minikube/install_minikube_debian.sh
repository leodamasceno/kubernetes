#!/bin/bash

DIRMNGR_BIN=$(which dirmngr)
CURL_BIN=$(which curl)
DOCKER_BIN=$(which docker)
MINIKUBE_BIN=$(which minikube)
KUBECTL_BIN=$(which kubectl)

function checkDependencies() {
  if [ "$DIRMNGR_BIN" == "" ];
  then
    apt-get install -y dirmngr
  fi

  if [ "$CURL_BIN" == "" ];
  then
    apt-get install -y curl
  fi

  if [[ $(dpkg -l apt-transport-https 2> /dev/null) -ne 0 ]];
  then
    apt-get install -y apt-transport-https
  fi
}

function setHost() {
  GET_INTERFACE=$(ip -o link show | sed -rn '/^[0-9]+: en/{s/.: ([^:]*):.*/\1/p}')
  IP_ADDRESS=$(ip addr li $GET_INTERFACE | grep -Po '(?<=inet )[0-9\.]+')
  echo "" >> /etc/hosts
  echo "# Minikube test" >> /etc/hosts
  echo "$IP_ADDRESS test.example.com" >> /etc/hosts
}

function checkDockerInstallation() {
  if [ "$DOCKER_BIN" == "" ];
  then
    echo "Installing Docker"
    echo 'deb https://apt.dockerproject.org/repo debian-stretch main' >> /etc/apt/sources.list
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    apt-get update
    apt-get install -y docker-engine
  fi
}

function checkBinaries() {
  if [ "$MINIKUBE_BIN" == "" ];
  then
    echo "Downloading Minikube binary"
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && mv minikube /usr/local/bin/
  fi

  if [ "$KUBECTL_BIN" == "" ];
  then
    echo "Downloading Kubectl binary"
    curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/
  fi
}

function checkKubeConfig() {
  if [ ! -d "$HOME/.kube" ];
  then
    mkdir $HOME/.kube
    touch $HOME/.kube/config
  else
    if [ ! -e "$HOME/.kube/config" ];
    then
      touch $HOME/.kube/config
    fi
  fi
}

echo "Running apt-get update"
apt-get -y update

echo "Checking dependencies"
checkDependencies

echo "Checking Docker installation"
checkDockerInstallation

echo "Checking Minikube and Kubectl binaries"
checkBinaries

echo "Setting up Minikube variables"
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true

echo "Looking for previous Kube configuration"
checkKubeConfig

echo "Starting Minikube"
export KUBECONFIG=$HOME/.kube/config
minikube start --vm-driver=none
