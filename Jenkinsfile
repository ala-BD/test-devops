pipeline {
    agent any
    
    environment {
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE = 'test-devops-ala'
        DOCKER_TAG = "build-${BUILD_NUMBER}"
    }
    
    stages {
        // ÉTAPE 1: PRÉPARATION
        stage('Préparation') {
            steps {
                echo '🚀 Démarrage du pipeline Docker'
                echo "Build: ${BUILD_NUMBER}"
                echo "Image: ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                
                sh '''
                    echo "Vérification Docker..."
                    docker --version
                '''
            }
        }
        
        // ÉTAPE 2: VÉRIFICATION
        stage('Vérification') {
            steps {
                sh '''
                    echo "Contenu du répertoire:"
                    ls -la
                    
                    echo ""
                    echo "Vérification Dockerfile:"
                    if [ -f "Dockerfile" ]; then
                        echo "✅ Dockerfile trouvé"
                        cat Dockerfile
                    else
                        echo "❌ Dockerfile manquant"
                        exit 1
                    fi
                '''
            }
        }
        
        // ÉTAPE 3: TEST CREDENTIALS
        stage('Test Login Docker') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-hub-ala',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "Test connexion Docker Hub..."
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                        echo "✅ Connecté à Docker Hub"
                        docker logout
                    '''
                }
            }
        }
        
        // ÉTAPE 4: BUILD
        stage('Build Image') {
            steps {
                sh """
                    echo "Construction image Docker..."
                    docker build -t ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                    echo "✅ Image construite"
                    
                    echo "Images disponibles:"
                    docker images | grep ${DOCKER_USER} || true
                """
            }
        }
        
        // ÉTAPE 5: TEST
        stage('Test Image') {
            steps {
                sh """
                    echo "Test de l'image..."
                    docker run --rm ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG}
                    echo "✅ Test réussi"
                """
            }
        }
        
        // ÉTAPE 6: PUSH
        stage('Push Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-hub-ala',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "Connexion Docker Hub..."
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                        
                        echo "Push image..."
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                        
                        echo "✅ Image poussée sur Docker Hub"
                        docker logout
                    '''
                }
            }
        }
        
        // ÉTAPE 7: FINAL
        stage('Final') {
            steps {
                echo "✅ PIPELINE RÉUSSIE!"
                echo ""
                echo "📊 RÉSUMÉ:"
                echo "Build: #${BUILD_NUMBER}"
                echo "Image: ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                echo "Docker Hub: https://hub.docker.com/r/${DOCKER_USER}/${DOCKER_IMAGE}"
                
                sh '''
                    echo "Nettoyage..."
                    docker rmi ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG} 2>/dev/null || true
                    docker rmi ${DOCKER_USER}/${DOCKER_IMAGE}:latest 2>/dev/null || true
                '''
            }
        }
    }
    
    post {
        success {
            echo '🎉 SUCCÈS COMPLET!!'
        }
        failure {
            echo '❌ ÉCHEC - Vérifiez les logs'
        }
    }
}
