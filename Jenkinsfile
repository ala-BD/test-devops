pipeline {
    agent any
    
    stages {
        stage('Bonjour Ala') {
            steps {
                echo '👋 Salut Ala! Ta pipeline Jenkins fonctionne!'
                echo "Branche: Ala"
                echo "Build: ${BUILD_NUMBER}"
            }
        }
        
        stage('Vérifier le projet') {
            steps {
                sh '''
                    echo "Voici ton projet:"
                    pwd
                    echo "Fichiers:"
                    ls -la
                '''
            }
        }
        
        stage('Test réussi') {
            steps {
                echo '✅ Tout est OK!'
                echo '🎯 Pipeline fonctionnelle pour la branche Alaa'
            }
        }
    }
}
