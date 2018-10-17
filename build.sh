#!/bin/bash -exu

export repositoryName="minecraft"
export region="ap-southeast-2"
export AWS_REGION=$region
export AWS_DEFAULT_REGION=$region
aws configure set region $region

docker build -t minecraft minecraft-image

aws ecr describe-repositories --repository-names $repositoryName 2>/dev/null || aws ecr create-repository --repository-name $repositoryName

# Could do this as a single query
registryId=`aws ecr describe-repositories --repository-names $repositoryName --query 'repositories[0].registryId' --output text`
repositoryUri=`aws ecr describe-repositories --repository-names $repositoryName --query 'repositories[0].repositoryUri' --output text`
set +x
$(aws ecr get-login --no-include-email --registry-ids $registryId)
set -x

docker tag minecraft:latest $repositoryUri:latest
docker push $repositoryUri:latest
