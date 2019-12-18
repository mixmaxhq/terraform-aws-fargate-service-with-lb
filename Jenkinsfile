pipeline {
  agent {
    docker {
      image 'hashicorp/terraform:0.12.12'
      args  '--entrypoint="" -u root'
    }
  }

  stages {
    stage('Lint & validate') {
      steps {
        sh 'terraform fmt -check -no-color -recursive'
        sh 'terraform fmt -check -no-color -recursive examples/simple'
        withCredentials([sshUserPrivateKey(credentialsId: 'mixmax-bot-github-ssh', keyFileVariable: 'SSH_KEY')]) {
          // The following line ensures there is no existing .ssh folder.
          // It should not exist but I really want to be defensive here.
          sh 'test ! -d ~/.ssh'
          sh 'mkdir ~/.ssh'
          sh 'chmod 700 ~/.ssh'
          sh 'echo "Host github.com" >> ~/.ssh/config'
          sh 'echo "  User git" >> ~/.ssh/config'
          sh 'echo "  IdentityFile $SSH_KEY" >> ~/.ssh/config'
          sh 'echo "  StrictHostKeyChecking accept-new" >> ~/.ssh/config'
          sh 'chmod 600 ~/.ssh/config'
          sh 'terraform init -no-color examples/simple'
          sh 'rm -rf ~/.ssh'
        }
        sh 'terraform validate -no-color examples/simple'
      }
    }
  }
}
