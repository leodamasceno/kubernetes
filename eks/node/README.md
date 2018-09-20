# Installing node

AWS provide an AMI so you can run EC2 instances and allow them to join the EKS cluster. It's fine for small infrastructures but what happens when you have custom scripts running and your own AMI? Well, you can run all your scripts with cloud-init or simply use your own AMI and use Puppet/Chef/Ansible to install the kubernetes client components. Use this shell script to install and configure kubelet and kube-proxy.

### Debian

This script was originally created to be run on Red Hat, I had to change it to run on Debian.

### Deploying the configmap

This configmap will allow all your users to have authenticate using IAM. Edit it and add the details of your AWS account. You will be the only one able to access the cluster because AWS automatically will give you *system:master* permissions. You will need to do the same for the other users to have access:
```
kubectl create -f configmap.yaml
```

### Configuring the node

Run the script below with the name of the cluster as a parameter:

```
bash script.sh dev-k8s-master
```
