#!/bin/sh
set -e
BOOTSRAP_REPO="https://github.com/metacoma/aws-minikube.git"
TMP_DIR=`mktemp -u /tmp/minikube-bootstrap.XXXXXXXX`


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


wait_for_cloud_init
case `linux_distro` in
  "Ubuntu 16.04")
    sudo sh -c 'apt-get update && sudo apt install -y git python-pip && pip install ansible==2.3.0.0'
    git clone --depth 1 ${BOOTSRAP_REPO} ${TMP_DIR}
    cd ${TMP_DIR}
    sudo ansible-galaxy install -r ./requirements.yml
    ansible-playbook -vvvv -t any playbook.yml 2>&1 | tee ansible.log
    echo http://`curl ipecho.net/plain`:`kubectl -n k8spray get svc nginx-basic-auth-k8spray -o jsonpath='{.spec.ports[0].nodePort}'`
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
