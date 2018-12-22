# SFDX  App

## Install Jenkins
Install and start Docker

docker build -t dangt85/jenkins .
docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home dangt85/jenkins

## Setup Jenkins CI

create pipeline build
connect to git repo
select ./Jenkinsfile

## Dev, Build and Test
current sfdx version v45.0 

install sfdx - current stable release 44.0
install pre-release
`$ sfdx plugins:intall salesforcedx@pre-release`

install vscode extensions
install vscode extension for lightning web components

## Resources


## Description of Files and Directories


## Issues


