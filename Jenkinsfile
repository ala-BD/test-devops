pipeline {
    agent any
    
    environment {
        // Variables Docker
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
                echo "Compte: ${DOCKER_HUB_USER}"
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
                        echo "Contenu:"
                        head -20 Dockerfile
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
                    
                    // Construction de l'image Docker
                    def dockerImage = docker.build("${DOCKER_REPO}:${DOCKER_TAG}")
                    
                    echo "✅ Image construite localement: ${DOCKER_REPO}:${DOCKER_TAG}"
                    
                    // Lister les images
                    sh """
                        echo "📦 Images Docker locales:"
                        docker images | grep -E "${DOCKER_HUB_USER}|REPOSITORY" || echo "Aucune image trouvée pour ${DOCKER_HUB_USER}"
                    """
                }
            }
        }
        
        stage('Test de l\'image Docker') {
            steps {
                script {
                    echo "🧪 Test de l'image Docker..."
                    sh """
                        echo "=== Démarrage du test ==="
                        docker run --rm ${DOCKER_REPO}:${DOCKER_TAG} echo "✅ Image Docker fonctionnelle!"
                        echo "=== Test terminé avec succès ==="
                    """
                }
            }
        }
        
        stage('Push vers Docker Hub') {
            steps {
                script {
                    echo "⬆️  Pushing vers Docker Hub..."
                    echo "🔗 Destination: https://hub.docker.com/r/${DOCKER_HUB_USER}/"
                    echo "🔑 Utilisation des credentials: docker-hub-ala"
                    
                    try {
                        // Se connecter à Docker Hub et pousser l'image
                        docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-ala') {
                            // Tag supplémentaire pour latest
                            sh """
                                docker tag ${DOCKER_REPO}:${DOCKER_TAG} ${DOCKER_REPO}:latest
                                echo "🏷️  Image taggée: latest"
                            """
                            
                            // Pousser avec le tag du build
                            dockerImage.push("${DOCKER_TAG}")
                            echo "📤 Image poussée avec tag: ${DOCKER_TAG}"
                            
                            // Pousser le tag latest
                            dockerImage.push("latest")
                            echo "📤 Image poussée avec tag: latest"
                            
                            echo "🎉 Image poussée sur Docker Hub avec succès!"
                            echo "🔗 URL: https://hub.docker.com/r/${DOCKER_HUB_USER}/${DOCKER_IMAGE_NAME}"
                        }
                    } catch (Exception e) {
                        echo "❌ Erreur lors du push: ${e.getMessage()}"
                        echo "💡 Vérifiez:"
                        echo "   1. Les credentials Docker Hub dans Jenkins"
                        echo "   2. Le token Docker Hub (Read/Write/Delete permissions)"
                        echo "   3. La connexion internet"
                        error("Échec du push Docker Hub")
                    }
                }
            }
        }
        
        stage('Nettoyage') {
            steps {
                script {
                    echo "🧹 Nettoyage des images locales..."
                    sh """
                        # Supprimer les images locales pour économiser de l'espace
                        docker rmi ${DOCKER_REPO}:${DOCKER_TAG} || true
                        docker rmi ${DOCKER_REPO}:latest || true
                        echo "✅ Images locales nettoyées"
                    """
                }
            }
        }
        
        stage('Vérification finale') {
            steps {
                script {
                    echo "🔍 Vérification finale..."
                    echo "✅ Pipeline exécutée avec succès!"
                    echo "🐳 Image Docker: ${DOCKER_REPO}:${DOCKER_TAG}"
                    echo "🔗 Accès sur Docker Hub: https://hub.docker.com/r/${DOCKER_HUB_USER}/${DOCKER_IMAGE_NAME}"
                    echo "🏷️ Tags disponibles: ${DOCKER_TAG} et latest"
                    echo ""
                    echo "📋 Pour utiliser l'image:"
                    echo "   docker pull ${DOCKER_REPO}:latest"
                    echo "   docker run --rm ${DOCKER_REPO}:latest"
                }
            }
        }
    }
    
    post {
        always {
            echo "📊 Pipeline terminée - Build #${BUILD_NUMBER}"
            echo "⏱️  Date: ${new Date().format('yyyy-MM-dd HH:mm:ss')}"
        }
        success {
            echo "✅ SUCCÈS COMPLET!"
            echo "🎯 Objectif atteint: Image Docker automatiquement créée et poussée sur Docker Hub"
            echo "📈 Prochain build automatique au prochain changement GitHub"
        }
        failure {
            echo "❌ ÉCHEC: Pipeline interrompue"
            echo "💡 Solutions possibles:"
            echo "   1. Vérifiez les credentials Docker Hub (ID: docker-hub-ala)"
            echo "   2. Vérifiez le token Docker Hub (permissions Read/Write/Delete)"
            echo "   3. Vérifiez la connexion internet"
            echo "   4. Vérifiez que Jenkins a accès à Docker (sudo -u jenkins docker ps)"
        }
        unstable {
            echo "⚠️  Pipeline instable - vérifiez les tests"
        }
    }
}
