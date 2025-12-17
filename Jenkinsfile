pipeline {
    agent any
    
    environment {
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE = 'test-devops-ala'
    }
    
    stages {
        // 1. Récupérer le code
        stage('📥 Git Checkout') {
            steps {
                checkout scm
            }
        }
        
        // 2. Analyser avec SonarQube
        stage('🔍 SonarQube') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=test-devops'
                }
            }
        }
        
        // 3. Attendre le Quality Gate
        stage('✅ Quality Check') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }
        
        // 4. Construire avec Maven
        stage('🏗️ Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        // 5. Construire l'image Docker
        stage('🐳 Build Docker') {
            steps {
                sh '''
                    docker build -t ${DOCKER_USER}/${DOCKER_IMAGE}:latest .
                    docker tag ${DOCKER_USER}/${DOCKER_IMAGE}:latest ${DOCKER_USER}/${DOCKER_IMAGE}:build-${BUILD_NUMBER}
                '''
            }
        }
        
        // 6. Pousser sur Docker Hub
        stage('📤 Push Docker') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-ala', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:build-${BUILD_NUMBER}
                        docker logout
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline réussie !'
            sh '''
                echo "Image Docker: ${DOCKER_USER}/${DOCKER_IMAGE}:build-${BUILD_NUMBER}"
                echo "Docker Hub: https://hub.docker.com/r/${DOCKER_USER}/${DOCKER_IMAGE}"
            '''
        }
        failure {
            echo '❌ Pipeline échouée'
        }
    }
}
