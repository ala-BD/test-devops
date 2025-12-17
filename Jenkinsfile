pipeline {
    agent any
    
    environment {
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE = 'test-devops-ala'
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
                    
                    // Test simple sans échouer
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
        
        stage('Build') {
            steps {
                sh '''
                    mvn clean package -DskipTests
                    echo "✅ Build Maven réussi"
                '''
            }
        }
        
        stage('Docker') {
            steps {
                sh '''
                    docker build -t ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                    echo "✅ Image Docker créée: ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}"
                '''
            }
        }
        
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
            echo '• Image Docker : alabendawed871/test-devops-ala:${BUILD_NUMBER}'
            echo '• Docker Hub : https://hub.docker.com/r/alabendawed871/test-devops-ala'
        }
    }
}
