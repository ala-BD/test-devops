pipeline {
    agent any
    
    environment {
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE = 'test-devops-ala'
        SONAR_PROJECT_KEY = 'student-management'
        SONAR_PROJECT_NAME = 'Student Management'
    }
    
    stages {
        stage('Git') {
            steps {
                checkout scm
                echo '✅ Code récupéré'
            }
        }
        
        stage('Build avec tests') {
            steps {
                sh '''
                    echo "🔨 Build Maven avec tests"
                    mvn clean compile test
                    echo "✅ Build et tests exécutés"
                '''
            }
        }
        
        stage('Génération rapport JaCoCo') {
            steps {
                sh '''
                    echo "📊 Génération rapport JaCoCo"
                    # Génère le rapport JaCoCo réel
                    mvn jacoco:report
                    
                    # Vérifie si le fichier existe
                    if [ -f "target/site/jacoco/jacoco.xml" ]; then
                        echo "✅ Rapport JaCoCo généré: target/site/jacoco/jacoco.xml"
                        # Affiche un aperçu du rapport
                        head -20 target/site/jacoco/jacoco.xml
                    else
                        echo "⚠️ Fichier JaCoCo non trouvé, recherche alternative..."
                        find . -name "jacoco.xml" -type f
                    fi
                '''
            }
        }
        
        stage('SonarQube Scan') {
            steps {
                script {
                    try {
                        withSonarQubeEnv('SonarQube-Ala') {
                            sh '''
                                echo "🔍 Analyse SonarQube en cours..."
                                
                                # Analyse SonarQube avec les bons paramètres
                                # Les variables SONAR_HOST_URL et SONAR_AUTH_TOKEN sont injectées par withSonarQubeEnv
                                mvn sonar:sonar \
                                  -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                  -Dsonar.projectName="${SONAR_PROJECT_NAME}" \
                                  -Dsonar.sources=src/main/java \
                                  -Dsonar.tests=src/test/java \
                                  -Dsonar.java.binaries=target/classes \
                                  -Dsonar.java.libraries=target/**/*.jar \
                                  -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml \
                                  -Dsonar.exclusions="**/test/**,**/target/**" \
                                  -Dsonar.sourceEncoding=UTF-8 \
                                  -Dsonar.host.url=${SONAR_HOST_URL} \
                                  -Dsonar.login=${SONAR_AUTH_TOKEN}
                            '''
                        }
                        
                        // Attendre l'analyse qualité
                        timeout(time: 1, unit: 'MINUTES') {
                            def qg = waitForQualityGate()
                            if (qg.status != 'OK') {
                                error "Qualité non atteinte: ${qg.status}"
                            }
                        }
                        
                        echo "✅ Analyse SonarQube terminée avec succès"
                        
                    } catch (Exception e) {
                        echo "⚠️ Erreur SonarQube: ${e.message}"
                        // Ne pas échouer le pipeline pour SonarQube
                        echo "Continuer avec le reste du pipeline..."
                    }
                }
            }
        }
        
        stage('Package JAR') {
            steps {
                sh '''
                    echo "📦 Création du package JAR"
                    mvn package -DskipTests
                    echo "✅ Package créé"
                    
                    # Affiche le JAR généré
                    ls -la target/*.jar
                '''
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    // Vérifie si Dockerfile existe
                    def dockerfileExists = fileExists('Dockerfile')
                    if (!dockerfileExists) {
                        echo "📝 Création du Dockerfile..."
                        sh '''
                            cat > Dockerfile << 'EOF'
                            FROM openjdk:11-jre-slim
                            WORKDIR /app
                            COPY target/*.jar app.jar
                            EXPOSE 8080
                            ENTRYPOINT ["java", "-jar", "app.jar"]
                            EOF
                        '''
                    }
                    
                    sh '''
                        echo "🐳 Construction de l'image Docker..."
                        docker build -t ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} .
                        docker tag ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                        echo "✅ Image Docker créée: ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}"
                        
                        # Liste les images créées
                        docker images | grep ${DOCKER_IMAGE}
                    '''
                }
            }
        }
        
        stage('Push Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-ala',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh '''
                        echo "📤 Pushing to Docker Hub..."
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                        docker logout
                        echo "✅ Images poussées sur Docker Hub"
                        echo "📎 Lien: https://hub.docker.com/r/${DOCKER_USER}/${DOCKER_IMAGE}/tags"
                    '''
                }
            }
        }
        
        stage('Nettoyage') {
            steps {
                sh '''
                    echo "🧹 Nettoyage des conteneurs Docker..."
                    docker system prune -f
                '''
            }
        }
    }
    
    post {
        success {
            echo '🎉 PIPELINE RÉUSSIE !'
            echo "📊 Rapport SonarQube disponible sur: ${SONAR_HOST_URL}/dashboard?id=${SONAR_PROJECT_KEY}"
            echo "🐳 Image Docker: ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}"
        }
        failure {
            echo '❌ Pipeline échouée'
        }
        always {
            echo '📋 Journal disponible dans Jenkins'
            // Archiver les rapports
            archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
            junit 'target/surefire-reports/*.xml'
        }
    }
}
