#!/bin/bash
#
# Build script for CI builds on CentOS CI
set -ex

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

REPO_PATH=${GOPATH}/src/github.com/fabric8-services/fabric8-webhook
REGISTRY="quay.io"

function setup() {
    if [ -f jenkins-env.json ]; then
        eval "$(./env-toolkit load -f jenkins-env.json \
                ghprbActualCommit \
                ghprbPullAuthorLogin \
                ghprbGhRepository \
                ghprbPullId \
                GIT_COMMIT \
                FABRIC8_DEVCLUSTER_TOKEN \
                DEVSHIFT_TAG_LEN \
                QUAY_USERNAME \
                QUAY_PASSWORD \
                BUILD_URL \
                BUILD_ID)"
    fi

    # We need to disable selinux for now, XXX
    /usr/sbin/setenforce 0 || :

    yum install epel-release -y
    yum -y install --enablerepo=epel podman make golang git

    mkdir -p $(dirname ${REPO_PATH})
    cp -a ${HOME}/payload ${REPO_PATH}
    cd ${REPO_PATH}

    echo 'CICO: Build environment created.'
}

function tag_push() {
    local image="$1"
    local tag="$2"

    podman tag ${image}:latest ${image}:${tag}
    podman push ${image}:${tag} ${image}:${tag}
}

function deploy() {
  # Login first
  cd ${REPO_PATH}

  if [ -n "${QUAY_USERNAME}" -a -n "${QUAY_PASSWORD}" ]; then
      podman login -u ${QUAY_USERNAME} -p ${QUAY_PASSWORD} ${REGISTRY}
  else
      echo "Could not login, missing credentials for the registry"
      exit 1
  fi

  # Build fabric8-webhook
  make image

  TAG=$(echo $GIT_COMMIT | cut -c1-${DEVSHIFT_TAG_LEN})
  if [ "$TARGET" = "rhel" ]; then
    tag_push ${REGISTRY}/openshiftio/rhel-fabric8-services-fabric8-webhook $TAG
    tag_push ${REGISTRY}/openshiftio/rhel-fabric8-services-fabric8-webhook latest
  else
    tag_push ${REGISTRY}/openshiftio/fabric8-services-fabric8-webhook $TAG
    tag_push ${REGISTRY}/openshiftio/fabric8-services-fabric8-webhook latest
  fi

  echo 'CICO: Image pushed, ready to update deployed app'
}

function compile() {
    make build
}

function do_coverage() {
    make coverage

    # Upload to codecov
    bash <(curl -s https://codecov.io/bash) -K -X search -f tmp/coverage.out -t 42dafca1-797d-48c5-95bf-2b17cf7f5d96
}

function do_test() {
    make test-unit
}
