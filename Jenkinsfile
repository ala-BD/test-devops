pipeline {
    agent any
    
    environment {
        // Docker
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE = 'test-devops-ala'
        DOCKER_TAG = "build-${BUILD_NUMBER}"
        
        // SonarQube
        SONAR_HOST = 'http://192.168.33.10:9000'
        SONAR_PROJECT = 'student-management'
    }
    
    stages {
        // ÉTAPE 1: Checkout
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        // ÉTAPE 2: Build Maven
        stage('Build & Test') {
            steps {
                sh '''
                    echo "=== BUILD MAVEN ==="
                    mvn clean compile test
                    echo "✅ Build réussi"
                '''
            }
        }
        
        // ÉTAPE 3: SonarQube Analysis (SIMPLIFIÉE)
        stage('SonarQube') {
            steps {
                script {
                    withSonarQubeEnv('SonarQube') {
                        sh """
                            echo "=== ANALYSE SONARQUBE ==="
                            mvn sonar:sonar \
                              -Dsonar.projectKey=${SONAR_PROJECT} \
                              -Dsonar.projectName="${SONAR_PROJECT}" \
                              -Dsonar.host.url=${SONAR_HOST}
                        """
                    }
                }
            }
        }
        
        // ÉTAPE 4: Quality Gate
        stage('Quality Check') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }
        
        // ÉTAPE 5: Build Docker
        stage('Build Docker') {
            steps {
                sh """
                    echo "=== BUILD DOCKER ==="
                    docker build -t ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                    echo "✅ Image Docker construite"
                """
            }
        }
        
        // ÉTAPE 6: Push Docker
        stage('Push Docker') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-ala',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh """
                        echo "=== PUSH DOCKER HUB ==="
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                        docker logout
                        echo "✅ Image poussée sur Docker Hub"
                    """
                }
            }
        }
        
        // ÉTAPE 7: Cleanup
        stage('Cleanup') {
            steps {
                sh '''
                    echo "=== NETTOYAGE ==="
                    # Nettoyer les images Docker
                    docker rmi ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG} 2>/dev/null || true
                    docker rmi ${DOCKER_USER}/${DOCKER_IMAGE}:latest 2>/dev/null || true
                    
                    # Nettoyer Docker
                    docker system prune -f 2>/dev/null || true
                    echo "✅ Nettoyage terminé"
                '''
            }
        }
    }
    
    post {
        success {
            echo """
            ✅ PIPELINE RÉUSSI!
            ====================
            Build: #${BUILD_NUMBER}
            SonarQube: ${SONAR_HOST}/dashboard?id=${SONAR_PROJECT}
            Docker: ${DOCKER_USER}/${DOCKER_IMAGE}:${DOCKER_TAG}
            """
        }
        failure {
            echo '❌ Pipeline échoué'
        }
    }
}
