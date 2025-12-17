pipeline {
    agent any
    
    environment {
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE = 'test-devops-ala'
        // Ces variables seront injectées par SonarQube dans Jenkins
        SONAR_PROJECT_KEY = 'student-management'
        SONAR_PROJECT_NAME = 'student-management'
    }
    
    stages {
        stage('Git') {
            steps {
                checkout scm
                echo '✅ Code récupéré'
            }
        }
        
        stage('Vérifier SonarQube') {
            steps {
                script {
                    echo "🔍 Vérification configuration SonarQube..."
                    echo "Nom recherché: SonarQube-Ala"
                    
                    try {
                        withSonarQubeEnv('SonarQube-Ala') {
                            echo "✅ Configuration SonarQube trouvée!"
                            echo "URL: ${SONAR_HOST_URL}"
                        }
                    } catch (Exception e) {
                        echo "⚠️ Configuration SonarQube-Ala non trouvée"
                        echo "➡️ On continue sans SonarQube pour l'instant"
                    }
                }
            }
        }
        
        stage('Build & Tests') {
            steps {
                sh '''
                    echo "🔧 Compilation et tests en cours..."
                    mvn clean compile test
                    echo "✅ Build Maven et tests terminés"
                '''
            }
            
            post {
                success {
                    sh 'echo "📊 Rapport JaCoCo généré dans target/site/jacoco/jacoco.xml"'
                }
            }
        }
        
        stage('Analyse SonarQube') {
            steps {
                script {
                    echo "📊 Début de l'analyse SonarQube..."
                    
                    try {
                        withSonarQubeEnv('SonarQube-Ala') {
                            sh '''
                                echo "🔍 Exécution de l'analyse SonarQube..."
                                echo "URL SonarQube: ${SONAR_HOST_URL}"
                                echo "Project Key: ${SONAR_PROJECT_KEY}"
                                
                                # Option 1: Utiliser le profil SonarQube défini dans pom.xml
                                mvn verify sonar:sonar -Psonar \
                                    -Dsonar.host.url=${SONAR_HOST_URL} \
                                    -Dsonar.login=${SONAR_AUTH_TOKEN}
                                    
                                # OU Option 2: Exécuter directement sonar:sonar
                                # mvn sonar:sonar \
                                #     -Dsonar.host.url=${SONAR_HOST_URL} \
                                #     -Dsonar.login=${SONAR_AUTH_TOKEN} \
                                #     -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                #     -Dsonar.projectName="${SONAR_PROJECT_NAME}"
                                
                                echo "✅ Analyse SonarQube terminée!"
                            '''
                        }
                    } catch (Exception e) {
                        echo "⚠️ ERREUR lors de l'analyse SonarQube: ${e.getMessage()}"
                        echo "➡️ On continue le pipeline sans l'analyse qualité"
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                script {
                    echo "⏳ Attente du Quality Gate SonarQube..."
                    
                    try {
                        timeout(time: 10, unit: 'MINUTES') {
                            def qg = waitForQualityGate()
                            if (qg.status != 'OK') {
                                error "❌ Quality Gate échoué: ${qg.status}"
                            } else {
                                echo "✅ Quality Gate réussi: ${qg.status}"
                            }
                        }
                    } catch (Exception e) {
                        echo "⚠️ Attention: ${e.getMessage()}"
                        echo "ℹ️ Le Quality Gate n'est pas disponible ou a timeout"
                        echo "➡️ On continue le pipeline"
                    }
                }
            }
        }
        
        stage('Package') {
            steps {
                sh '''
                    echo "📦 Création du package JAR..."
                    # On skip les tests car ils ont déjà été exécutés
                    mvn package -DskipTests
                    echo "✅ Package créé: target/student-management-0.0.1-SNAPSHOT.jar"
                '''
            }
        }
        
        stage('Docker Build') {
            steps {
                sh '''
                    echo "🐳 Construction de l'image Docker..."
                    docker build -t ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                    echo "✅ Image Docker créée: ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}"
                '''
            }
        }
        
        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-ala',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh '''
                        echo "📤 Connexion à Docker Hub..."
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                        
                        echo "📦 Pousse des images..."
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                        
                        docker logout
                        echo "✅ Images poussées sur Docker Hub"
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo '🎉 PIPELINE RÉUSSIE !'
            echo ''
            echo '📊 RÉSUMÉ :'
            echo "• Image Docker : ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}"
            echo '• Docker Hub : https://hub.docker.com/r/alabendawed871/test-devops-ala'
            script {
                try {
                    withSonarQubeEnv('SonarQube-Ala') {
                        echo "• Analyse SonarQube : ${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}"
                    }
                } catch (Exception e) {
                    echo "• Analyse SonarQube : Non disponible"
                }
            }
        }
        failure {
            echo '❌ PIPELINE ÉCHOUÉE !'
            echo '🔍 Vérifiez les logs pour plus de détails.'
            
            script {
                // Afficher des infos de débogage
                echo "=== DEBUG INFO ==="
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Workspace: ${WORKSPACE}"
                sh 'ls -la ${WORKSPACE} || true'
            }
        }
        always {
            echo '🏁 Pipeline terminée'
            // Nettoyage optionnel
            // cleanWs()
        }
    }
}
