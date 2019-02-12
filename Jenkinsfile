@Library('github.com/khrm/osio-pipeline@dockerfile-podman') _

osio {

  config runtime: 'go'

  ci {
    build resources: [ImageStream:"podman-docker-test:latest"], strategy: [type: docker, file: "./Dockerfile"]

  }
  
  
  cd {

    build resources:  [ImageStream:"podman-docker-test:latest"],

    deploy resources:  [ImageStream:"podman-docker-test:latest"],, env: 'stage'

    deploy resources:  [ImageStream:"podman-docker-test:latest"],, env: 'run', approval: 'manual'

  } 
  
}
