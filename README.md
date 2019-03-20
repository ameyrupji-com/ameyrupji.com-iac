# ameyrupji.com-iac

[![CircleCI](https://circleci.com/gh/ameyrupji/ameyrupji.com-iac.svg?style=svg)](https://circleci.com/gh/ameyrupji/ameyrupji.com-iac)

Infrastructure As Code (iac) for hosting ameyrupji.com in AWS using Terraform

## Infrastructure
The following infrastructure is created to host http://www.ameyrupji.com
- Domain (ameyrupji.com) - Created Manually
- S3 Buckets - Created Manually
  - ameyrupji.com-iac
  - ameyrupji.com-assets
- Hosted zones - automatically created while registering domain
- Certificate through ACM for *.ameyrupji.com - Created Manually
- Two different environments are maintained prod and beta. In each of these environments the following buckets are created:

Bucket Use | Prod Bucket Name | Beta Bucket Name
--- | --- | --- 
Main Subdomain | ameyrupji.com | beta.ameyrupji.com
Alternate Subdomain | www.ameyrupji.com | www.beta.ameyrupji.com
Blog Subdomain | blog.ameyrupji.com | blog-beta.ameyrupji.com
Code Subdomain | code.ameyrupji.com | code-beta.ameyrupji.com
Images Subdomain | images.ameyrupji.com | images-beta.ameyrupji.com

- Hosted Zones Record Sets

Record Set Use | Prod Record Set Name | Beta Record Set Name
--- | --- | --- 
Main Subdomain |  | beta
Alternate Subdomain | www | www.beta
Blog Subdomain | blog | blog-beta
Code Subdomain | code | code-beta
Images Subdomain | images | images-beta
- [ ] Cloud Front CDN for ameyrupji.com
- [ ] DynamoDB table to Terraform State

### Daigram
![Infrastructure Diagram](/images/ameyrupji.com-blueprint.png)

Link:
https://cloudcraft.co/view/a84a92f3-0147-42eb-be3e-bc849d99d6d6?key=7EtAxVRr-L84VOa7CFUsWA&embed=true


## Prerequisites
- [x] User for programatic AdminAccess (cli-user)
- [x] S3 Bucket created to store state (ameyrupji.com-iac) and artifacts (ameyrupji.com-artifacts).
- [x] IAM User to run terrafrom scripts (cirlce-ci-iac). The following policies need to be attached:
    - AmazonS3FullAccess
    - AmazonRoute53DomainsFullAccess
    - AWSAPIGatewayAdmin
    - AWSLambdaFullAccess
    - AWSIAMFullAccess
    - AWSCertificateManagerReadOnly
- [x] Update Environment Variables (AWS_ACCESS_KEY_ID, AWS_REGION, AWS_SECRET_ACCESS_KEY) for CircleCI Build to be able to communicate with AWS.
