pipeline {
    agent any
    
    stages {
        stage('Hello') {
            steps {
                echo 'Hello World!'
            }
        }
        
        stage('GIT') {
            steps {
                git branch: 'Ala', 
                url: 'https://github.com/ala-BD/test-devops.git'
                echo 'Code récupéré depuis Git avec succès'
            }
        }
        
        stage('MAVEN') {
            steps {
                script {
                    if (fileExists('pom.xml')) {
                        sh 'mvn clean compile'
                        echo 'Build Maven réussi'
                    } else {
                        error 'Fichier pom.xml non trouvé'
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    if (fileExists('pom.xml')) {
                        sh 'mvn test'
                        echo 'Tests exécutés avec succès'
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline terminé'
        }
        success {
            echo 'Pipeline réussi!'
        }
        failure {
            echo 'Pipeline échoué'
        }
    }
}
