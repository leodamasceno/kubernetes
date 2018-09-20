#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

if [ -z "$1" ];
then
  exit 1
fi

if [ ! -d "/tmp/k8s_files" ];
then
  mkdir /tmp/k8s_files
fi

cp -r files/* /tmp/k8s_files/

apt-get update
apt-get install -y conntrack curl ntp socat unzip wget apt-transport-https ca-certificates curl software-properties-common

systemctl enable ntp

curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py
rm get-pip.py
pip install --upgrade awscli

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean false | debconf-set-selections
apt-get install -y iptables-persistent
iptables -P FORWARD ACCEPT
iptables-save > /etc/iptables/rules.ipv4

cp /tmp/k8s_files/iptables-restore.service /etc/systemd/system/iptables-restore.service
systemctl daemon-reload

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

cp /tmp/k8s_files/logrotate-kube-proxy /etc/logrotate.d/kube-proxy

mkdir -p /etc/kubernetes/manifests
mkdir -p /var/lib/kubernetes
mkdir -p /var/lib/kubelet
mkdir -p /opt/cni/bin

CNI_VERSION=${CNI_VERSION:-"v0.6.0"}
wget https://github.com/containernetworking/cni/releases/download/${CNI_VERSION}/cni-amd64-${CNI_VERSION}.tgz
tar -xvf cni-amd64-${CNI_VERSION}.tgz -C /opt/cni/bin
rm cni-amd64-${CNI_VERSION}.tgz

CNI_PLUGIN_VERSION=${CNI_PLUGIN_VERSION:-"v0.7.1"}
wget https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGIN_VERSION}/cni-plugins-amd64-${CNI_PLUGIN_VERSION}.tgz
tar -xvf cni-plugins-amd64-${CNI_PLUGIN_VERSION}.tgz -C /opt/cni/bin
rm cni-plugins-amd64-${CNI_PLUGIN_VERSION}.tgz

S3_URL_BASE="https://s3-us-west-2.amazonaws.com/amazon-eks/1.10.3/2018-07-26/bin/linux/amd64"

BINARIES=(
    kubelet
    kubectl
    aws-iam-authenticator
)
for binary in ${BINARIES[*]} ; do
    sudo wget $S3_URL_BASE/$binary
    sudo wget $S3_URL_BASE/$binary.sha256
    sudo sha256sum -c $binary.sha256
    sudo chmod +x $binary
    sudo mv $binary /usr/bin/
done

cp /tmp/k8s_files/kubelet-kubeconfig /var/lib/kubelet/kubeconfig

cp /tmp/k8s_files/kubelet.service /etc/systemd/system/kubelet.service

mkdir -p /etc/systemd/system/kubelet.service.d

systemctl daemon-reload

systemctl stop kubelet
systemctl stop docker
iptables --flush
iptables -tnat --flush

rm -rf /etc/cni/net.d/*flannel*

chmod +x /tmp/k8s_files/bootstrap.sh

bash /tmp/k8s_files/bootstrap.sh $1

systemctl start kubelet
systemctl start docker

iptables -P FORWARD ACCEPT
