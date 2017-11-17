# Minikube examples

## Installing components:
To install the YAML componentes listed here, you will need to run the kubectl command. Check the example below:
```
kubectl create -f ingress.yaml
```

All the shell scripts in this repository should be downloaded and executed after the execution permission has been given. Make sure you have permissions to execute it in your system:
```
chmod +x script.sh
./script.sh
```

### Examples
All the examples in this repostory are listed below:
- ingress.yaml: You will be able to create an ingress rule with this file. Edit it to specify the host and the name of the components. The documentation can be found [here](https://kubernetes.io/docs/concepts/services-networking/ingress)
- install_minikube_debian.sh: Use this script to install and start minikube on your Debian system
- install_minikube_mac.sh: This script can be used to install minikube on your Mac OS

## Important commands
Minikube status:
```
# minikube status
```

Starting Minikube:
```
# minikube start
```

Destroying Kubernetes cluster:
```
minikube delete
```

Checking if the node is ready:
```
# kubectl get nodes
```
