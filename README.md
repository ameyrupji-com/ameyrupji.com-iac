# ameyrupji.com-iac

[![CircleCI](https://circleci.com/gh/ameyrupji/ameyrupji.com-iac.svg?style=svg)](https://circleci.com/gh/ameyrupji/ameyrupji.com-iac)

Infrastructure As Code (iac) for hosting ameyrupji.com in AWS using Terraform

## Infrastructure
The following infrastructure is created to host http://www.ameyrupji.com
- Domain (ameyrupji.com) - Created Manually
- Hosted zones - automatically created while registering domain
- S3 Buckets
  - ameyrupji.com-iac - Created Manually
  - ameyrupji.com
  - www.ameyrupji.com
  - beta.ameyrupji.com
  - blog.ameyrupji.com
  - code.ameyrupji.com
  - images.ameyrupji.com
- Hosted Zones Record Sets
  - name = ""
  - name = "www"
  - name = "beta"
  - name = "blog"
  - name = "code"
  - name = "images"
- [ ] Cloud Front CDN for ameyrupji.com
- [ ] DynamoDB table to Terraform State

### Daigram
![Infrastructure Diagram](/images/ameyrupji.com-blueprint.png)

Link:
https://cloudcraft.co/view/a84a92f3-0147-42eb-be3e-bc849d99d6d6?key=7EtAxVRr-L84VOa7CFUsWA&embed=true


## Prerequisites
- [x] S3 Bucket created to store state (ameyrupji.com-iac).
- [x] IAM Role to update state file (cirlce-ci-iac). Can have the following policies attached AmazonS3FullAccess, AmazonRoute53DomainsFullAccess.
- [x] Update Environment Variables (AWS_ACCESS_KEY_ID, AWS_REGION, AWS_SECRET_ACCESS_KEY) for Build to be able to communicate with AWS.
