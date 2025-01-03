pipeline {
    agent any
    
    environment {
        // Reference Jenkins Credentials (set in the Credentials manager)
        AZURE_TENANT_ID = credentials('AZURE_TENANT_ID')
        AZURE_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')
        AZURE_CLIENT_ID = credentials('AZURE_CLIENT_ID')
        AZURE_CLIENT_SECRET = credentials('AZURE_CLIENT_SECRET')
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository containing Terraform code
                git branch: 'main', url: 'https://github.com/ishan2210/Azure-Hybrid-Firewall-using-Terraform.git'
            }
        }

        stage('Initialize Terraform') {
            steps {
                // Log in to Azure and initialize Terraform
                sh '''
                az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
                terraform init
                '''
            }
        }

        stage('Plan Terraform') {
            steps {
                // Run terraform plan to check the infrastructure changes
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Apply Terraform') {
            steps {
                // Apply the Terraform plan
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}



