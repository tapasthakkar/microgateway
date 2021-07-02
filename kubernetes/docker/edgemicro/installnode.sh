#!/bin/bash
set echo off

# For development purpose
cd /opt/apigee
git clone -b docker_dev https://github.com/tapasthakkar/microgateway.git
cd microgateway
npm install
npm link

# npm install --only=production --no-optional -g edgemicro