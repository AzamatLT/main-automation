pipeline {
    agent any
    
    tools {
        maven 'maven'
        jdk 'jdk11'
    }
    
    stages {
        stage('Check Tools') {
            steps {
                script {
                    sh '''
                        echo "=== Проверка установленных инструментов ==="
                        echo "Docker version:"
                        docker --version
                        echo ""
                        echo "Kubectl version:"
                        kubectl version --client
                        echo ""
                        echo "Terraform version:"
                        terraform version
                        echo ""
                        echo "Helm version:"
                        helm version
                        echo ""
                        echo "Ansible version:"
                        ansible --version
                        echo ""
                        echo "Python version:"
                        python3 --version
                        echo ""
                        echo "Node.js version:"
                        node --version
                        echo ""
                        echo "Maven version:"
                        mvn --version
                    '''
                }
            }
        }
        
        stage('Test Docker') {
            steps {
                script {
                    sh 'docker ps'
                }
            }
        }
    }
}