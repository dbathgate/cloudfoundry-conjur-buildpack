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
    stage('Validate') {
      parallel {
        stage('Changelog') {
          steps { sh './bin/parse-changelog.sh' }
        }
      }
    }
    
    stage('Build buildpack') {
      steps {
        sh './package.sh'

        archiveArtifacts artifacts: '*.zip', fingerprint: true
      }
    }

    stage('Test') {
      parallel {
        stage('Integration Tests') {
          steps {
            sh 'summon ./test.sh'
            junit 'ci/features/reports/*.xml'
          }
        }

        stage('Unit Tests') {
          stages {
            stage("Secret Retrieval Script Tests") {
              steps {
                sh './ci/test-retrieve-secrets/start'
                junit 'TestReport-test.xml'
              }
            }

            stage("Conjur-Env Unit Tests") {
              steps {
                sh './ci/test-unit'
                junit 'conjur-env/output/*.xml'
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
    }
  }
}
