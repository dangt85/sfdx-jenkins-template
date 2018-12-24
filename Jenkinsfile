#!groovy

import groovy.json.JsonSlurperClassic

pipeline {
    agent any
    stages {
        stage('Authorize PROD') {
            when { branch 'master' }
            steps {
                script {
                    rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${env.DEV_HUB_CONSUMER_KEY} --username ${env.DEV_HUB_USERNAME} --jwtkeyfile build/server.key --setalias PROD"
                    if (rc != 0) { error 'hub org authorization failed' }
                }
            }
        }
        stage('Deploy to PROD') {
            when { branch 'master' }
            steps {
                script {
                    rc = sh returnStatus: true, script: "sfdx force:lightning:test:install --packagetype jasmine --targetusername PROD --wait 5"
                    if (rc != 0) { error 'Lightning Testing Service install failed' }
                    // convert to metadata api
                    rc = sh returnStatus: true, script: "sfdx force:source:convert --rootdir force-app/ --outputdir src/"
                    if (rc != 0) { error 'metadata convert failed' }
                    rmsg = sh returnStdout: true, script: "sfdx force:mdapi:deploy --checkonly --deploydir src/ --targetusername PROD --testlevel RunLocalTests --wait 10 --json"
                    def jsonSlurper = new JsonSlurperClassic()
                    def robj = jsonSlurper.parseText(rmsg)
                    if (robj.status != 0) { error 'prod deploy failed: ' + robj.message }
                    // assign permset
                    // rc = sh returnStatus: true, script: "sfdx force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname DreamHouse"
                    // if (rc != 0) {
                    //     error 'permset:assign failed'
                    // }
                }
            }
        }
        stage('Quick deploy PROD') {
            when { branch 'master' }
            input {
                message 'Commit deploy?'
                ok 'Yes'
                parameters {
                    booleanParam(name: 'COMMIT', defaultValue: true, description: '')
                }
            }
            steps {
                script {
                    if(params.COMMIT == true) {
                        echo 'quick deploy ${params.COMMIT}'
                        printf rmsg
                        // rc = sh returnStatus: true, script: "sfdx force:source:convert --rootdir force-app/ --outputdir src/"
                        // if (rc != 0) { error 'metadata convert failed' }
                    }
                }
            }
        }
        stage('Authorize STAGE') {
            when { branch 'stage' }
            steps {
                script {
                    rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${env.STAGE_CONSUMER_KEY} --username ${env.STAGE_USERNAME} --jwtkeyfile build/server.key --instanceurl https://test.salesforce.com --setalias STAGE"
                    if (rc != 0) { error 'hub org authorization failed' }
                }
            }
        }
        stage('Deploy to STAGE') {
            when { branch 'stage' }
            steps {
                script {
                    rc = sh returnStatus: true, script: "sfdx force:lightning:test:install --packagetype jasmine --targetusername STAGE --wait 5"
                    if (rc != 0) { error 'Lightning Testing Service install failed' }
                    // convert to metadata api
                    rc = sh returnStatus: true, script: "sfdx force:source:convert --rootdir force-app/ --outputdir src/"
                    if (rc != 0) { error 'metadata convert failed' }
                    rmsg = sh returnStdout: true, script: "sfdx force:mdapi:deploy --checkonly --deploydir src/ --targetusername STAGE --testlevel RunLocalTests --wait 5 --json"
                    def jsonSlurper = new JsonSlurperClassic()
                    def robj = jsonSlurper.parseText(rmsg)
                    if (robj.status != 0) { error 'stage deploy failed: ' + robj.message }
                    // assign permset
                    // rc = sh returnStatus: true, script: "sfdx force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname DreamHouse"
                    // if (rc != 0) { error 'permset:assign failed' }
                }
            }
        }
        stage('Authorize DevHub') {
            when { branch 'feature*' }
            steps {
                script {
                    rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${env.DEV_HUB_CONSUMER_KEY} --username ${env.DEV_HUB_USERNAME} --jwtkeyfile build/server.key --setdefaultdevhubusername"
                    if (rc != 0) { error 'hub org authorization failed' }
                }
            }
        }
        stage('Build') {
            when { branch 'feature*' }
            steps {
                script {
                    rc = sh returnStatus: true, script: "sfdx force:org:create --definitionfile config/project-scratch-def.json --json --setdefaultusername --setalias ciorg --durationdays 1"
                    if (rc != 0) { error 'scratch org creation failed' }
                    rc = sh returnStatus: true, script: "sfdx force:lightning:test:install --packagetype jasmine --wait 5"
                    if (rc != 0) { error 'Lightning Testing Service install failed' }
                    rc = sh returnStatus: true, script: "sfdx force:source:push"
                    if (rc != 0) { error 'source push failed' }
                    // assign permset
                    // rc = sh returnStatus: true, script: "sfdx force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname DreamHouse"
                    // if (rc != 0) {
                    //     error 'permset:assign failed'
                    // }
                }
            }
        }
        stage('Tests') {
            when { branch 'feature*' }
            failFast true
            parallel {
                stage('Run Apex tests') {
                    options {
                        timeout(time: 120, unit: 'SECONDS') 
                    }
                    steps {
                        script {
                            rc = sh returnStatus: true, script: "sfdx force:apex:test:run --testlevel RunLocalTests --codecoverage --outputdir tests/ --resultformat junit"
                            if (rc != 0) { error 'apex test run failed' }
                        }
                    }
                }
                stage('Run Aura tests') {
                    options {
                        timeout(time: 120, unit: 'SECONDS')
                    }
                    steps {
                        script {
                            rc = sh returnStatus: true, script: "sfdx force:lightning:test:run -a myTestSuite.app"
                            if (rc != 0) { error 'aura test run failed' }
                        }
                    }
                }
                // stage('Run LWC tests') {
                //     options {
                //         timeout(time: 120, unit: 'SECONDS')
                //     }
                //     steps {
                //         script {
                //             rc = sh returnStatus: true, script: "npm run jest"
                //             if (rc != 0) { error 'lwc test run failed' }
                //         }
                //     }
                // }
            }
        }
        stage('Reports') {
            when { branch 'feature*' }
            steps {
                junit keepLongStdio: true, testResults: 'tests/*-junit.xml'
            }
        }
    }
    post {
        cleanup {
            echo 'sfdx ciorg delete'
            script {
                rc = sh returnStatus: true, script: "sfdx force:org:delete --targetusername ciorg --noprompt"
                if (rc != 0) { error 'org delete failed' }
            }
        }
    }
}