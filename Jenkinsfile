pipeline {
    agent any
    
    environment {
        DOCKER_HUB_USER = 'alabendawed871'
        DOCKER_IMAGE_NAME = 'test-devops-ala'
        DOCKER_TAG = "build-${BUILD_NUMBER}"
        DOCKER_REPO = "${DOCKER_HUB_USER}/${DOCKER_IMAGE_NAME}"
    }
    
    stages {
        stage('Préparation') {
            steps {
                echo '🚀 Démarrage du pipeline CI/CD Docker'
                echo "Build: ${BUILD_NUMBER}"
                echo "Branche: Ala"
                echo "Repo Docker: ${DOCKER_REPO}:${DOCKER_TAG}"
                echo "Compte: alabendawed871"
            }
        }
        
        stage('Vérification du code') {
            steps {
                sh '''
                    echo "📁 Contenu du répertoire:"
                    pwd
                    ls -la
                    
                    echo "📄 Vérification du Dockerfile:"
                    if [ -f "Dockerfile" ]; then
                        echo "✅ Dockerfile trouvé!"
                        cat Dockerfile
                    else
                        echo "❌ ERREUR: Dockerfile non trouvé!"
                        exit 1
                    fi
                '''
            }
        }
        
        stage('Build de l\'image Docker') {
            steps {
                script {
                    echo "🔨 Construction de l'image Docker..."
                    
                    // CORRECTION ICI : ID des credentials
                    dockerImage = docker.build("${DOCKER_REPO}:${DOCKER_TAG}")
                    
                    echo "✅ Image construite localement: ${DOCKER_REPO}:${DOCKER_TAG}"
                    
                    sh 'docker images | grep alabendawed871 || echo "Aucune image trouvée"'
                }
            }
        }
        
        stage('Test de l\'image Docker') {
            steps {
                script {
                    echo "🧪 Test de l'image Docker..."
                    sh """
                        docker run --rm ${DOCKER_REPO}:${DOCKER_TAG} echo "✅ Image fonctionnelle!" || echo "⚠️  Test échoué"
                    """
                }
            }
        }
        
        stage('Push vers Docker Hub') {
            steps {
                script {
                    echo "⬆️  Pushing vers Docker Hub..."
                    echo "🔗 Destination: https://hub.docker.com/r/alabendawed871/"
                    
                    // CORRECTION CRITIQUE : 'docker-hub-ala' au lieu de 'docker-hub-credentials'
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-ala') {
                        dockerImage.push("${DOCKER_TAG}")
                        dockerImage.push("latest")
                        echo "🎉 Image poussée sur Docker Hub avec succès!"
                    }
                }
            }
        }
        
        stage('Vérification finale') {
            steps {
                script {
                    echo "🔍 Vérification sur Docker Hub..."
                    echo "URL: https://hub.docker.com/r/alabendawed871/${DOCKER_IMAGE_NAME}"
                }
            }
        }
    }
    
    post {
        always {
            echo "📊 Pipeline terminée - Build #${BUILD_NUMBER}"
        }
        success {
            echo "✅ SUCCÈS: Image Docker poussée sur Docker Hub!"
            echo "🐳 Image: ${DOCKER_REPO}:${DOCKER_TAG}"
        }
        failure {
            echo "❌ ÉCHEC: Vérifiez les permissions Docker et les credentials"
        }
    }
}
