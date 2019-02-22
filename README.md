# ameyrupji.com-iac

[![CircleCI](https://circleci.com/gh/ameyrupji/ameyrupji.com-iac.svg?style=svg)](https://circleci.com/gh/ameyrupji/ameyrupji.com-iac)

Infrastructure as code for hosting ameyrupji.com in AWS using Terraform


## Infrastructure
The following infrastructure is created to host ameyrupji.com
- Domain (ameyrupji.com) - Created Manually
- Hosted zones - automatically created while registering domain
- S3 Buckets
  - ameyrupji.com-iac - Created Manually
  - ameyrupji.com
  - www.ameyrupji.com
  - beta.ameyrupji.com
  - blog.ameyrupji.com
  - code.ameyrupji.com
- Hosted Zones Record Sets
  - name = ""
  - name = "www"
  - name = "beta"
  - name = "blog"
  - name = "code"
- TODO: Cloud Front CDN for ameyrupji.com
- Enable storing of terraform state in DynamoDB

### Daigram



## Prerequisites
- [x] S3 Bucket created to store state
- [x] IAM Role to update state file (cirlce-ci-iac). Can have the following policies attached AmazonS3FullAccess, AmazonRoute53DomainsFullAccess
- [x] Update Environment Variables (AWS_ACCESS_KEY_ID, AWS_REGION, AWS_SECRET_ACCESS_KEY) in Environment variables for Build
