
pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/gilllavish25/kanban-dashboard.git'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                        -t kanban-dashboard:${BUILD_NUMBER} \
                        -t kanban-dashboard:latest .
                '''
            }
        }

        stage('Docker Hub Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKERHUB_USERNAME',
                    passwordVariable: 'DOCKERHUB_TOKEN'
                )]) {
                    sh '''
                        set +x

                        echo "$DOCKERHUB_TOKEN" | docker login \
                            -u "$DOCKERHUB_USERNAME" --password-stdin

                        docker tag kanban-dashboard:${BUILD_NUMBER} \
                            gilllavish25/lavish-kanban-dashboard:${BUILD_NUMBER}

                        docker tag kanban-dashboard:latest \
                            gilllavish25/lavish-kanban-dashboard:latest

                        docker push \
                            gilllavish25/lavish-kanban-dashboard:${BUILD_NUMBER}

                        docker push \
                            gilllavish25/lavish-kanban-dashboard:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    set -e

                    echo "Pulling latest image..."
                    docker pull gilllavish25/lavish-kanban-dashboard:${BUILD_NUMBER}

                    echo "Saving previous image for rollback..."
                    OLD_IMAGE=$(docker inspect --format='{{.Config.Image}}' kanban-app 2>/dev/null || true)

                    echo "Stopping old container..."
                    docker rm -f kanban-app || true

                    echo "Starting new container..."
                    docker run -d \
                        --name kanban-app \
                        --restart unless-stopped \
                        --memory=128m \
                        --cpus=0.5 \
                        -p 80:8080 \
                        gilllavish25/lavish-kanban-dashboard:${BUILD_NUMBER}

                    sleep 10

                    if curl -f http://localhost/; then
                        echo "Deployment successful!"
                    else
                        echo "Deployment failed. Attempting rollback..."

                        docker rm -f kanban-app || true

                        if [ -n "$OLD_IMAGE" ]; then
                            docker run -d \
                                --name kanban-app \
                                --restart unless-stopped \
                                --memory=128m \
                                --cpus=0.5 \
                                -p 80:8080 \
                                "$OLD_IMAGE"
                        fi

                        exit 1
                    fi
                '''
            }
        }
    }
}
