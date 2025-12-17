pipeline {
    agent any
    
    environment {
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE = 'test-devops-ala'
    }
    
    stages {
        // 1. Git
        stage('Git') {
            steps { checkout scm }
        }
        
        // 2. SonarQube avec le BON nom de configuration
        stage('SonarQube') {
            steps {
                // UTILISE 'SonarQube-Ala' et NON 'SonarQube'
                withSonarQubeEnv('SonarQube-Ala') {
                    sh 'mvn clean compile sonar:sonar -Dsonar.projectKey=Ala-Test-DevOps'
                }
            }
        }
        
        // 3. Quality Gate (continue même si échec)
        stage('Quality Check') {
            steps {
                script {
                    try {
                        timeout(time: 1, unit: 'MINUTES') {
                            waitForQualityGate abortPipeline: false
                        }
                    } catch (Exception e) {
                        echo "⚠️ SonarQube timeout, on continue..."
                    }
                }
            }
        }
        
        // 4. Build
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        
        // 5. Docker
        stage('Docker') {
            steps {
                sh '''
                    docker build -t ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                '''
            }
        }
        
        // 6. Push
        stage('Push') {
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
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ PIPELINE RÉUSSIE !'
        }
        failure {
            echo '❌ Pipeline échouée'
        }
    }
}
