#!/usr/bin/env/ groovy
pipeline {
    agent any
    stages {
//         stage ('Build') {
//             when { expression { return params.Build }}
//             steps {
//                 withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'pass', usernameVariable: 'user')]) {
//                     sh "docker build -t ${user}/helloapp:${currentBuild.number} ."
//                     sh "docker tag ${user}/helloapp:${currentBuild.number} ${user}/helloapp:latest"
//                 }
//             }
//         }
//         stage ('Push to registry') {
//             when { expression { return params.Build }}
//             steps {
//                 withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'pass', usernameVariable: 'user')]) {
//                     sh "docker login -u ${user} -p ${pass}"
//                     sh "docker push ${user}/helloapp:${currentBuild.number}"
//                     sh "docker push ${user}/helloapp:latest"
//                 }
//             }
//         }
        stage ('create eks cluster') {
            steps {
                steps{
                    dir('terraform') {
                        ssh "terraform init"
                        ssh "terraform plan"
                        ssh "terraform apply -auto-approve"
                    }
                }
            }
        }
    }
} 