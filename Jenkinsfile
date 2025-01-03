pipeline {
    agent any
    
    environment {
        // Azure Credentials
        AZURE_CLIENT_ID = credentials('azure-client-id')  // Replace with your credential ID
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')  // Replace with your credential ID
        AZURE_TENANT_ID = credentials('azure-tenant-id')  // Replace with your credential ID
        AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')  // Replace with your credential ID
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from GitHub repository
                git 'https://github.com/your-repo/terraform-azure.git'
            }
        }
        
        stage('Terraform Init') {
            steps {
                script {
                    // Set the environment variables for Terraform
                    sh '''
                    export ARM_CLIENT_ID=$AZURE_CLIENT_ID
                    export ARM_CLIENT_SECRET=$AZURE_CLIENT_SECRET
                    export ARM_TENANT_ID=$AZURE_TENANT_ID
                    export ARM_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID
                    
                    terraform init
                    '''
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                script {
                    // Run terraform plan to see what changes will be made
                    sh '''
                    terraform plan -out=tfplan
                    '''
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                script {
                    // Apply the Terraform plan to create the infrastructure on Azure
                    sh '''
                    terraform apply -input=false tfplan
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo "Terraform applied successfully!"
        }
        failure {
            echo "Terraform failed to apply. Check the logs."
        }
    }
}

