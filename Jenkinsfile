pipeline {

    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
        AWS_DEFAULT_REGION = 'us-west-1'
        ECR_REGISTRY_ID = '634639955940.dkr.ecr.us-west-1.amazonaws.com'
        IMAGE_NAME = 'product_service'
       }

    stages {      
        stage('Git Checkout') {
            steps { 
                    echo "Checking out code from github"
                    checkout scm
                 }
               }      
              
        stage('Build Stage') {
           agent { docker 'maven:3.5-alpine' }
           steps { 
                   echo 'Building stage for the app...'
                   sh 'mvn compile'
           }
        }

        stage('Test App') {
           agent { docker 'maven:3.5-alpine' }
           steps {
                   echo 'Testing stage for the app...'
                   sh 'mvn test'
                   junit '**/target/surefire-reports/TEST-*.xml'

           }
        }

        stage('Packaging Stage') {
           agent { docker 'maven:3.5-alpine' }
           steps {
                   echo 'Packaging stage for the app..'
                   sh 'mvn package'
           }
        }

        stage('Docker Image Build') {
            steps {
                echo 'Bulding docker image...'
                sh "docker build -t product_service:${env.BUILD_NUMBER} ."
            }
        }        
        
        stage('Push Docker Image to ECR') {
                steps {
                   withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWS_CREDENTIALS_ID',
                   secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {

                    sh """
                       aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY_ID}
                       docker tag ${IMAGE_NAME}:${env.BUILD_NUMBER} ${ECR_REGISTRY_ID}/${IMAGE_NAME}:${env.BUILD_NUMBER}
                       docker push ${ECR_REGISTRY_ID}/${IMAGE_NAME}:${env.BUILD_NUMBER}

                      """
                     }
                    }
                  }

        stage('Deploy app to EKS') {
                 steps {
                   withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWS_CREDENTIALS_ID',
                   secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                     sh """
                         aws ec2 describe-regions 
                         aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin ${ECR_REGISTRY_ID}
                         docker tag ${IMAGE_NAME}:${env.BUILD_NUMBER} ${ECR_REGISTRY_ID}/${IMAGE_NAME}:${env.BUILD_NUMBER}
                         docker push ${ECR_REGISTRY_ID}/${IMAGE_NAME}:${env.BUILD_NUMBER}
                         rm -rf .kube
                	 mkdir .kube
	                 touch .kube/config
        	         chmod 775 .kube/config
                	 ls -la .kube
	                 aws --version
        	         helm version
                	 aws eks update-kubeconfig --name devopsthehardway-cluster --region us-west-1
                	 echo "Deploying application..."
	                 helm upgrade --install java-app ./java-app  --set app.image="${ECR_REGISTRY_ID}/${IMAGE_NAME}:${env.BUILD_NUMBER}"
 			 sleep 6s
                         helm ls

                      """
                 }
              }
     
            }
          }

    post {
      failure {
        mail to: 'richgoldd2@gmail.com',
            subject: 'Failed pipeline: ${currentBuild.fullDisplayName}',
            body: 'Pipeline failed for dev ${env.BUILD_URL}'
         }
       }
     }
  
