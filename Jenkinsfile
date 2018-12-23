#!groovy

node {
    stage('checkout source') {
        checkout scm
    }

    stage('deploy') {
        when { branch 'master' }
        echo 'master'
    }

    stage('deploy2') {
        when { branch 'stage'}
        echo 'stage'
    }
}