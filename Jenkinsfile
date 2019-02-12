@Library('github.com/khrm/osio-pipeline@dockerfile-podman') _

osio {

  config runtime: 'go'

  ci {
    build resources: resources, strategy: [type: docker, file: "./Dockerfile"]

  }
  
  
  cd {

    build resources: resources

    deploy resources: resources, env: 'stage'

    deploy resources: resources, env: 'run', approval: 'manual'

  } 
  
}
