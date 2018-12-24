#!groovy

node {
    stage('checkout source') {
        checkout scm
    }
    echo env.BRANCH_NAME

    // stage('Authorize PROD') {
    //     when { branch 'master' }
    //     rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${DEV_HUB_CONSUMER_KEY} --username ${DEV_HUB_USERNAME} --jwtkeyfile build/server.key --setalias PROD"
    //     if (rc != 0) { error 'hub org authorization failed' }
    // }
    // stage('Deploy to PROD') {
    //     when { branch 'master' }
    //     // convert to metadata api
    //     rc = sh returnStatus: true, script: "sfdx force:source:convert --rootdir force-app/ --outputdir src/"
    //     if (rc != 0) {
    //         error 'metadata convert failed'
    //     }
    //     rc = sh returnStatus: true, script: "sfdx force:mdapi:deploy --checkonly true --deploydir src/ --ignoreerrors false --ignorewarnings false --targetusername PROD --testlevel RunLocalTests --wait 5"
    //     if (rc != 0) {
    //         error 'deploy failed'
    //     }
    //     // assign permset
    //     // rc = sh returnStatus: true, script: "sfdx force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname DreamHouse"
    //     // if (rc != 0) {
    //     //     error 'permset:assign failed'
    //     // }
    // }
    // stage('Authorize STAGE Sandbox') {
    //     when { branch 'stage' }
    //     rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${STAGE_CONSUMER_KEY} --username ${STAGE_USERNAME} --jwtkeyfile build/server.key --instanceurl https://test.salesforce.com --setalias STAGE"
    //     if (rc != 0) { error 'hub org authorization failed' }
    // }
    // stage('Deploy to STAGE') {
    //     when { branch 'stage' }
    //     // convert to metadata api
    //     rc = sh returnStatus: true, script: "sfdx force:source:convert --rootdir force-app/ --outputdir src/"
    //     if (rc != 0) {
    //         error 'metadata convert failed'
    //     }
    //     rc = sh returnStatus: true, script: "sfdx force:mdapi:deploy --checkonly false --deploydir src/ --ignoreerrors false --ignorewarnings false --targetusername STAGE --testlevel RunLocalTests --wait 5"
    //     if (rc != 0) {
    //         error 'deploy failed'
    //     }
    //     // assign permset
    //     // rc = sh returnStatus: true, script: "sfdx force:user:permset:assign --targetusername ${SFDC_USERNAME} --permsetname DreamHouse"
    //     // if (rc != 0) {
    //     //     error 'permset:assign failed'
    //     // }
    // }
    stage('Authorize') {
        echo env.BRANCH_NAME
        if(env.BRANCH_NAME ==~ /feature\.*/) {
            steps {
                rc = sh returnStatus: true, script: "sfdx force:auth:jwt:grant --clientid ${env.DEV_HUB_CONSUMER_KEY} --username ${env.DEV_HUB_USERNAME} --jwtkeyfile build/server.key --setdefaultdevhubusername"
                if (rc != 0) { error 'hub org authorization failed' }
            }
        }
    }
    stage('Build') {
        if(env.BRANCH_NAME ==~ /feature\.*/) {
            steps {
                rc = sh returnStatus: true, script: "sfdx force:org:create --definitionfile config/project-scratch-def.json --json --setdefaultusername --setalias ciorg --durationdays 1"
                if (rc != 0) { error 'scratch org creation failed' }
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

    stage('Run tests') {
        if(env.BRANCH_NAME ==~ /feature\.*/) {
            steps {
                timeout(time: 120, unit: 'SECONDS') {
                    rc = sh returnStatus: true, script: "sfdx force:apex:test:run --testlevel RunLocalTests --codecoverage --outputdir ${RUN_ARTIFACT_DIR} --resultformat junit"
                    if (rc != 0) { error 'apex test run failed' }
                }
                timeout(time: 120, unit: 'SECONDS') {
                    rc = sh returnStatus: true, script: "sfdx force:lightning:test:run -a myTestSuite.app"
                    if (rc != 0) { error 'aura test run failed' }
                }
                timeout(time: 120, unit: 'SECONDS') {
                    rc = sh returnStatus: true, script: "npm run jest"
                    if (rc != 0) { error 'lwc test run failed' }
                }
            }
        }
    }
    stage('Finish') {
        if(env.BRANCH_NAME ==~ /feature\.*/) {
            steps {
                rc = sh returnStatus: true, script: "sfdx force:org:delete --targetusername ciorg --noprompt"
                if (rc != 0) { error 'org delete failed' }
                junit keepLongStdio: true, testResults: 'tests/**/*-junit.xml'
            }
        }
    }
}