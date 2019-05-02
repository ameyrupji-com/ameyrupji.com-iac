# ameyrupji.com-iac

[![CircleCI](https://circleci.com/gh/ameyrupji-com/ameyrupji.com-iac.svg?style=svg)](https://circleci.com/gh/ameyrupji-com/ameyrupji.com-iac)

Infrastructure As Code (iac) for hosting ameyrupji.com in AWS using Terraform. This repository createds the necessary AWS infastructure enables quick deployment and easy testability in beta environment before the code can be promoted to the live website. The builds are triggered through CircleCI integration of this repository.

Please fell free to use any part of this repository. If you find this useful please dont forget to Star or Folk this repository. If there are things that you would like me to improve in this code feel free to point it out by creating an Issue.  

### Daigram
![Infrastructure Diagram](/images/ameyrupji.com-blueprint.png)

Link:
https://cloudcraft.co/view/a84a92f3-0147-42eb-be3e-bc849d99d6d6?key=7EtAxVRr-L84VOa7CFUsWA&embed=true

## Infrastructure
The following infrastructure needs to be created to host http://www.ameyrupji.com.

### Initial Setup
This needs to be done manually before you can run the terraform code below:

- Buy/Register ameyrupji.com domain through Route53 Service using the portal.
- Create the following S3 Buckets using the portal
  - ameyrupji.com-iac - Stores the terraform state files.
  - ameyrupji.com-assets - Stores the assets.
- Hosted zones should automatically created while registering domain.
- Create a certificate for *.ameyrupji.com through ACM Servie usijng the portal.

### Created through Terraform 
Two different environments are maintained **prod** and **beta**. For each of these environments the following resources are created:

- S3 Buckets

Bucket Use | Prod Bucket Name | Beta Bucket Name
--- | --- | --- 
Main Subdomain | ameyrupji.com | beta.ameyrupji.com
Alternate Subdomain | www.ameyrupji.com | www.beta.ameyrupji.com
Blog Subdomain | blog.ameyrupji.com | blog.beta.ameyrupji.com
Code Subdomain | code.ameyrupji.com | code.beta.ameyrupji.com
IaC Subdomain | iac.ameyrupji.com | iac.beta.ameyrupji.com
Images Subdomain | images.ameyrupji.com | images.beta.ameyrupji.com

- Hosted Zones Record Sets

Record Set Use | Prod Record Set Name | Beta Record Set Name
--- | --- | --- 
Main Subdomain |  | beta
Alternate Subdomain | www | www.beta
Blog Subdomain | blog | blog.beta
Code Subdomain | code | code.beta
IaC Subdomain | iac | iac.beta
Images Subdomain | images | images.beta

#### TODOs:

- [x] Api Gateway with domain (api) for sending emails as POST request through the UI.
- [ ] Lambda code as Git Submodule + Build changes.
- [ ] Cloud Front CDN for ameyrupji.com.
- [ ] Upgrade state to store in DynamoDB table to Terraform State.

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
