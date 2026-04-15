pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = 'cedrick13bienvenue'
        IMAGE_NAME         = 'cicd-node-app'
        IMAGE_TAG          = "${BUILD_NUMBER}"
        FULL_IMAGE         = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
        CONTAINER_NAME     = 'cicd-node-app'
        APP_PORT           = '3000'
        AWS_REGION         = 'eu-west-1'
    }

    stages {

        // ── Stage 1: Checkout ──────────────────────────────────────────────
        // Clones the repo and resolves the App EC2 IP dynamically from AWS
        // using the IAM role attached to this Jenkins EC2 — no hardcoded IPs
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.APP_EC2_IP = sh(
                        script: """
                            aws ec2 describe-instances \
                                --region ${AWS_REGION} \
                                --filters \
                                    "Name=tag:Role,Values=app" \
                                    "Name=instance-state-name,Values=running" \
                                --query "Reservations[0].Instances[0].PublicIpAddress" \
                                --output text
                        """,
                        returnStdout: true
                    ).trim()
                    echo "App EC2 IP resolved: ${env.APP_EC2_IP}"
                }
            }
        }

        // ── Stage 2: Install ───────────────────────────────────────────────
        // npm ci: deterministic install from lock file — faster and safer than npm install in CI
        stage('Install') {
            steps {
                dir('app') {
                    sh 'npm ci'
                }
            }
        }

        // ── Stage 3: Test ──────────────────────────────────────────────────
        // Pipeline aborts here if any test fails — image is never built from broken code
        stage('Test') {
            steps {
                dir('app') {
                    sh 'npm test'
                }
            }
        }

        // ── Stage 4: Docker Build ──────────────────────────────────────────
        // Tags image with BUILD_NUMBER so every build is uniquely traceable
        stage('Docker Build') {
            steps {
                dir('app') {
                    sh "docker build -t ${FULL_IMAGE} ."
                }
            }
        }

        // ── Stage 5: Push Image ────────────────────────────────────────────
        // registry_creds stored in Jenkins credentials store — never in code
        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'registry_creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ''' + FULL_IMAGE + '''
                        docker logout
                    '''
                }
            }
        }

        // ── Stage 6: Deploy ────────────────────────────────────────────────
        // sshagent loads ec2_ssh key for this stage only — key is never written to disk
        // Pulls the exact image built in this run (by BUILD_NUMBER tag)
        stage('Deploy') {
            steps {
                sshagent(['ec2_ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ec2-user@${APP_EC2_IP} '
                            docker pull ${FULL_IMAGE}
                            docker stop ${CONTAINER_NAME} || true
                            docker rm   ${CONTAINER_NAME} || true
                            docker run -d \\
                                --name ${CONTAINER_NAME} \\
                                -p ${APP_PORT}:${APP_PORT} \\
                                --restart unless-stopped \\
                                ${FULL_IMAGE}
                        '
                    """
                }
            }
        }
    }

    // ── Post: Cleanup ──────────────────────────────────────────────────────
    // Runs always — removes dangling images on Jenkins and App EC2 after every build
    post {
        always {
            sh 'docker image prune -f'
            sshagent(['ec2_ssh']) {
                sh "ssh -o StrictHostKeyChecking=no ec2-user@${APP_EC2_IP} 'docker image prune -f'"
            }
        }
        success {
            echo "Pipeline succeeded. App is live at http://${APP_EC2_IP}:${APP_PORT}"
        }
        failure {
            echo 'Pipeline failed. Check the stage logs above.'
        }
    }
}
