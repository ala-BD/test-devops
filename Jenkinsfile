pipeline {
    agent any
    
    environment {
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE = 'test-devops-ala'
    }
    
    stages {
        // 1. Récupérer le code
        stage('📥 Git') {
            steps {
                checkout scm
            }
        }
        
        // 2. Analyser avec SonarQube (MAINTENANT ÇA MARCHE !)
        stage('🔍 SonarQube') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn clean compile sonar:sonar -Dsonar.projectKey=Ala-Test-DevOps'
                }
            }
        }
        
        // 3. Attendre le résultat Quality Gate
        stage('✅ Quality Check') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        // 4. Construire l'application
        stage('🏗️ Build') {
            steps {
                sh 'mvn clean package -DskipTests'
                echo '✅ Application construite'
            }
        }
        
        // 5. Construire l'image Docker
        stage('🐳 Docker') {
            steps {
                sh '''
                    docker build -t ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                    echo "✅ Image Docker créée"
                '''
            }
        }
        
        // 6. Pousser sur Docker Hub
        stage('📤 Push') {
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
            echo '🎉 PIPELINE RÉUSSIE !'
            echo ''
            echo '📊 RÉSUMÉ :'
            echo '• SonarQube : http://192.168.1.18:9000'
            echo '• Image Docker : alabendawed871/test-devops-ala:${BUILD_NUMBER}'
            echo '• Docker Hub : https://hub.docker.com/r/alabendawed871/test-devops-ala'
        }
        failure {
            echo '❌ Pipeline échouée'
        }
    }
}
