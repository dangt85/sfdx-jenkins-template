#!groovy

node {
    stage('checkout source') {
        checkout scm
    }
    

    if(env.BRANCH_NAME == 'master') {
        prodDeploy()
    } else if(env.BRANCH_NAME == 'stage') {
        stageDeploy()
    } else if(env.BRANCH_NAME ==~ /feature\.*/) {
        ciBuild()
    }
}

def BUILD_NUMBER=env.BUILD_NUMBER
def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"

def DEV_HUB_USERNAME=env.DEV_HUB_USERNAME
def DEV_HUB_CONSUMER_KEY=env.DEV_HUB_CONSUMER_KEY

def ciBuild() {
    stage('Authorize DevHub') {
        rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${DEV_HUB_CONSUMER_KEY} --username ${DEV_HUB_USERNAME} --jwtkeyfile build/server.key --setdefaultdevhubusername"
        if (rc != 0) { error 'hub org authorization failed' }
    }

    stage('Create CI Org') {
        rc = sh returnStatus: true, script: "sfdx force:org:create --definitionfile config/project-scratch-def.json --json --setdefaultusername --setalias ciorg --durationdays 1"
        if (rc != 0) { error 'scratch org creation failed' }
    }

    stage('Push Source To CI Org') {
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

    parallel('Run tests') {
        stage('Run Apex Tests') {
            timeout(time: 120, unit: 'SECONDS') {
                rc = sh returnStatus: true, script: "sfdx force:apex:test:run --testlevel RunLocalTests --codecoverage --outputdir ${RUN_ARTIFACT_DIR} --resultformat junit"
                if (rc != 0) {
                    error 'apex test run failed'
                }
            }
        }
        stage('Run Aura Tests') {
            timeout(time: 120, unit: 'SECONDS') {
                rc = sh returnStatus: true, script: "sfdx force:lightning:test:run -a myTestSuite.app"
                if (rc != 0) {
                    error 'aura test run failed'
                }
            }
        }
        // stage('Run LWC Tests') {
        //     timeout(time: 120, unit: 'SECONDS') {
        //         rc = sh returnStatus: true, script: "npm run jest"
        //         if (rc != 0) {
        //             error 'lwc test run failed'
        //         }
        //     }
        // }
    }

    parallel('Free up ciorg and report tests results') {
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
}

def prodDeploy() {
    stage('Authorize PROD') {
        rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${DEV_HUB_CONSUMER_KEY} --username ${DEV_HUB_USERNAME} --jwtkeyfile build/server.key --setalias PROD"
        if (rc != 0) { error 'hub org authorization failed' }
    }

    stage('Deploy to PROD') {
        // convert to metadata api
        rc = sh returnStatus: true, script: "sfdx force:source:convert --rootdir force-app/ --outputdir src/"
        if (rc != 0) {
            error 'metadata convert failed'
        }
        rc = sh returnStatus: true, script: "sfdx force:mdapi:deploy --checkonly true --deploydir src/ --ignoreerrors false --ignorewarnings false --targetusername PROD --testlevel RunLocalTests --wait 5"
        if (rc != 0) {
            error 'deploy failed'
        }
        // assign permset
        // rc = sh returnStatus: true, script: "sfdx force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname DreamHouse"
        // if (rc != 0) {
        //     error 'permset:assign failed'
        // }
    }
}

def stageDeploy() {
    stage('Authorize STAGE Sandbox') {
        rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${STAGE_CONSUMER_KEY} --username ${STAGE_USERNAME} --jwtkeyfile build/server.key --instanceurl https://test.salesforce.com --setalias STAGE"
        if (rc != 0) { error 'hub org authorization failed' }
    }

    stage('Deploy to STAGE') {
        // convert to metadata api
        rc = sh returnStatus: true, script: "sfdx force:source:convert --rootdir force-app/ --outputdir src/"
        if (rc != 0) {
            error 'metadata convert failed'
        }
        rc = sh returnStatus: true, script: "sfdx force:mdapi:deploy --checkonly false --deploydir src/ --ignoreerrors false --ignorewarnings false --targetusername STAGE --testlevel RunLocalTests --wait 5"
        if (rc != 0) {
            error 'deploy failed'
        }
        // assign permset
        // rc = sh returnStatus: true, script: "sfdx force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname DreamHouse"
        // if (rc != 0) {
        //     error 'permset:assign failed'
        // }
    }
}