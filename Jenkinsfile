node ('master') {
  //def app
  stage('Cloning Git') {
    /* Let's make sure we have the repository clined to our workspace */
    checkout scm
  }
  stage('Build-and-Tag') {
  sh 'echo Build-andTag'
    /* This builds the actual image; synonmous to
      * docker build on the command line */
    //app = docker.build("amrit96/snake")
  }
  stage('Post-to-dockerhub') {
  sh 'echo Post-to-dockerhub'
   /* docker.withRegistery('https://registry.hub.docker.com', dockerhub') {
      app.push("latest")
        }*/
      }
  stage('Pull-image-server')
  sh 'echo pull image-server'
     /* sh "docker-compose down"
      sh "docker-compose up -d" */
      
      }
}
