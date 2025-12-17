pipeline {
    agent any
    
    environment {
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE = 'test-devops-ala'
        // Variables SonarQube (seront injectées par Jenkins)
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
        
        stage('Build & Tests avec JaCoCo') {
            steps {
                sh '''
                    # Exécute les tests et génère le rapport JaCoCo
                    mvn clean verify
                    echo "✅ Build et Tests réussi avec couverture JaCoCo"
                    
                    # Vérifie que le rapport JaCoCo est généré
                    ls -la target/site/jacoco/
                '''
            }
        }
        
        stage('Analyse SonarQube') {
            steps {
                script {
                    echo "🔍 Lancement de l'analyse SonarQube..."
                    
                    // Vérifie d'abord la configuration SonarQube
                    try {
                        withSonarQubeEnv('SonarQube-Ala') {
                            echo "✅ Configuration SonarQube trouvée!"
                            echo "URL SonarQube: ${SONAR_HOST_URL}"
                            
                            // Exécute l'analyse SonarQube
                            sh """
                                echo "Analyse SonarQube en cours..."
                                mvn sonar:sonar \
                                  -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                  -Dsonar.projectName="${SONAR_PROJECT_NAME}" \
                                  -Dsonar.host.url=${SONAR_HOST_URL} \
                                  -Dsonar.login=${SONAR_AUTH_TOKEN} \
                                  -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \
                                  -Dsonar.java.binaries=target/classes
                            """
                        }
                        
                        echo "✅ Analyse SonarQube envoyée avec succès"
                        
                        // Optionnel : Attendre le résultat de la qualité
                        timeout(time: 5, unit: 'MINUTES') {
                            waitForQualityGate abortPipeline: false
                        }
                        
                    } catch (Exception e) {
                        echo "⚠️ Erreur SonarQube: ${e.message}"
                        echo "➡️ On continue sans analyse SonarQube"
                    }
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                    echo "✅ Image Docker créée: ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}"
                '''
            }
        }
        
        stage('Push Docker') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-ala',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh '''
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
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
            echo '🎉 PIPELINE RÉUSSIE !!'
            echo ''
            echo '📊 RÉSUMÉ :'
            echo '• Image Docker : alabendawed871/test-devops-ala:${BUILD_NUMBER}'
            echo '• Docker Hub : https://hub.docker.com/r/alabendawed871/test-devops-ala'
            echo '• SonarQube : http://192.168.1.18:9000/dashboard?id=student-management'
        }
        failure {
            echo '❌ Pipeline échouée'
        }
    }
}
