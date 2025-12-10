pipeline {
    agent any
    
    environment {
        // UTILISEZ VOTRE NOM D'UTILISATEUR DOCKER HUB
        DOCKER_HUB_USER = 'alabendawed871'
        DOCKER_IMAGE_NAME = 'test-devops-ala'  // ou gardez 'alpine' si vous voulez mettre à jour votre image existante
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
                    
                    // OPTION 1: Si vous voulez mettre à jour votre image 'alpine'
                    // dockerImage = docker.build("alabendawed871/alpine:${DOCKER_TAG}")
                    
                    // OPTION 2: Créer une nouvelle image (recommandé pour les tests)
                    dockerImage = docker.build("${DOCKER_REPO}:${DOCKER_TAG}")
                    
                    echo "✅ Image construite localement: ${DOCKER_REPO}:${DOCKER_TAG}"
                    
                    // Lister les images
                    sh 'docker images | grep alabendawed871'
                }
            }
        }
        
        stage('Test de l\'image Docker') {
            steps {
                script {
                    echo "🧪 Test de l'image Docker..."
                    
                    // Test simple
                    sh """
                        echo "=== Test de l'image ==="
                        docker run --rm ${DOCKER_REPO}:${DOCKER_TAG} echo "✅ Image fonctionnelle!"
                    """
                }
            }
        }
        
        stage('Push vers Docker Hub') {
            steps {
                script {
                    echo "⬆️  Pushing vers Docker Hub..."
                    echo "🔗 Destination: https://hub.docker.com/r/alabendawed871/"
                    
                    // Se connecter à Docker Hub
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        // Push avec le tag du build
                        dockerImage.push("${DOCKER_TAG}")
                        
                        // Optionnel: aussi tagger comme latest
                        dockerImage.push("latest")
                        
                        echo "🎉 Image poussée sur Docker Hub avec succès!"
                        echo "📊 Tags: ${DOCKER_TAG} et latest"
                    }
                }
            }
        }
        
        stage('Vérification finale') {
            steps {
                script {
                    echo "🔍 Vérification sur Docker Hub..."
                    echo "Pour vérifier manuellement:"
                    echo "1. Allez sur https://hub.docker.com/r/alabendawed871/"
                    echo "2. Cherchez '${DOCKER_IMAGE_NAME}'"
                    echo "3. Vérifiez les tags: ${DOCKER_TAG} et latest"
                }
            }
        }
    }
    
    post {
        always {
            echo "📊 Pipeline terminée - Build #${BUILD_NUMBER}"
            sh 'docker images | grep -E "alabendawed871|REPOSITORY" || true'
        }
        success {
            echo "✅ SUCCÈS: Image Docker poussée sur Docker Hub!"
            echo "🐳 Image: ${DOCKER_REPO}:${DOCKER_TAG}"
            echo "🔗 Accès: https://hub.docker.com/r/alabendawed871/${DOCKER_IMAGE_NAME}"
            echo "📦 Pour tirer l'image: docker pull ${DOCKER_REPO}:${DOCKER_TAG}"
        }
        failure {
            echo "❌ ÉCHEC: Vérifiez les logs pour plus d'informations"
            echo "💡 Conseils:"
            echo "   - Vérifiez les credentials Docker Hub dans Jenkins"
            echo "   - Vérifiez que Docker est installé sur Jenkins"
            echo "   - Vérifiez les permissions Docker"
        }
    }
}
