#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  triggers {
    cron(getDailyCronString())
  }

  stages {
    stage('Grant IP Access') {
      steps {
        // Grant access to this Jenkins agent's IP to AWS security groups
        grantIPAccess()
      }
    }

    stage('Validate Changelog') {
      steps {
        sh './bin/parse-changelog.sh'
      }
    }

    stage('Package') {
      steps {
        sh './package.sh && ./unpack.sh'
      }
    }

    stage('Test') {
      parallel {
        stage('Integration Tests') {
          steps {
            sh './bin/test_integration'
            junit 'bin/features/reports/*.xml'
          }
        }

        stage('End To End Tests') {
          steps {
            sh 'cd bin && summon ./test_e2e'
            junit 'bin/features/reports/*.xml'
          }
        }

        stage('Unit Tests') {
          stages {
            stage("Secret Retrieval Script Tests") {
              steps {
                sh './bin/test-retrieve-secrets/start'
                junit 'TestReport-test.xml'
              }
            }

            stage("Conjur-Env Unit Tests") {
              steps {
                sh './bin/test_conjur-env'
                junit 'buildpack/conjur-env/output/*.xml'
              }
            }
          }
        }
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
      // Remove this Jenkins Agent's IP from AWS security groups
      removeIPAccess()
    }
  }
}
