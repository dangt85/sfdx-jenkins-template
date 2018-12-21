#!groovy

node {
    def BUILD_NUMBER=env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"

    def DEV_HUB_USERNAME=env.DEV_HUB_USERNAME
    def DEV_HUB_CONSUMER_KEY=env.DEV_HUB_CONSUMER_KEY

    stage('checkout source') {
        checkout scm
    }

    stage('Authorize DevHub') {
        rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${DEV_HUB_CONSUMER_KEY} --username ${DEV_HUB_USERNAME} --jwtkeyfile build/server.key --setdefaultdevhubusername"
        if (rc != 0) { error 'hub org authorization failed' }
    }

    stage('Create Scratch Org') {
        rc = sh returnStatus: true, script: "sfdx force:org:create --definitionfile config/project-scratch-def.json --json --setdefaultusername --setalias ciorg --durationdays 1"
        if (rc != 0) { error 'scratch org creation failed' }
    }

    stage('Push To Test Org') {
        rc = sh returnStatus: true, script: "sfdx force:source:push"
        if (rc != 0) {
            error 'push failed'
        }
        // assign permset
        // rc = sh returnStatus: true, script: "sfdx force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname DreamHouse"
        // if (rc != 0) {
        //     error 'permset:assign failed'
        // }
    }

    stage('Run Apex Test') {
        sh "mkdir -p ${RUN_ARTIFACT_DIR}"
        timeout(time: 120, unit: 'SECONDS') {
            rc = sh returnStatus: true, script: "sfdx force:apex:test:run --testlevel RunLocalTests --codecoverage --outputdir ${RUN_ARTIFACT_DIR} --resultformat junit"
            if (rc != 0) {
                error 'apex test run failed'
            }
        }
    }

    stage('Delete Sratch Org') {
        rc = sh returnStatus: true, script: "sfdx force:org:delete --targetusername ciorg --noprompt"
        if (rc != 0) {
            error 'org delete failed'
        }
    }

    stage('Collect Test Results') {
        junit keepLongStdio: true, testResults: 'tests/**/*-junit.xml'
    }
}