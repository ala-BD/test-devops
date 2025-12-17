pipeline {
    agent any
    
    environment {
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE = 'test-devops-ala'
    }
    
    triggers {
        pollSCM('* * * * *')  // Vérifie chaque minute
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
                        echo "➡️ On continue avec URL directe"
                    }
                }
            }
        }
        
        stage('Build & Sonar') {
            steps {
                script {
                    echo "🔨 Build et analyse SonarQube..."
                    
                    // Essayez d'abord avec la config Jenkins
                    try {
                        withSonarQubeEnv('SonarQube-Ala') {
                            sh '''
                                mvn clean test sonar:sonar \
                                -Dsonar.login=admin \
                                -Dsonar.password=AdminSonar123!
                            '''
                        }
                    } catch (Exception e) {
                        // Fallback: URL directe
                        echo "⚠️ Utilisation URL directe pour SonarQube"
                        sh '''
                            mvn clean test sonar:sonar \
                            -Dsonar.host.url=http://192.168.33.10:9000 \
                            -Dsonar.login=admin \
                            -Dsonar.password=AdminSonar123!
                        '''
                    }
                }
                echo "✅ Build et analyse SonarQube réussis"
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
            echo '• SonarQube : http://192.168.33.10:9000'
            echo '• Login Sonar : admin / AdminSonar123!'
        }
    }
}
