pipeline {
    agent any

    environment {
        APP_NAME = 'your-app-name'
        BUILD_DIR = 'target'   // or 'build', 'dist' for your project
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building the project...'
                // Maven:  sh 'mvn clean package -DskipTests'
                // Gradle: sh './gradlew build'
                // npm:    sh 'npm install && npm run build'
                sh 'echo Build step — replace with your command'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                // Maven:  sh 'mvn test'
                // npm:    sh 'npm test'
                sh 'echo Test step — replace with your command'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Archive') {
            steps {
                echo 'Archiving build artifacts...'
                archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline FAILED — check the logs above.'
        }
    }
}
