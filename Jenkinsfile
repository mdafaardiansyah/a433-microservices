pipeline {
    agent any
    
    tools {
        go 'Go 1.19' // Sesuaikan dengan versi Go yang Anda gunakan
    }
    
    parameters {
        string(name: 'RELEASE_TAG', defaultValue: '', description: 'Release tag to build and deploy (kosongkan untuk menggunakan build number)')
        choice(name: 'DEPLOY_ENV', choices: ['development', 'production'], description: 'Environment to deploy')
    }
    
    environment {
        DOCKER_HUB_CREDS = credentials('docker-hub')
        DOCKER_HUB_PAT = credentials('docker-hub-pat')
        DISCORD_WEBHOOK = credentials('discord-notification')
        APP_NAME = 'karsajobs'
        DOCKER_IMAGE = "${DOCKER_HUB_CREDS_USR}/${APP_NAME}"
        IMAGE_TAG = "${params.RELEASE_TAG ? params.RELEASE_TAG : env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    try {
                        discordSend(
                            webhookURL: DISCORD_WEBHOOK,
                            title: "BUILD STARTED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                            description: "Build started for ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                            link: env.BUILD_URL,
                            result: 'STARTED'
                        )
                    } catch (Exception e) {
                        echo "Discord notification failed: ${e.message}"
                    }
                }
            }
        }
        
        stage('Lint Dockerfile') {
            steps {
                sh '''
                # Use docker to run hadolint instead of downloading it
                docker run --rm -i hadolint/hadolint < Dockerfile || true
                '''
            }
        }
        
        stage('Test App') {
            steps {
                sh 'go test -v -short --count=1 $(go list ./...)'
            }
        }
        
        stage('Docker Build') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} -t ${DOCKER_IMAGE}:latest ."
            }
        }
        
        stage('Docker Push') {
            steps {
                sh "echo ${DOCKER_HUB_PAT} | docker login -u ${DOCKER_HUB_CREDS_USR} --password-stdin"
                sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
                sh "docker push ${DOCKER_IMAGE}:latest"
            }
        }
    }
    
    post {
        success {
            script {
                try {
                    discordSend(
                        webhookURL: DISCORD_WEBHOOK,
                        title: "BUILD SUCCESSFUL: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                        description: "Build completed successfully for ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                        link: env.BUILD_URL,
                        result: 'SUCCESS'
                    )
                } catch (Exception e) {
                    echo "Discord notification failed: ${e.message}"
                }
            }
        }
        failure {
            script {
                try {
                    discordSend(
                        webhookURL: DISCORD_WEBHOOK,
                        title: "BUILD FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                        description: "Build failed for ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                        link: env.BUILD_URL,
                        result: 'FAILURE'
                    )
                } catch (Exception e) {
                    echo "Discord notification failed: ${e.message}"
                }
            }
        }
        always {
            // Clean up Docker images and builder cache
            withEnv([
                "DOCKER_IMG=${DOCKER_IMAGE}", 
                "IMG_TAG=${IMAGE_TAG}"
            ]) {
                sh '''
                    # Hapus image yang tidak terpakai
                    docker rmi $DOCKER_IMG:$IMG_TAG || true
                    docker rmi $DOCKER_IMG:latest || true
                    
                    # Bersihkan builder cache untuk mencegah penumpukan storage
                    docker builder prune -f || true
                '''
            }
            cleanWs()
        }
    }
}