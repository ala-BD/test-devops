peline {
    agent any

    tools {
        maven 'M2_HOME'
    }

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World!'
            }
        }

        stage('GIT') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/ala-BD/test-devops/'
            }
        }

        stage('MAVEN') {
            steps {
                sh 'mvn --version'
            }
        }
    }
}
