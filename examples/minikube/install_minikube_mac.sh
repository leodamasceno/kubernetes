#!/bin/bash

BREW_BIN=$(which brew)
MINIKUBE_BIN=$(which minikube)
KUBECTL_BIN=$(which kubectl)
VBOX_BIN=$(which virtualbox)

function checkDependencies() {
  if [ "$BREW_BIN" == "" ];
  then
    echo "Installing HomeBrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

function checkBinaries() {
  if [ "$MINIKUBE_BIN" == "" ];
  then
    echo "Downloading Minikube binary"
    brew cask install minikube
  fi

  if [ "$KUBECTL_BIN" == "" ];
  then
    echo "Downloading Kubectl binary"
    brew install kubectl
  fi

  if [ "$VBOX_BIN" == "" ];
  then
    echo "Downloading Virtualbox"
    brew cask install virtualbox
  fi
}


echo "Checking dependencies"
checkDependencies

echo "Checking Minikube and Kubectl binaries"
checkBinaries

echo "Starting Minikube"
minikube start
