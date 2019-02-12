@Library('github.com/khrm/osio-pipeline@dockerfile-podman') _

osio {

  config runtime: 'go'

  ci {

    def resources = processTemplate(params: [
          RELEASE_VERSION: "1.0.${env.BUILD_NUMBER}"
    ])

    build resources: resources, strategy: [type: docker, file: "./Dockerfile"]

  }
  
  
  cd {

    def resources = processTemplate(params: [
          RELEASE_VERSION: "1.0.${env.BUILD_NUMBER}"
    ])

    build resources: resources

    deploy resources: resources, env: 'stage'

    deploy resources: resources, env: 'run', approval: 'manual'

  } 
  
}
