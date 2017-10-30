#!/bin/sh
set -e
BOOTSRAP_REPO="https://github.com/metacoma/aws-minikube.git"
TMP_DIR=`mktemp -u /tmp/minikube-bootstrap.XXXXXXXX`

linux_distro() {
  echo "Ubuntu 16.04"
}
echo $TMP_DIR
case `linux_distro` in
  "Ubuntu 16.04")
    sudo sh -c 'apt-get update && sudo apt install -y git python-pip && pip install ansible==2.3.0.0'
    git clone --depth 1 ${BOOTSRAP_REPO} ${TMP_DIR}
    cd ${TMP_DIR}
    sudo ansible-galaxy install -r ./requirements.yml
    ansible-playbook -vvvv playbook.yml >ansible.log 2>&1
  ;;
  "Centos 7")
  ;;
  *)
    echo "Unknown distro"
    exit 1
  ;;
esac
