# ameyrupji.com-iac

[![CircleCI](https://circleci.com/gh/ameyrupji/ameyrupji.com-iac.svg?style=svg)](https://circleci.com/gh/ameyrupji/ameyrupji.com-iac)

Infrastructure as code for hosting ameyrupji.com in AWS using Terraform


## Infrastructure diagram


## Prerequisites before running terraform commands
- [x] S3 Bucket created to store state
- [x] IAM Role to update state file (cirlce-ci-iac). Can have the following policies attached AmazonS3FullAccess, AmazonRoute53DomainsFullAccess
- [x] Update Environment Variables (AWS_ACCESS_KEY_ID, AWS_REGION, AWS_SECRET_ACCESS_KEY) in Environment variables for Build
