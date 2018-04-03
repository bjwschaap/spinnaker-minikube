#!/bin/bash
set -xe -o pipefail

# XXX this should break the deployment on amazon
BOOTSTRAP_REPO="https://github.com/metacoma/aws-minikube.git"
#BOOTSTRAP_REPO="http://localhost:10080/bebebeko/k8spray.git"
TMP_DIR=`mktemp -u /tmp/minikube-bootstrap.XXXXXXXX`

export LC_ALL=C

env

linux_distro() {
  echo "Ubuntu 16.04"
}
wait_for_cloud_init() {
  test -d /var/lib/cloud/instance || return 0
  while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo -e "\033[1;36mWaiting for cloud-init..."
    sleep 1
  done
}

myip() {
  dig +short myip.opendns.com @resolver1.opendns.com
}

wait_for_cloud_init
case `linux_distro` in
  "Ubuntu 16.04")
    sudo sh -c 'apt-get update && sudo apt install -y git python-pip && pip install ansible==2.5.0.0'
    git clone ${BOOTSTRAP_REPO} ${TMP_DIR}
    cd ${TMP_DIR}
    test -n "$CI_COMMIT_REF_NAME" && git checkout $CI_COMMIT_REF_NAME || :
    sudo apt-get --auto-remove --yes remove python-openssl && sudo pip install pyOpenSSL
    sudo ansible-galaxy install -r ./requirements.yml
    ansible-playbook -vvvv playbook.yml 2>&1 | tee ansible.log
    echo http://`myip`:`kubectl -n k8spray get svc nginx-basic-auth-k8spray -o jsonpath='{.spec.ports[0].nodePort}'`
  ;;
  "Centos 7")
    echo "Not supported yet"
    exit 1
  ;;
  *)
    echo "Unknown distro"
    exit 1
  ;;
esac
