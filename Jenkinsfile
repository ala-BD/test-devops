pipeline {
    agent any
    
    stages {
        stage('Hello') {
            steps {
                echo 'Hello World!'
                sh 'echo "This is a simple test pipeline"'
            }
        }
        
        stage('System Info') {
            steps {
                sh 'echo "Current directory: $PWD"'
                sh 'whoami'
                sh 'uname -a'
            }
        }
        
        stage('Tools Check') {
            steps {
                script {
                    try {
                        sh 'java -version'
                    } catch (Exception e) {
                        echo 'Java not available11'
                    }
                    
                    try {
                        sh 'mvn --version'
                    } catch (Exception e) {
                        echo 'Maven not available'
                    }
                    
                    try {
                        sh 'git --version'
                    } catch (Exception e) {
                        echo 'Git not available'
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed'
        }
    }

}
