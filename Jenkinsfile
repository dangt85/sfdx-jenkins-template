#!groovy

node {
    echo env.BRANCH_NAME
    if(env.BRANCH_NAME == 'master') {
        echo 'master'
    } else if (env.BRANCH_NAME == 'stage') {
        echo 'stage'
    }
}