pipeline {
    agent any
    
    environment {
        // Variables Docker
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE_NAME = 'test-devops-ala'
        DOCKER_TAG = "build-${BUILD_NUMBER}"
        DOCKER_REPO = "${DOCKER_USER}/${DOCKER_IMAGE_NAME}"
        DOCKER_CREDENTIALS_ID = 'docker-hub-ala'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds()
        timeout(time: 20, unit: 'MINUTES')
    }
    
    stages {
        // STAGE 1: INITIALISATION
        stage('🔧 Initialisation') {
            steps {
                echo '🚀 DÉMARRAGE PIPELINE DOCKER CI/CD'
                echo "========================================"
                echo "📊 Build Number: #${BUILD_NUMBER}"
                echo "👤 Docker User: ${DOCKER_USER}"
                echo "🐳 Image: ${DOCKER_REPO}:${DOCKER_TAG}"
                echo "🔑 Credentials ID: ${DOCKER_CREDENTIALS_ID}"
                echo "========================================"
                
                script {
                    // Vérification de base
                    sh '''
                        echo "=== VÉRIFICATION SYSTÈME ==="
                        echo "Date: $(date)"
                        echo "User: $(whoami)"
                        echo "Docker version:"
                        docker --version
                        echo ""
                        echo "Espace disque:"
                        df -h . | head -2
                    '''
                }
            }
        }
        
        // STAGE 2: VÉRIFICATION DU CODE
        stage('📁 Vérification Code') {
            steps {
                sh '''
                    echo "=== 📂 CONTENU DU PROJET ==="
                    echo "Répertoire: $(pwd)"
                    echo ""
                    echo "Liste fichiers:"
                    ls -la
                    echo ""
                    echo "=== 🐳 DOCKERFILE ==="
                    if [ -f "Dockerfile" ]; then
                        echo "✅ Dockerfile trouvé!"
                        echo "Contenu complet:"
                        cat Dockerfile
                    else
                        echo "❌ ERREUR: Dockerfile manquant!"
                        exit 1
                    fi
                    echo ""
                    echo "=== 📋 FICHIERS SOURCE ==="
                    find . -name "*.java" -o -name "*.py" -o -name "*.js" -o -name "*.txt" | head -10 || echo "Aucun fichier source spécifique"
                '''
            }
        }
        
        // STAGE 3: TEST CREDENTIALS DOCKER
        stage('🔐 Test Authentification') {
            steps {
                script {
                    echo "=== 🔐 TEST CREDENTIALS DOCKER HUB ==="
                    
                    withCredentials([
                        usernamePassword(
                            credentialsId: DOCKER_CREDENTIALS_ID,
                            usernameVariable: 'DOCKER_HUB_USER',
                            passwordVariable: 'DOCKER_HUB_TOKEN'
                        )
                    ]) {
                        sh '''
                            echo "Username: ${DOCKER_HUB_USER}"
                            echo "Token (premiers chars): ${DOCKER_HUB_TOKEN:0:10}..."
                            
                            # Nettoyage préalable
                            docker logout 2>/dev/null || true
                            
                            # TEST CRITIQUE: CONNEXION DOCKER HUB
                            echo ""
                            echo ">>> Tentative de connexion à Docker Hub..."
                            if echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USER}" --password-stdin; then
                                echo "✅ ✅ ✅ CONNEXION RÉUSSIE À DOCKER HUB!"
                                echo "🎉 Les credentials sont VALIDES!"
                                
                                # Vérification supplémentaire
                                echo ""
                                echo "=== VÉRIFICATION ==="
                                docker info 2>/dev/null | grep -E "Username:|Registry:" || echo "Info Docker disponible"
                                
                                # Petit test
                                echo "Test rapide pull..."
                                docker pull hello-world 2>&1 | grep -E "Pulling|Downloaded|Status" || true
                                
                                # Déconnexion pour la suite
                                docker logout
                                echo "✅ Prêt pour la suite!"
                            else
                                echo "❌ ❌ ❌ ÉCHEC CONNEXION DOCKER HUB"
                                echo "💡 Problème probable:"
                                echo "   1. Token invalide/expiré"
                                echo "   2. Mauvais username"
                                echo "   3. Problème réseau"
                                echo ""
                                echo "⚠️  Vérifiez les credentials dans Jenkins:"
                                echo "   Manage Jenkins → Manage Credentials → ${DOCKER_CREDENTIALS_ID}"
                                exit 1
                            fi
                        '''
                    }
                }
            }
        }
        
        // STAGE 4: BUILD DOCKER IMAGE
        stage('🏗️ Build Image Docker') {
            steps {
                script {
                    echo "=== 🐳 CONSTRUCTION IMAGE DOCKER ==="
                    
                    sh """
                        # Construction avec cache optimisé
                        echo "Construction de: ${DOCKER_REPO}:${DOCKER_TAG}"
                        docker build \\
                            --pull \\
                            --no-cache \\
                            --tag ${DOCKER_REPO}:${DOCKER_TAG} \\
                            --tag ${DOCKER_REPO}:latest \\
                            .
                        
                        echo "✅ Construction terminée!"
                        echo ""
                        echo "=== 📦 IMAGES CRÉÉES ==="
                        docker images ${DOCKER_USER}/*
                        
                        echo ""
                        echo "=== ℹ️  INFO IMAGE ==="
                        docker inspect ${DOCKER_REPO}:${DOCKER_TAG} | jq -r '.[0].Config.Labels' 2>/dev/null || \\
                        docker inspect ${DOCKER_REPO}:${DOCKER_TAG} | grep -A5 "Config" || echo "Info inspection"
                    """
                }
            }
        }
        
        // STAGE 5: TESTS DE L'IMAGE
        stage('🧪 Tests Image') {
            steps {
                sh '''
                    echo "=== 🧪 TESTS DE L'IMAGE ==="
                    
                    echo "Test 1: Exécution basique"
                    docker run --rm ${DOCKER_REPO}:${DOCKER_TAG}
                    
                    echo ""
                    echo "Test 2: Vérification fichiers"
                    docker run --rm ${DOCKER_REPO}:${DOCKER_TAG} ls -la /app
                    
                    echo ""
                    echo "Test 3: Vérification packages"
                    docker run --rm ${DOCKER_REPO}:${DOCKER_TAG} bash --version | head -1
                    docker run --rm ${DOCKER_REPO}:${DOCKER_TAG} curl --version | head -1
                    docker run --rm ${DOCKER_REPO}:${DOCKER_TAG} git --version
                    
                    echo ""
                    echo "Test 4: Vérification environnement"
                    docker run --rm ${DOCKER_REPO}:${DOCKER_TAG} env | grep -E "PATH|HOME|USER" | head -5
                    
                    echo ""
                    echo "✅ Tous les tests réussis!"
                '''
            }
        }
        
        // STAGE 6: PUSH VERS DOCKER HUB
        stage('⬆️ Push Docker Hub') {
            steps {
                script {
                    echo "=== 🚀 PUSH VERS DOCKER HUB ==="
                    
                    withCredentials([
                        usernamePassword(
                            credentialsId: DOCKER_CREDENTIALS_ID,
                            usernameVariable: 'DOCKER_HUB_USER',
                            passwordVariable: 'DOCKER_HUB_TOKEN'
                        )
                    ]) {
                        sh '''
                            echo "Connexion à Docker Hub..."
                            
                            # CONNEXION
                            if ! echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USER}" --password-stdin; then
                                echo "❌ Impossible de se connecter - ABANDON"
                                exit 1
                            fi
                            
                            echo "✅ Connecté avec succès!"
                            echo ""
                            
                            # PUSH IMAGE BUILD TAG
                            echo ">>> Pushing ${DOCKER_TAG}..."
                            if docker push ${DOCKER_REPO}:${DOCKER_TAG}; then
                                echo "✅ ${DOCKER_TAG} poussé avec succès!"
                            else
                                echo "❌ Échec push ${DOCKER_TAG}"
                                exit 1
                            fi
                            
                            echo ""
                            
                            # PUSH LATEST TAG
                            echo ">>> Pushing latest..."
                            if docker push ${DOCKER_REPO}:latest; then
                                echo "✅ latest poussé avec succès!"
                            else
                                echo "❌ Échec push latest"
                                exit 1
                            fi
                            
                            echo ""
                            echo "🎉 🎉 🎉 PUSH COMPLÈTEMENT RÉUSSI! 🎉 🎉 🎉"
                            echo "Votre image est maintenant disponible sur Docker Hub!"
                        '''
                    }
                }
            }
        }
        
        // STAGE 7: VÉRIFICATION FINALE
        stage('✅ Vérification Finale') {
            steps {
                script {
                    echo "=== ✅ VÉRIFICATION FINALE ==="
                    echo ""
                    echo "🎊 PIPELINE COMPLÈTEMENT RÉUSSIE! 🎊"
                    echo ""
                    echo "📊 RAPPORT DE BUILD:"
                    echo "   Build Number: #${BUILD_NUMBER}"
                    echo "   Date: ${new Date().format('yyyy-MM-dd HH:mm:ss')}"
                    echo "   Durée: ${currentBuild.durationString}"
                    echo ""
                    echo "🐳 IMAGE DOCKER:"
                    echo "   Nom: ${DOCKER_REPO}"
                    echo "   Tags: ${DOCKER_TAG}, latest"
                    echo "   Taille: $(docker images ${DOCKER_REPO} --format '{{.Size}}' | head -1)"
                    echo ""
                    echo "🌐 DOCKER HUB:"
                    echo "   URL: https://hub.docker.com/r/${DOCKER_USER}/${DOCKER_IMAGE_NAME}"
                    echo "   Tags disponibles: ${DOCKER_TAG} et latest"
                    echo ""
                    echo "🚀 COMMANDES POUR UTILISER:"
                    echo "   # Télécharger l'image"
                    echo "   docker pull ${DOCKER_REPO}:latest"
                    echo ""
                    echo "   # Exécuter l'image"
                    echo "   docker run --rm ${DOCKER_REPO}:latest"
                    echo ""
                    echo "   # Voir les informations"
                    echo "   docker run --rm ${DOCKER_REPO}:latest cat /info.txt"
                    echo ""
                    echo "   # Accéder au shell"
                    echo "   docker run -it --rm ${DOCKER_REPO}:latest /bin/bash"
                }
                
                // Nettoyage final
                sh '''
                    echo ""
                    echo "=== 🧹 NETTOYAGE FINAL ==="
                    docker logout 2>/dev/null || true
                    
                    # Optionnel: supprimer images locales
                    docker rmi ${DOCKER_REPO}:${DOCKER_TAG} 2>/dev/null || echo "Image ${DOCKER_TAG} supprimée"
                    docker rmi ${DOCKER_REPO}:latest 2>/dev/null || echo "Image latest supprimée"
                    
                    # Nettoyage Docker
                    docker system prune -f 2>/dev/null || true
                    
                    echo "✅ Nettoyage terminé"
                '''
            }
        }
    }
    
    post {
        always {
            echo "========================================"
            echo "🏁 FIN DU PIPELINE - Build #${BUILD_NUMBER}"
            echo "========================================"
            
            // Archivage des logs
            archiveArtifacts artifacts: '**/*.log', allowEmptyArchive: true
        }
        success {
            echo ""
            echo "███████╗██╗   ██╗ ██████╗ ██████╗███████╗███████╗███████╗"
            echo "██╔════╝██║   ██║██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝"
            echo "███████╗██║   ██║██║     ██║     █████╗  ███████╗███████╗"
            echo "╚════██║██║   ██║██║     ██║     ██╔══╝  ╚════██║╚════██║"
            echo "███████║╚██████╔╝╚██████╗╚██████╗███████╗███████║███████║"
            echo "╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝╚══════╝╚══════╝╚══════╝"
            echo ""
            echo "🌟 FÉLICITATIONS! Votre pipeline Docker fonctionne parfaitement! 🌟"
            echo ""
            
            // Message de succès
            script {
                sh '''
                    echo "Build ${BUILD_NUMBER} - SUCCÈS" > success.txt
                    echo "Image: ${DOCKER_REPO}:${DOCKER_TAG}" >> success.txt
                    echo "Date: $(date)" >> success.txt
                '''
                archiveArtifacts artifacts: 'success.txt'
            }
        }
        failure {
            echo ""
            echo "███████╗██████╗ ███████╗ ██████╗██╗   ██╗██████╗ "
            echo "██╔════╝██╔══██╗██╔════╝██╔════╝██║   ██║██╔══██╗"
            echo "█████╗  ██║  ██║█████╗  ██║     ██║   ██║██████╔╝"
            echo "██╔══╝  ██║  ██║██╔══╝  ██║     ██║   ██║██╔══██╗"
            echo "███████╗██████╔╝███████╗╚██████╗╚██████╔╝██║  ██║"
            echo "╚══════╝╚═════╝ ╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝"
            echo ""
            echo "🔧 DIAGNOSTIC RAPIDE:"
            echo "   1. Testez manuellement: docker login -u alabendawed871"
            echo "   2. Vérifiez le token dans Jenkins"
            echo "   3. Vérifiez que Docker tourne: docker ps"
            echo ""
            echo "📋 Logs d'erreur disponibles dans Jenkins"
            
            // Archivage des logs d'erreur
            script {
                sh '''
                    echo "Build ${BUILD_NUMBER} - ÉCHEC" > error.log
                    docker version >> error.log 2>&1
                    echo "=== FIN ====" >> error.log
                '''
                archiveArtifacts artifacts: 'error.log'
            }
        }
        cleanup {
            // Nettoyage ultime
            sh '''
                echo "🧼 Nettoyage des fichiers temporaires..."
                rm -f success.txt error.log 2>/dev/null || true
                echo "✅ Nettoyage terminé"
            '''
        }
    }
}
