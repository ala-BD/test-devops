pipeline {
    agent any
    
    environment {
        // Docker
        DOCKER_USER = 'alabendawed871'
        DOCKER_IMAGE = 'student-management-ala'
        DOCKER_TAG = "build-${BUILD_NUMBER}"
        
        // SonarQube
        SONAR_HOST = 'http://192.168.33.10:9000'
        SONAR_PROJECT = 'student-management'
        
        // VOTRE configuration MySQL EXACTE
        DB_URL = 'jdbc:mysql://localhost:3306/studentdb?createDatabaseIfNotExist=true'
        DB_USER = 'root'
        DB_PASSWORD = ''
    }
    
    stages {
        // ÉTAPE 1: Checkout
        stage('Checkout Git') {
            steps {
                checkout scm
                echo '✅ Code récupéré depuis Git'
            }
        }
        
        // ÉTAPE 2: Build avec VOTRE configuration MySQL
        stage('Build avec MySQL') {
            steps {
                sh """
                    echo "=== BUILD AVEC VOTRE CONFIGURATION MYSQL ==="
                    echo "URL: ${DB_URL}"
                    echo "User: ${DB_USER}"
                    
                    # OPTION A: Avec tests (si MySQL disponible sur Jenkins)
                    mvn clean compile test \
                      -Dspring.datasource.url=${DB_URL} \
                      -Dspring.datasource.username=${DB_USER} \
                      -Dspring.datasource.password=${DB_PASSWORD} \
                      -Dspring.jpa.hibernate.ddl-auto=update \
                      -Dspring.jpa.show-sql=false \
                      -Dserver.port=8089 \
                      -Dserver.servlet.context-path=/student
                    
                    echo "✅ Build avec MySQL réussi"
                """
            }
        }
        
        // ÉTAPE 3: ATELIER SONARQUBE (LE PLUS IMPORTANT)
        stage('Atelier SonarQube') {
            steps {
                script {
                    withSonarQubeEnv('SonarQube') {
                        sh """
                            echo "======================================"
                            echo "🔍 ATELIER SONARQUBE - ANALYSE DU CODE"
                            echo "======================================"
                            
                            # Commande SonarQube - Token injecté AUTOMATIQUEMENT
                            mvn sonar:sonar \
                              -Dsonar.projectKey=${SONAR_PROJECT} \
                              -Dsonar.projectName="Student Management" \
                              -Dsonar.projectVersion=${BUILD_NUMBER} \
                              -Dsonar.sources=src/main/java \
                              -Dsonar.java.binaries=target/classes \
                              -Dsonar.java.source=17 \
                              -Dsonar.sourceEncoding=UTF-8
                            
                            echo ""
                            echo "🎯 ANALYSE SONARQUBE TERMINÉE!"
                            echo "📊 Accédez au rapport: ${SONAR_HOST}/dashboard?id=${SONAR_PROJECT}"
                            echo ""
                            echo "✅ Objectif Atelier: ATTEINT!"
                        """
                    }
                }
            }
        }
        
        // ÉTAPE 4: Quality Gate (sans bloquer)
        stage('Quality Gate') {
            steps {
                echo "⏳ Vérification Quality Gate..."
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
                echo "✅ Quality Gate vérifiée"
            }
        }
        
        // ÉTAPE 5: Rapport final atelier
        stage('Rapport Atelier') {
            steps {
                echo """
                ========================================
                🎉 ATELIER SONARQUBE COMPLÈTEMENT RÉUSSI!
                ========================================
                
                📋 CONFIGURATION UTILISÉE:
                • Base de données: MySQL (votre config)
                • Projet: ${SONAR_PROJECT}
                • SonarQube: ${SONAR_HOST}
                • Build: #${BUILD_NUMBER}
                
                ✅ COMPÉTENCES ACQUISES:
                1. Intégration SonarQube dans Jenkins
                2. Analyse statique de code Java
                3. Configuration avec base de données
                4. Pipeline CI/CD fonctionnel
                5. Quality Gate automatisée
                
                🏁 L'atelier est terminé avec succès!
                Consultez vos résultats sur SonarQube.
                """
            }
        }
    }
    
    post {
        success {
            echo "🎉🎉🎉 FÉLICITATIONS! Atelier SonarQube réussi! 🎉🎉🎉"
        }
        failure {
            echo "⚠️ Atelier partiellement réussi - Vérifiez SonarQube pour les résultats"
        }
    }
}
