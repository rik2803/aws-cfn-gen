# AWS CloudFormation Template Generator

[toc]

## TL;DR

This repository consists of:

* A _Ansible_ playbook
* A number of _Ansible_ templates that generate AWS CloudFormation templates with an external configuration
  file as driver

Combined with the configuration file, the _Ansible_  playbook creates a set of
AWS CloudFormation templates, and deploys these templates to your AWS account.

Example execution command:

```
ansible-playbook CreateOrUpdateEnv.yml --extra-vars configfile=/path/to/your/environment/config/file
```

## Dependencies and Prerequisites

* A _Docker_ engine when using the `dockerwrapper` to build and deploy the templates
* A local _Ansible_ and _AWS CLI_ client installation when **not** using the
  `dockerwrapper`

## Running the playbook

### Creating changesets and printing the changeset report

When the switch `-e create_changeset=yes` is added to the command, nothing will be changed,
a _change set_ will be created for all processed templates (`--tags` also works), and a
change set report will be printed at the end of the playbook.

An example:

```bash
$ ansible-playbook CreateOrUpdateEnv.yml \
    --extra-vars configfile=~/projects/IxorDocs/aws-ixor.ixordocs-dev-ixordocs-config/config.yml \
    --extra-vars create_changeset=yes \
    --tags=bastion,cw

...

TASK [Dump changeset report] *************************************************************
ok: [localhost] => {
    "changeset.stdout_lines": [
        "IxordocsDevBastion",
        "Modify BastionHost True",
        "Modify RecordSetForBastionHost Conditional",
        "IxordocsDevCW",
        "Modify AwsLambdaCWLogsSubscription False",
        "Modify AwsLambdaCWLogsSubscriptionPermission Conditional",
        "Modify AwsLambdaEC2InstallCWAgent False",
        "Modify AwsLambdaEC2InstallCWAgentPermission Conditional",
        "Modify CWEventRuleCWCreateLogGroup False",
        "Modify CWEventRuleSSMInstallCWAgent False",
        "Remove TestPolicy None",
        "IxordocsDevBastion",
        "Modify BastionHost True",
        "Modify RecordSetForBastionHost Conditional",
        "IxordocsDevCW",
        "Modify AwsLambdaCWLogsSubscription False",
        "Modify AwsLambdaCWLogsSubscriptionPermission Conditional",
        "Modify AwsLambdaEC2InstallCWAgent False",
        "Modify AwsLambdaEC2InstallCWAgentPermission Conditional",
        "Modify CWEventRuleCWCreateLogGroup False",
        "Modify CWEventRuleSSMInstallCWAgent False",
        "Remove TestPolicy None",
        "IxordocsDevBastion",
        "Modify BastionHost True",
        "Modify RecordSetForBastionHost Conditional",
        "IxordocsDevCW",
        "Modify AwsLambdaCWLogsSubscription False",
        "Modify AwsLambdaCWLogsSubscriptionPermission Conditional",
        "Modify AwsLambdaEC2InstallCWAgent False",
        "Modify AwsLambdaEC2InstallCWAgentPermission Conditional",
        "Modify CWEventRuleCWCreateLogGroup False",
        "Modify CWEventRuleSSMInstallCWAgent False",
        "Remove TestPolicy None",
        "IxordocsDevBastion",
        "Modify BastionHost True",
        "Modify RecordSetForBastionHost Conditional",
        "IxordocsDevCW",
        "Modify AwsLambdaCWLogsSubscription False",
        "Modify AwsLambdaCWLogsSubscriptionPermission Conditional",
        "Modify AwsLambdaEC2InstallCWAgent False",
        "Modify AwsLambdaEC2InstallCWAgentPermission Conditional",
        "Modify CWEventRuleCWCreateLogGroup False",
        "Modify CWEventRuleSSMInstallCWAgent False",
        "Remove TestPolicy None",
        "IxordocsDevBastion",
        "Modify BastionHost True",
        "Modify RecordSetForBastionHost Conditional",
        "IxordocsDevCW",
        "Modify AwsLambdaCWLogsSubscription False",
        "Modify AwsLambdaCWLogsSubscriptionPermission Conditional",
        "Modify AwsLambdaEC2InstallCWAgent False",
        "Modify AwsLambdaEC2InstallCWAgentPermission Conditional",
        "Modify CWEventRuleCWCreateLogGroup False",
        "Modify CWEventRuleSSMInstallCWAgent False",
        "Remove TestPolicy None",
        "IxordocsDevBastion",
        "Modify BastionHost True",
        "Modify RecordSetForBastionHost Conditional",
        "IxordocsDevCW",
        "Modify AwsLambdaCWLogsSubscription False",
        "Modify AwsLambdaCWLogsSubscriptionPermission Conditional",
        "Modify AwsLambdaEC2InstallCWAgent False",
        "Modify AwsLambdaEC2InstallCWAgentPermission Conditional",
        "Modify CWEventRuleCWCreateLogGroup False",
        "Modify CWEventRuleSSMInstallCWAgent False",
        "Remove TestPolicy None"
    ]
}

PLAY RECAP ******************************************************************************************
localhost                  : ok=39   changed=14   unreachable=0    failed=0   

```

## Running the playbook in a controlled way

### Background

The Ansible templates used for the creation of the AWS CloudFormation templates, much like
any other kind of code, evolves. Sometimes, evolution has a price, and that price is
backward compatibility.

To make sure that a _aws-cfn-gen_ configuration file will still build after a backward
compatibility breaking change, the build environment should not change in time.

This is solved by using a _Docker_ image to create the AWS CloudFormation templates and
to deploy these AWS CloudFormation templates to the desired account.

The _Docker_ image contains a combination of _ansible_ and _AWS CLI_ versions, and running
the _Docker_ image with the right set of environment variables allows the user to choose
the _tag_ in this repository to checkout for the build and deploy.

The _Docker_ image is called `ixor/ansible-aws-cfn-gen` and can be
found [here](https://hub.docker.com/r/ixor/ansible-aws-cfn-gen/). The documentation for
this _DockerWrapper_ is in rhe file `README_DOCKERWRAPPER.md` in this repository.

### An example _dockerwrapper_ script

If, for example, you have a configuration file, `config.yml` that is tested and approved
with:

  * Ansible v2.6.1
  * AWS CommandLine version 1.6
  * v0.1.0 of the template files in this repository.

Your `dockerwrapper` script will look like this:

```bash
#! /bin/bash

GITTAG=v0.1.0

docker run --rm \
    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
    -e AWS_REGION=${AWS_REGION:-eu-central-1} \
    -e AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
    -e GITTAG=${GITTAG:-v0.1.0} \
    -e ANSIBLE_TAGS=${ANSIBLE_TAGS:-} \
    -e CONFIG=config.yml \
    -v ${PWD}:/config \
    -it \
    ixor/ansible-aws-cfn-gen:2.6.1-aws-1.6
```

To create the _AWS CloudFormation_ template files and deploy them to the AWS account of your choice,
follow these steps:

* Start your (_Docker_) engines
* **Set _AWS Credentials_ for that account**. The roles and policies linked to the user that owns these
  credentials should be able to create all the configured resources in that account. The first step when
  the container is started is to check the account id you are logged in to with the account id in the
  configuration file.  If they do not match, the build is cancelled.
* (**optional**) Set the **environment variables** `ANSIBLE_TAGS` and `ANSIBLE_SKIPTAGS` to limit the
  execution of the playbook to just the services you include minus the service you exclude.
* Run the `dockerwrapper` script created above, by running `bash dockerwrapper`

## Resources that can be created using this repository

* AWS Application Load Balancers (ALB)
* AWS ECR
* AWC ECS Cluster
* AWS ECS Tasks and Services
* S3 buckets
* Route 53 private Hosted Zones
* IAM Users, Roles and Policies
* CloudFront distribution
* DynamoDB tables

Following _modules_ have their own documentation file:

* [Elastic Container Registry](docs/ECR.md)
* [Elastic Container Service](docs/ECS.md)
* [The mamagement ECS Fargate cluster](docs/ECSMgmt.md)
* [KMS](docs/MKS.md)
* [RDS](docs/RDS.md)
* [RDS Parameter Group](docs/RDSParameterGroups.md)
* [SecretsManager](docs/SecretsManager.md)

## Order of installation is important

The template for certain resources may depend on resources created by other
templates. Those templates obviously have to be deployed for the dependencies
to exist.

Therefor, the order of resource creation in the main playbook (`CreateOrUpdateEnv.yml`)
should not be changed, unless there is a dependency issue and changing the order does
not introduce new dependencies.

## Configuration file

### The project configuration

The project configuation is used throughout the templates, mostly to prefix resource
names and resource logical names to guarantee uniqueness.

All `cfn_name` properties are used to create the CloudFormation logical resource names.
Those name can only include letters and numbers.

```yaml
organization:
  name: Acme
  cfn_name: Acme
```

```yaml
project:
  name: my_big_project-prd
  shortname: mbp-prd
```

### Configuration to _tag_ resources created by _CloudFormation_

These tags can be used in _Cost Explorer_ to create reports per environment and per application, for example.

```yaml
application: mybigapplication
env: prd
```

### The `referenced_stacks`

These are stacks (usually only the VPC stack) created by [these templates](https://github.com/rik2803/aws-cfn-templates),
and used troughout `aws-cfn-gen`. As said in the _Dependencies and Prerequisites_ section, this is meant
to disappear over time.

```yaml
referenced_stacks:
  VPCStackName: "VPCForAcmePrd"
``` 

### Describe the account where de deployment will be done

This is mostly used for sanity checks (are you running on the account you think you are running on?)
and for the region.

```yaml
target_account:
  name: "acme.mybigapplication-prd"
  account_id: "123456789012"
  region: "eu-central-1"
```

### Create a _best practices_ VPC

Example configuration:

```
vpc:
  stackname: "MyVPCCFNStackName"
  name: "MyVPC"
  safe_ssh_01: "1.2.3.4/32"
  safe_ssh_02: "1.2.3.5/32"
  create_rds_subnets: true
  nfs_for_sg_app: true
  environment: "dev"
  cidr: 10.121
  nr_of_azs: 3
  application: "myapp"
```

Running the environment setup with this config will create these resources following
the AWS VPC Reference Architecture:

* A public subnet `xxx.yyy.0.0/24` (i.e. for bastion)
* A IGW
* A NAT GW (only one, while not redundant, this saves on the bill)
* 3 (or 2) Private subnets for applications
  * `xxx.yyy.10.0/24`
  * `xxx.yyy.11.0/24`
  * `xxx.yyy.12.0/24`
* 3 (or 2) Public subnets for ELB
  * `xxx.yyy.20.0/24`
  * `xxx.yyy.21.0/24`
  * `xxx.yyy.22.0/24`
* 3 (or 2) Public subnets for RDS (optional)
  * `xxx.yyy.30.0/24`
  * `xxx.yyy.31.0/24`
  * `xxx.yyy.32.0/24`
* 2 routing tables (private and public)
* The necessary security groups to allow:
  * `ssh` traffic to the public subnet from `safe_ssh_01` and
    `safe_ssh_01`
  * *HTTP* and *HTTPS* traffic from everywhere to the load balancer subnets
  * *HTTP* and *HTTPS* traffic from the load balancer subnets to the
    application subnets
  * Database traffic (*MySQL*, *PostgreSQL* and *SQL Server*) from the
    application subnets to the RDS suibnets
  * (**optional**) NFS traffic from the application subnets

#### `vpc.stackname`

The name used to create the _CloudFormation_ stack. This name will also be used
when referncing to the VPC stack in the `referenced_stacks` list.

#### `vpc.name`

The name of the VPC.

#### `vpc.cidr`

The first 2 bytes of the network CIDR for the VPC. Will be extended with
`.0.0/16` to form a cpmplete CIDR.

#### `vpc.safe_ssh_01` and `vpc.safe_ssh_01`

Used to create a _Security Group_ for the public subnets that allow `ssh` traffic
from a limited (range of) IP addresses.

#### `vpc.create_rds_subnets`

Should subnets and a subnet group be created for RDS?

#### `vpc.nfs_for_sg_app`

Should the applicaton subnets be allowed to use NFS (i.e. for `EFS`)

#### `vpc.environment`

The application environment (dev, acc, prd, ....). Used to tag resources.

#### `vpc.application`

The name of the application (dev, acc, prd, ....). Used to tag resources.

#### `vpc.nr_of_azs`

The number of AZs to create subnets in. Default is 2, is set to `3`, 3 subnets
will be created for LB, private and RDS subnets.


### The _Bastion_ host

An example:

```yaml
bastion:
  instance_type: t2.micro
  route53_sns_topic: arn:aws:sns:eu-central-1:123456789012:RequestRoute53CNAMEZ123456789012
  hostname: "bastion-myaccount"
  domain: "acme.com"
  keypair_name: "id_rsa_myaccount"
  pubkeys:
    - owner: "user01"
      key: "ssh-rsa ........"
    - owner: "user02"
      key: "ssh-rsa ........"
  hostkeys:
    - type: "ecdsa-sha2-nistp256"
      location: "/etc/ssh/ssh_host_ecdsa_key"
      key: "-----BEGIN EC PRIVATE KEY-----\\nMHcCAQEEIA\\nANOTHERLINE\\n...."
```

When this configuration is present in the configuration file, and the `aws-cfn-gen` stack is run, these resources will be created:

* An EC2 instance
* A Route53 RecordSet (optional)

#### `bastion.instance_type` (Optional, default is `t2.micro`)

#### `bastion.route53_sns_topic` (Optional)

When set, a _Custom_ resource will be created that triggers the creation of a _Route53 RecordSet_
on the AWS account where the domain is managed. The current account needs to have permission to
post events to the SNS topic.

If this property is not defined, not _Route53 RecordSet_ will be created.

#### `bastion.hostname` (Optional)

Only required if `bastion.route53_sns_topic` is set.

#### `bastion.domain` (Optional)

Only required if `bastion.route53_sns_topic` is set.

#### `keypair_name`

The name of an existing SSH key pair.

#### `bastion.pubkeys` (Optional, but required when `bastion.hostkey` is present)

A list of dictionaries with these keys:

* `user`: The name of the owner of the SSH public key
* `key`: The SSH public key string

#### `bastion.hostkeys` (Optional, but required when `bastion.pubkeys` is present)

To avoid having to accept the host's host key after every re-creation
of the bastion host, you can save the host keys and have them re-created
when the instance is re-instantiated.

The value for `bastion.hostkeys` is a list of dictionaries with these keys:

* `type`: The type of the host key (i.e. `ecdsa-sha2-nistp256`)
* `location`: The full path of the file for the private key
* `key`: The SSH private key string, on one line, add newlines
  with `\\n`

### Create _CloudWatch_ related resources

Create a scheduled _CloudWatch_ event or a _CloudWatch_ rule and attach a target
by importing a value (`ARN`) from the exports of another CloudFormation stack.


```yaml
cw:
  auto_config_log_group_lambda_s3_key: "cw-logs-new-stream-to-lambda-9...ed50.zip"
  log_group_settings:
    retention_in_days: 14
    filter_pattern: "-DEBUG"
  logshipper_lambda_function_arn_import: "MyLogshipperLambdaImport"
  event_rules:
    - name: "Demo"
      source: "aws.logs"
      detail_type: "AWS API Call via CloudTrail"
      event_source: "logs.amazonaws.com"
      event_name:
        - "CreateLogGroup"
      description: "Emit event whenever a CreateLogGroup API call is made"
      targets:
        - type: "import"
          value: "MyLambdaImport"
  scheduled_rules:
    - name: "ScheduledEventDaily6AM"
      description: "Triggers daily at 6 AM"
      schedule_expression: "cron(0 6 * * ? *)"
      targets:
        - type: "import"
          value: "MyLambdaImport"
```

The value for `filter_pattern` in `cw.log_group_settings` is described in the [AWS documentation](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html
). Use an empty string to disable the filter.
          
### Create _Lambda_ functions

Let's start with an example:

```yaml
lambda_functions:
  - name: aws-lambda-s3-logs-to-cloudwatch
    handler: handler
    runtime: nodejs8.10
    role: S3ToCloudwatchLogsRole
    vpc: true | false
    code:
      s3_bucket: "{{ lambda_function_bucket_name }}"
      s3_key: aws-lambda-s3-logs-to-cloudwatch-06b0c5cda86555d95f5939bedeca17830c81ff98.zip
    environment:
      - name: LOGGROUP_NAME
        value: lb_access_logs
      - name: LOGSTREAM_NAME
        value: albint
    invoke_permissions:
      - type: predefined
        description: "Allows bucket events to trigger this lambda function"
        name: s3
        bucket_arn: "arn:aws:s3:::ixordocs-dev-accesslogs-albint"
```

**How to use the same function more than once in an environment?**

Sometimes, the same function needs to be used more than once, for example if there are different
triggers or a different set onf environment variables that influence the execution and the result
of the function.

To achieve this, create identical blocks (with different envvars or whatever changes), and the
`name` should have a suffix that starts with un underscore.

#### `name`

The name determines:

* The _CloudFormation_ resource name
* The name of the function (i.e. the name of the file in the zip defined by 
  `'s3://' + code.s3_bucket + '/' + 'code.s3_key'`), unless `function_name`
  is defined.
  
The `name` can contain:

* letters
* numbers
* hyphens
* 0 or 1 underscores, used to differentiate the _CFN_ resource name in case of
  multiple instances of the same function.
  
If the name contains an underscore, the part before the underscore is used to determine
the function name, and the complete string is used, after some _CFN_ related transformation,
as the _CloudFormation_ resource name. 

#### `function_name`

Assign fixed name to Lambda function, if the property is present. Changing this
name will cause the resource to be re-created (and the old resource to be removed). This is at risk of the user.

#### `handler`

#### `runtime`

#### `timeout` (default `3`)

#### `memory_size` (default `128`)

#### `role`

#### `code.s3_bucket`

#### `code.s3_prefix`

#### `vpc`

The function will be in the (private) application subnets defined by `vpc_privatesubnet_az*` and
the associated _Security Group_ will be `vpc_sg_app`.

#### `environment`

##### `environment[n].name`

##### `environment[n].value`

#### `invoke_permissions`

Determine the principals that are allowed `lambda:InvokeFunction` for the
Lambda function.

#### `execution_role_permissions`

Used to create a role that grants the required permissions to the Lambda.

```yaml
lambda_functions:
  - name: aws-lambda-myFunction
    ...
    execution_role_permissions:
      - type: sns
        
```

### Create _Lambda_ functions in `us-east-1`

Usage is identical to `lambda_functions`, but use `lambda_functions_cloudfront` instead.

To make this possible, some other changes have to be done to the account configuration, this
is taken care off by [https://github.com/rik2803/aws-account-config]():

* Create Lambda bucket in all regions you use
* Deply the lambda functions to those different buckets


### Creation of IAM related resources

Some IAM resources are implicitely created by other components, i.e. in _CloudFront_ to allow
a user to invalidate the _CloudFront_ distributions.

But it is sometimes useful to be able to create your own roles and policies. This can be
accomplished by using these configuration sections:

* `managed_policies`
* `awsroles` (this used to be called `roles`, but _Ansible_ complained about me using its reserved word)
* `iam_users`: Create users, assign policies and (optionally) create credentials

#### `managed_policies`

A list of policies, syntax is identical to the *CloudFormation* syntax for [`AWS::IAM::ManagedPolicy`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-managedpolicy.html).

```yaml
managed_policies:
  - name: S3DeployArtifactsAccess
    policy_document:
      Version: '2012-10-17'
      Statement:
        - Sid: AllowReadAccessToS3CentralDeployArtifacts
          Effect: Allow
          Action:
            - s3:GetObject
            - s3:GetObjectAcl
            - s3:ListBucket
          Resource:
            - arn:aws:s3:::acme-s3-deploy-artifacts
            - arn:aws:s3:::acme-s3-deploy-artifacts/*
```

#### `awsroles`

A list of roles, syntax is identical to the *CloudFormation* syntax for [`AWS::IAM::Role`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-role.html).

```yaml
awsroles:
  - name: MyECSGeneralTaskRole
    policy_arns:
      # The last part in arn:aws:iam::account_id:policy/policyname
      - S3DeployArtifactsAccess
    assumerole_policy_document:
      Version: '2012-10-17'
      Statement:
        - Sid: ''
          Effect: Allow
          Principal:
            Service: ecs-tasks.amazonaws.com
          Action: sts:AssumeRole
```

#### `iam_users`

```yaml
iam_users:
  - name: s3-deploy
    cfn_name: S3DeployUser
    managed_policies:
      - S3DeployArtifactsAccess
    create_accesskeys: true
```

##### `managed_policies`

Before `0.1.5`, managed policies for `iam_users` were interpreted as a policy name and
extended to `arn:aws:iam::123456789012:policy/<name>`. From version `0.1.5`, the full
`arn` can also be specified.

### `ecs`: _Elastic Container Services_

Moved to [here](docs/ECS.md).

### `loadbalancers`: Create _Application Load Balancers_

`loadbalancers` is a list of, you guessed it, loadbalancers.

It creates a typical loadbalancer, with these components:

* An ALB or *Application LoadBalancer* (`AWS::ElasticLoadBalancingV2::LoadBalancer`).
  This can be an internet-facing loadbalancer (`scheme: internet-facing`), or an internal
  loadbalancer (`scheme: internal`).
* The _Security Groups_ and subnets used for the loadbalancer are extracted from the
  VPC stack mentioned before. That stack uses AWSs reference architecture and matches most setups.
* A HTTP listener on both internet-facing and internal loadbalancers.
* A HTTPS listener on the internet-facing loadbalancer. This requires a certificate for TLS
  termination.
* A default target group for HTTP and HTTPS
* Additional rules and target groups are created for the services defined in
  `applicationconfig`
* (optional) Define redirects, see below in `redirects`

```yaml
loadbalancers:
  - name: ALBExt
    scheme: "internet-facing"
    certificate_arn: "arn:aws:acm:eu-central-1:123456789012:certificate/55555555-4444-4444-7777-555555555555"
    def_tg_http_healthcheckpath: /health
    def_tg_https_healthcheckpath: /health
  - name: ALBInt
    scheme: "internal"
    idle_timeout_seconds: 120
    accesslogs:
      state: enabled
      log_expiry_days: 14
      s3_objectcreated_lambda_import: StackName-LambdaTriggeredOnS3ObjectCreation
      cw_logs:
        log_group_name: lb_loggroup_name
      cw_logs_subscription_filter:
        type: lambda
        lambda_cfn_export_name: ExportName
        filter_pattern: "-DEBUG"  
```

#### `ssl_policy` (optional, default is `ELBSecurityPolicy-2016-08`)

The SSL/TLS policy to use for the HTTPS listener. It defaults to today's AWS default
`ELBSecurityPolicy-2016-08`, and can have any value from the list you can find
[here](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies).

#### `access_logs`

When `access_logs` is defined and `state` is `enabled`,
following resources are created:

* A S3 bucket named `{{application }}-{{ env }}-accesslogs-{{ lbname }}`
* An lifecycle rule that expires the access logs after `log_expiry_days` days
* A bucket policy that allows the AWS ALB account in the current region to
  write to that bucket
* A `s3.ObjectCreated` trigger to a lambda function if
  `accesslogs.s3_objectcreated_lambda_import` is defined. That *Lambda* function can, for example,
  be used to ship the S3 logs to *CloudWatch*.

And the loadbalancer will get the attributes required to enable access logs, as specified
[here](https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_LoadBalancerAttribute.html).

#### `access_logs.cw_logs`

* `access_logs.cw_logs.log_group_name`: the log group name to be created and where
  `s3_objectcreated_lambda_import` will send the logs to

#### `access_logs.cw_logs_subscription_filter`

The CW logs subscription filter to assign to the log group. It can be a Lambda function that sends
the log to a service such as DataDogHQ.

* `access_logs.cw_logs_subscription_filter.type`: Currently only `lambda`
* `access_logs.cw_logs_subscription_filter.lambda_cfn_export_name`: Used if `type == `lambda`,
  it's an export from another CloudFormation stack that returns the ARN of the Lambda function
  to be used
* `access_logs.cw_logs_subscription_filter.filter_pattern`: The (optional) filter to apply to the
  subscription filter. Can be a positive or a negative filter.

#### `idle_timeout_seconds`

Default is `60`, sets the LB `LoadBalancerAttribute` named `idle_timeout.timeout_seconds` to this
value.

#### `redirects`

```yaml
loadbalancers:
  - name: ALBExtRedirectTest
    ...
```

`redirects` is a list of dicts that define URLs to redirect.

##### `redirects[n].host_header` (required)

A hostname that will trigger the redirect.

##### `redirects[n].path_pattern` (optional)

A `path_pattern` strings that will trigger the redirect.

##### `redirects[n].priority` (required)

Determines the order of the redirect rules.

##### `redirects[n].status_code` (optional, default is `HTTP_301`)

On of these strings:

* `HTTP_301` for permanent redirect
* `HTTP_302` for temporary redirect

##### `redirects[n].to` (optional, default is original host)

##### `redirects[n].path`  (optional, default is original path)

##### `redirects[n].skiproute53` and `redirects[n].skiproute53public` and `redirects[n].skiproute53private`

Skip the creation of a *Route 53* record if `true`.

* `redirects[n].skiproute53`: Skip in both public and private hosted zone
* `redirects[n].skiproute53public`: Skip in public hosted zone
* `redirects[n].skiproute53private`: skip in private hosted zone


### `route53`

TODO

### `s3`

Create S3 buckets.

Other S3 buckets might be created implicitely by the other components (i.e. _CloudFront_),
but `s3` can be used to explicitely create buckets.


```yaml
s3:
  - name: mybucket
    cfn_name: MyBucket
    access_control: Private
    static_website_hosting: no
    versioning: {Enabled|Suspended}
    skip_output: {true|false}
    lifecycle_configuration: |
      Rules:
        - ExpirationInDays: 14
    cors:
      allowed_headers:
        - '*'
      allowed_methods:
        - 'GET'
        - 'PUT'
      allowed_origins:
        - '*'
```

#### `name`

The name for the bucket. The resulting name will be the value of this variable,
prefixed with `{{ application }}-{{ env }}-`.

```yaml
application: mybigapplication
env: prd

...

s3:
  - name: mybucket
    cfn_name: MyBucket
    access_control: Private
    static_website_hosting: no
```

For the above configuration, the resulting bucket will be named `mybigapplication-prd-mybucket`.

#### `cfn_name`

The name to be used for the _CloudFormation_ logical resource.

The final _CloudFormation_ logical name will be `{{ cfn_project }}{{ bucket.cfn_name }}` where
`{{ cfn_project }}`.

#### `access_control`

This setting grants predefined permissions to the bucket. All object created after this setting
was set or updated will get that ACL.

See [here](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) for valid values.


#### `static_website_hosting`

Valid values:

* `yes` or `Yes`
* `true` or `True`
* `on` or `On`

All other values will not enable website hosting on the bucket.

**Important**: This potentially exposes object to the evil internet.

#### `versioning`

Enable or disable (suspend) bucket versioning.

Allowed values:

* `Enabled`
* `Suspended`

#### `skip_output`

Default behaviour is to create an output for an s3 bucket, use this property to skip
the creation of the output.

This property was added to avoid the number of outputs to reach 60, which is a AWS limit
on the number of outputs per stack.

#### `lifecycle_configuration`

Use the exact same _yaml_ as described in [Amazon S3 Bucket Rule](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-bucket-lifecycleconfig-rule.html).

If `lifecycle_configuration` is not specified, the default lifecycle rule is:

```yaml
        Rules:
          - NoncurrentVersionExpirationInDays: 60
            Status: Enabled
```

#### 'cors'

Add CORS permissions to the bucket. This is optional, when omitted no CORS settings will be
applied. This is the default AWS behaviour.

You can specify all properties like this:

```yaml
s3:
  - name: mybucket
    cors:
      allowed_headers:
        - '*'
      allowed_methods:
        - 'GET'
        - 'PUT'
      allowed_origins:
        - '*'
      exposed_headers:
        - 'Header1'
        - 'Header2'
```

Or:

```yaml
s3:
  - name: mybucket
    cors: yes
```

The value does not matter, the presence of the `cors` property will apply these CORS settings to the
bucket:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<CORSRule>
    <AllowedOrigin>*</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>PUT</AllowedMethod>
    <AllowedHeader>*</AllowedHeader>
</CORSRule>
</CORSConfiguration>
```

Omitting a property from the configuration will use following defaults:

* `allowed_origins`: `['*']`
* `allowed_methods`: `['GET', 'PUT']`
* `allowed_headers`: `['*']`
* No defaults for `exposed_headers`


### `applicationconfig`

`applicationconfig` is a list of applications to run in the ECS cluster. Each
element in the `applicationconfig` list contains the application description.

For each service, a lot of resources are created:

* ECS Task Description
* ECS Service
* R53 Record Sets
* The application propeties are also used by the ALB stack to create:
  * ALB Listener rules
  * ALB Target Group
  * Target Health checks
* ... 
* _CloudWatch_ log group
  * Metric filter to create a custom CW metric to monitor service restarts. The _Metric Filter_ looks
    for the string determined by the property `applicationconfig[n].monitoring.start_filter_string`
    (default value is `Started Application in`)
  * Alarm on that metric filter, target is SNS Queue created when the AWS account was setup
    (also see `awc-account-config`)
  * The flow for the `ServiceStartAlert` is:
    * The ECS task is started
    * The logs are sent to the CW log group for that service
    * The Metric Filter scans for the `start_filter_string` and ...
    * ... creates a custom CloudWatch metric
    * The CloudWatch alarm is triggered
    * Sends en event to the SNS queue (created by the AWS account configuration (`aws-account-config`))
    * All subscribers to the SNS topic will receive the event (i.s Slack, Chat)


```yaml
  - name: "servicename"
    cfn_name: ServiceName
    target: "ecs"
    environment:
      - name: JAVA_TOOL_OPTIONS
        value: "-Xmx2048m"
    monitoring:
      start_filter_string: "string to match in service logs"
      alarm_actions_enabled: "true"
    ecs:
      image: "123456789012.dkr.ecr.eu-central-1.amazonaws.com/example/service:latest"
      containerport: 8080
      memory: 2048
      cpu: 512
      desiredcount: 2
      healthcheckgraceperiodseconds: 3600
      task_role_arn: "arn:aws:iam::123456789012:role/ECSTaskRole"
      ulimits:
        - name: nofile
          hard_limit: 102400
          soft_limit: 102400
    lb:
      name: ALBExt
      ### Can be public or private, determines if DNS entries are created in the public
      ### or private hosted zones.
      type: public
      healthcheckpath: /actuator/health
      healthcheckokcode: "200"

    domains:
      - name: example.com
        cfn_name: ExampleCom
        listener_rule_host_header: service.example.com
        priority: 210
      - name: voorbeeld.be
        cfn_name: VoorbeeldBe
        listener_rule_host_header: service.voorbeeld.be
        priority: 211
        skiproute53: false
```

#### `applicationconfig[n].name`

**Important**: The `name` should only contain letters, numbers, hyphens and colons. Underscores are not allowed.

**Important**: The `name` should not be changed one the service was created. If it **is** changed, the service
and the related reources might be recreated and will cause downtime.

The name defines the name to be used for the service. It is alse used to create related resources:

* _Listener Rule_ name in the `ALB.yml` template
* _Target Group_ CloudFormation export for use in other templates in `ALB.yml`
* Name of the _CloudWatch Log Group_ in `ECS.yml`
* Name of the _Task Definition_ in `ECS.yml`

#### `applicationconfig[n].cfn_name`

CloudFormation logical names are restricted to letters and numbers only. All `cfn_` properties are used
for naming _CloudFormation_ resource logical names.

#### `applicationconfig[n].target`

Where and how the service will be running. Currently supports `ecs`
and `ecs_scheduled_task`.

* `ecs`: The container will run as a service, be always available and is monitored
* `ecs_scheduled_task`: The task will be started much like a `cron` job is

#### `applicationconfig[n].execution_schedule`

Only used for `ecs_scheduled_task`.

Default value: `cron(0 3 ** ? *)`

See [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html)
for more information on the syntax.

#### `applicationconfig[n].environment`

A list of key-value pairs to add to the environment variables of the running container

```yaml
    environment:
      - name: JAVA_TOOL_OPTIONS
        value: "-Xmx2048m"
```

#### `application[n].monitoring`

```yaml
applicationconfig:
  - name: MyApplication
    monitoring:
      start_filter_string: "string to match in service logs"
      alarm_actions_enabled: "true"
```

##### `application[n].monitoring.start_filter_string`

* Default: `Started Application in`
* Allowed values: Any valid string

##### `application[n].monitoring.alarm_actions_enabled`

Determines whether or not an alarm will trigger its actions.

* Default: `"false"`
* Allowed values: `"false"` `"true"`

#### `application[n].ecs`

##### `application[n].ecs.image`

The image to run in the container. This can be a ECR repository, or a (public) _Docker Hub_
repository.

Private _Docker Hub_ repositories are not supported at the moment.

##### `application[n].ecs.containerport`

The port the service inside the container is listening on. When the task is started, a port
mapping will be created by the ECS Agent (which also runs in a Docker container), and that
port will be registered with the Target Group to which the service is linked, in order for
loadbalancing to do its job.

##### `application[n].ecs.memory`

The number on MB to reserve for the container. If the container requires more memory than
is available (i.e. not reserved) on any of the ECS cluster nodes, the task will not be started.
This will be logged in the service’s events in de AWS Console.

The value is ignored if `application[n].ecs.memory_reservation` is also set.

##### `application[n].ecs.memory_reservation`

Same as `application[n].ecs.memory`, but with the difference that more memory can be used by
the container when memory is available on the ECS instance node. Conversely, when the ECS Agent
looks for memory, it will require the extra memory allocated above the 
`application[n].ecs.memory_reservation` value, to be freed.

This property is _stronger_ than `application[n].ecs.memory`.

##### `application[n].ecs.cpu`

The number of CPU shares to allocate to the running container. Each vCPU on AWS
accounts for 1024 CPU shares. The available number of CPU shares in the cluster is
`1024 * sum_of_vCPUs_of_all_clusternodes`.

For a list of vCPUs per instance type, look [here](http://aws.amazon.com/ec2/instance-types/).

##### `application[n].ecs.desiredcount`

The number of instances to start and maintain for that service.

##### `application[n].ecs.ulimits`

```
  - name: "servicename"
    cfn_name: ServiceName
    target: "ecs"
    ...
    ecs:
      image: "123456789012.dkr.ecr.eu-central-1.amazonaws.com/example/service:latest"
      ...
      ulimits:
        - name: nofile
          hard_limit: 102400
          soft_limit: 102400

```

`ulimits` is a list of _dicts_ with this structure:

* `name`: The name of the `ulimit` property to change. Must be one of:
  * `core`
  * `cpu`
  * `data`
  * `fsize`
  * `locks`
  * `memlock`
  * `msgqueue`
  * `nice`
  * `nofile`
  * `nproc`
  * `rss`
  * `rtprio`
  * `rttime`
  * `sigpending`
  * `stack`
* `hard_limit`
* `soft_limit`

See also [here](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_Ulimit.html).

##### `application[n].ecs.deploymentconfiguration`

Describes how the services will behave when a service is redeployed.

##### `application[n].ecs.deploymentconfiguration.max_percent`

The maximum number of tasks, specified as a percentage of the Amazon ECS service's
_DesiredCount_ value, that can run in a service during a deployment. To calculate
the maximum number of tasks, Amazon ECS uses this formula: the value of
`DesiredCount * (the value of the MaximumPercent/100)`, rounded down to the nearest
integer value.

(From the [AWS Documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ecs-service-deploymentconfiguration.html))

##### `application[n].ecs.deploymentconfiguration.min_healthy_percent`

The minimum number of tasks, specified as a percentage of the Amazon ECS service's
DesiredCount value, that must continue to run and remain healthy during a deployment.
To calculate the minimum number of tasks, Amazon ECS uses this formula: the value of
`DesiredCount * (the value of the MinimumHealthyPercent/100)`, rounded up to the 
nearest integer value.

(From the [AWS Documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ecs-service-deploymentconfiguration.html))

#### `application[n].lb`

**Important**: Changing the LB requires the `AWS::ECS::Service` resource to be
recreated. Since the framework assigns a name to the `AWS::ECS::Service` resource,
this means that the template will fail unless (or):

* the `application[n]` with the changed loadbalancer is first deleted (remove it
  from the configuration file and deploy) and recreated
* **or** the `application[n].name` is changed

##### `application[n].lb.name`

The name of the LoadBalancer behind which the service should be put. External services
should get their traffic from the external load balancer, while internal services should
be put behind an internal load balancer. Internal traffic can be HTTP, while external
traffic should be HTTPS.

##### `application[n].lb.type`

Only used if DNS records have to be made for external services. This only works if the
domain is hosted in _Route 53_, and if the value of the property is `public`.

##### `application[n].lb.healthcheckpath`

The path to check the health of the service.

##### `application[n].lb.healthcheckokcode`

The HTTP code that reflects a healthy services. For example:

* `200`
* `200-299`
* `200-499`
* Values in the `500` range cannot be used


##### `application[n].lb.targetgroup`

##### `application[n].lb.sticky`

##### `application[n].lb.targetgroup_attributes`

```yaml
applicationconfig:
  - name: myapp
    ...
    lb:
      name: mylb
      ...
      targetgroup_attributes:
        - key: deregistration_delay.timeout_seconds
          value: 0
        - key: ...
          value: ...
```

Allowed values are described in the _CloudFormation_ documentation for
`AWS::ElasticLoadBalancingV2::TargetGroup`. The list currently includes
these attributes:

* `deregistration_delay.timeout_seconds`
* `slow_start.duration_seconds`
* `stickiness.enabled`
* `stickiness.type`
* `stickiness.lb_cookie.duration_seconds`

#### `application[n].domains`

A list of domains, used to:

* Create LoadBalancer target group rules (`ALB.,yml`)
* Create private and public Route53 record sets for the service endpoints

An example:

```yaml
application_config:
  - name: myapp
    ...
    domains:
     - name: acme.com
        cfn_name: AcmeCom
        cfn_name_suffix: ep1
        listener_rule_host_header: ep1.acme.com
        priority: 1
     - name: acme.com
        cfn_name: AcmeCom
        cfn_name_suffix: ep2
        listener_rule_host_header: ep2.acme.com
        priority: 2
```

##### `application[n].domains[m].name`

The name of the parent domain in which the service lives.

##### `application[n].domains[m].cfn_name`

This name shoud comply with AWS CloudFormation resource naming convention. The
`cfn_name` of the Route53 hosted zone that corresponds with the domain the service lves in, should match this `cfn_name`.

##### `application[n].domains[m].cfn_name_suffix`

The optional `cfn_name_suffix` in `applicationconfig[n].domains[n]` can be used
if 2 service endpoints within the same parent domain should be directed to this
service's tartget group.

The value of the property will be appended to the _CloudFormation_ resource name
for the Route53 recordset.

The property is optional to guarantee backward compatibility with existing
environments.

##### `application[n].domains[m].listener_rule_host_header`

When an incoming request's host header matches the value of this property (and
the optional `listener_rule_path_pattern`), it will be directed to the 
_Target Group_ for the service.

##### `application[n].domains[m].listener_rule_path_pattern`

Optional path pattern.

##### `application[n].domains[m].priority`

The order of the rule in the _Target Group_ for the service. The lower the order,
the earlier the rule will be checked for incoming traffic.

Assign higher `priority` to more general rules to avoid specific rules never to
be reached.


### `ecr`: _Elastic Container Registry_

See `docs/ECR.md`

### `cloudfront_distributions`

Create _CloudFront_ distributions, including:

* the S3 bucket (default origin) when:
  * `origin.domain` is not defined *or*
  * `origin.domain.type` is `s3`
* _Route53 Record Sets_ for all the distribution's `cname`s if `route53.public_hosted_zoned`
  is defined and it contains an element where the public hosted zone name equals the
  name of the DNS domain of the distribution's `cname`.

**NOTE** - The certificate must be created in the `us-east-1` region.

* `name`
* `cfn_name`
* `cnames`

```yaml
cloudfront_distributions:
  - name: apps
    cfn_name: Apps
    cnames:
      - "apps.acme.com"
    certificate_arn: "arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxxxx"
    minimum_protocol_version: "SSLv3" | "TLSv1" | "TLSv1_2016" | "TLSv1.1_2016" | "TLSv1.2_2018"
    logging:
      prefix: apps
    origins_and_cachebehaviors:
      - origin_name: "apps-{{ application }}-{{ env }}"
        forward_headers:
          - Origin
        path_pattern: "/*"
        allowed_http_methods: options
        lambda_function_associations:
          - event_type: viewer-request
          - lambda_function_arn_export: Cfnname-
        priority: 999
        origin_custom_headers:
          - name: "{{ cloudfront.header_name }}"
            value: "{{ cloudfront.header_value }}"
```

```
cloudfront_distributions:
  - name: redirect-test
    cfn_name: RedirectTest
    cnames:
      - "redirect.acme.com"
    certificate_arn: "arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxx"
    origins_and_cachebehaviors:
      - origin_name: "redirect-test"
        forward_headers:
          - Origin
        priority: 100
        origin_bucket_redirects:
          - routing_rule_condition:
              type: http_error_code_returned_equals
              value: 404
            redirect_rule:
              hostname: www.acme.com
              http_redirect_code: 301
              protocol: https
              replace_key_with: "index.html"
```

#### Working with custom origins

The default behaviour, when no `domain` property is defined, is to use a
S3 bucket as the origin for the distribution.

In that case, the bucket will be implicitely created and be given the name `origin.name`.

When using the `domain` property and `type` `s3`, the bucket is assumed to already exist in
the AWS account where the CloudFormation template is bing deployed.


```yaml
    origins_and_cachebehaviors:
      - ...
      - origin_name: "{{ application }}-{{ env }}-name"
        domain:
          type: import
          name: TheNameACloudformationExport
          origin_path: /mypath
        ...  
```

```yaml
    origins_and_cachebehaviors:
      - ...
      - origin_name: "{{ application }}-{{ env }}-name"
        domain:
          type: s3
          name: my-bucket
          origin_path: /prefix
        ...  
```

```yaml
    origins_and_cachebehaviors:
      - ...
      - origin_name: "{{ application }}-{{ env }}-name"
        domain:
          type: custom
          origin_domain_name: "google.be"
          orinig_path: "/nl"
        ...  
```

##### `origins_and_cachebehaviors[n].origin_name`

The value of this propery is used to:

* Name the origin
* Implicitely create a bucket with the same name (mind the global uniqueness!!)

##### `origins_and_cachebehaviors[n].domain.type`

Can be one of these values:

* `import`: When `type` is `import`, following properties are allowed:
  * `name`: The name of the _CloudFormation_ export to be used for the import
  * `origin_path` (**optional**): If you want _CloudFront_ to request your content from a 
                                  directory in your Amazon S3 bucket or your custom origin,
                                  enter the directory name here, beginning with a `/`.
                                  _CloudFront_ appends the directory name to the value of
                                  `origin_domain_name` when forwarding the request to your origin,
                                  for example, `myawsbucket/production`. Do not include a `/`
                                  at the end of the directory name. 

* `s3`: Use the value of the `name` property as the name of the bucket in the
        same region as the region where the _CloudFormation_
        stack is being deployed. The domain that will be used by the _CloudFront_
        distribution will be
        `{{ origin.domain.name }}.s3-website.{{ target_account.region }}.amazonaws.com`
  * `name`
  * `origin_path` (**optional**): If you want _CloudFront_ to request your content from a 
                                  directory in your Amazon S3 bucket or your custom origin,
                                  enter the directory name here, beginning with a `/`.
                                  _CloudFront_ appends the directory name to the value of
                                  `origin_domain_name` when forwarding the request to your origin,
                                  for example, `myawsbucket/production`. Do not include a `/`
                                  at the end of the directory name.

* `custom`: When `type` is `custom`, following porperties are allowed:
  * `origin_domain_name`: The name of the domain to use as the origin, for example `google.com`.
  * `origin_path` (**optional**): If you want _CloudFront_ to request your content from a 
                                  directory in your Amazon S3 bucket or your custom origin,
                                  enter the directory name here, beginning with a `/`.
                                  _CloudFront_ appends the directory name to the value of
                                  `origin_domain_name` when forwarding the request to your origin,
                                  for example, `myawsbucket/production`. Do not include a `/`
                                  at the end of the directory name. 

#### Custom Error Responses

```yaml
cloudfront_distributions:
  - name: servicedesk
    ...
    custom_error_responses:
      - error_caching_min_ttl: 300
        error_code: 404
        response_code: 200
        response_page_path: /index.html
```

#### Custom Origin Headers

* `header_name`: Name of the header.
* `header_value`: Value of the header.

#### `origin_bucket_redirects`

Add redirect statements to the origin bucket.

Also see the [AWS documentation for routing rules](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-websiteconfiguration-routingrules-redirectrule.html) and the
[AWS documentation for routing rule conditions](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-websiteconfiguration-routingrules-routingrulecondition.html)
for full details on the redirection.


```
cloudfront_distributions:
  - name: redirect-test
    ...
    origins_and_cachebehaviors:
      - origin_name: "redirect-test"
        ...
        origin_bucket_redirects:
          - routing_rule_condition:
              type: http_error_code_returned_equals
              value: 404
            redirect_rule:
              hostname: www.acme.com
              http_redirect_code: 301
              protocol: https
              replace_key_with: "index.html"
```

##### `routing_rule_condition`

##### `redirect_rule`


### `dynamodb`

An example:

```yaml
dynamodb:
  - table_name: journal
    backup: true
    attributes:
      - attribute_name: par
        attribute_type: S
      - attribute_name: num
        attribute_type: N
    key_schema:
      - attribute_name: par
        key_type: HASH
      - attribute_name: num
        key_type: RANGE
    billing_mode: PROVISIONED | PAY_PER_REQUEST
    provisioned_throughput:
      read_capacity_units: 5
      write_capacity_units: 5
```

#### `backup`

This setting enables or disables the PITR for the table.

Allowed values:

* `true`
* `false` (default)

#### `billing_mode` and `provisioned_throughput`

`billing_mode` can have 2 values:

* `PROVISIONED` (default)
* `PAY_PER_REQUEST`

`provisioned_throughput` is ignored if `billing_mode` is `PAY_PER_REQUEST`.

See the [AWS documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-dynamodb-table.html#cfn-dynamodb-table-billingmode) for more details.

### `sns`

**IMPORTANT**: all aubscription names should be unique across all SNS topics. Using the same
name twice will result in the creation of the last occurrence only!!!

```
sns:
  - display_name: mytopic
    topic_name: mytopic
    subscriptions:
      - name: subscr01
        endpoint_export: mysubscriptionexport
        subscription_protocol: lambda
```

This creates:

* an SNS topic
* subscriptions for the topic (**optional**)
* permissions to invoke a lambda function if the subscription protocol
  is `lambda`

#### `display_name`

#### `topic_name`

#### `subscriptions`

##### `subscriptions[n].name`

##### `subscriptions[n].endpoint_export`

The name of a _CloudFormation_ export that contains the ARN to the resource
that subscribes to the topic.

##### `subscriptions[n].endpoint_arn`

The ARN to the resource that subscribes to the topic.

##### `subscriptions[n].protocol`

### The `ecsmgmt` FARGATE ECS cluster

The documentation for this module has been moved to `docs/ECSMgmt.md`.

### Route53 Delegation

**Important**: This setup should be done only on the account where the
               _hosted zones_ are defined.

#### How it works

```
+------------------------------------------------------+    +----------------------------+
|         Route 53                      Tooling Account|    |        Application Account |
| +--------------------+                               |    |                            |
| |                    |                               |    |+--------------------------+|
| |                    |                               |    ||  CloudFormation Template ||
| |                    |    Lambda f()     SNS Queue   |    ||                          ||
| |                    |   +----------+    +---------+ |    || +----------------------+ ||
| | +----------------+ |   |          |    |    |    | |    || |                      | ||
| | | R53 Record Set <-+---+          <----+    |    <-+----+--+Custom::CNAME Resource| ||
| | +----------------+ |   |          |    |    |    | |    || |                      | ||
| |                    |   +----------+    +---------+ |    || +----------------------+ ||
| +--------------------+                               |    |+--------------------------+|
+------------------------------------------------------+    +----------------------------+
```


#### Setup the account that _hosts_ the Hosted Zone

The Hosted Zone itself should already already be created in the target account
(usually the _tooling_ account for the organization)

This allows the AWS accounts which have been granted access to this functionality to
remotely add records to a hosted zone by using a custom _CloudFormation_ resource.

#### The configuration file

This config file creates the above resources.

An example:

```
route53_delegation:
  hostedzone:
    - domain: "acme.com"
    - id: "XXXXXXXXXXX"
    - account_id: "123456789012"
  allowed_accounts:
    - name: account description
      account_id: 234567890123
    - name: account description
      account_id: 345678901234
    - name: account description
      account_id: 456789012345
    - name: account description
      account_id: 567890123456
```

* `hostedzone.domain`: The domain name of the hosted zone
* `hostedzone.id`: The Route53 ID of the hosted zone
* `hostedzone.account_id`: The AWS account-id that _owns_ the hosted zone
* `allowed_accounts`: The list of AWS account IDs that are allowed to remotely
  manage _Route 53_ record sets for the Hosted Zone using the CLI or CloudFormation

This will create the following resources on the account that hosts the _Hosted Zone_:

* An S3 bucket that holds the lambda function
* A Lambda function from a file on the S3 bucket
* The SNS topic that will trigger the Lambda function. This SNS topic is also required
  when using the custom CloudFormation resource to manage the Route53 Record Sets.
* An SNS Topic Policy
* A service policy for Lambda to allow the Route53 actions
* A role for CLI access

## Common or not so common actions

### Configure the DataDogHQ log shipper

The full configuration of the DD log shipper takes 3 steps:

* Configure the DD Log Shipper Lambda
* Configure the Lambda function that automatically onboards new
  _CloudWatch_ log groups and adds a subscription filter to those
  log groups
  
#### Configure the DD logshipper Lambda

```yaml
lambda_functions:
  - name: aws-lambda-datadog-logshipper
    handler: lambda_handler
    runtime: python2.7
    code:
      s3_bucket: "{{ lambda_function_bucket_name }}"
      s3_key: aws-lambda-datadog-logshipper-4c4579dfe5ab32ca8c5b9ecd8eb06b1281e5a5b7.zip
    environment:
      - name: APPLICATION
        value: "{{ application }}"
      - name: ENVIRONMENT
        value: "{{ env }}"
      - name: DD_API_KEY
        value: xxxxxxxxxxxxxxxxxxxxxxxxxx
    invoke_permissions:
      - type: predefined
        description: "Allows CloudWatch log events to trigger this lambda function"
        name: logs
```

* `s3_key`: The name of the Lambda ZIP file on the S3 bucket, only requires change
  if the function is changed.
* The `APPLICATION` and `ENVIRONMENT` environment variables are used to add metadata
  to the logged entries to allow for better filtering.
* The `DD_API_KEY` determines to which DD account the log are sent

#### Configure the log group onboarding function

```yaml
cw:
  auto_config_log_group_lambda_s3_key: "cw-logs-new-stream-to-lambda-5de112e77e72fe069784d795412880499551fe5b.zip"
  log_group_settings:
    retention_in_days: 14
    filter_pattern: "-DEBUG"
  logshipper_lambda_function_arn_import: "AppEnvLambda-AwsLambdaDatadogLogshipperArn"
```

* `retention_in_days`: How long are log streams kept in CW logs
* `filter_pattern`: Determines the filter to be applied to incoming messages. See [here](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html) for the syntax.
* `logshipper_lambda_function_arn_import`: The Lambda to send the logs to. If the destination is _DataDogHQ_
  see the section above, but you can provide your own function, export its ARN and use it instead.

### Disable _ServiceStartAlert_

### Remove a service

#### Description

Because of the potential dependency between the ALB's _TargetGroup_ and the service,
removing a service is not as straightforward as it should be.

* _TargetGroup_ for a service is created during the _ALB_ setup
* The _TargetGroup_ is referred to by the service's _Service_ definition
  during the _ECS_ setup
* _ECS_ is always run **after** _ALB_
* Removing a service from the config file causes the _ALB_ template to try to
  delete the _TargetGroup_, but that action fails because it is still used in the
  _Service_ definition.
  
Ideally, the _TargetGroup_ should be created in the _ECS_ template, but that is a breaking
change, requiring a fresh roll-out of the environments.

#### Procedure to follow for services behind a ALB TargetGroup

* Edit the configuration file and remove the service from the configuration file
* Generate the _CloudFormation_ templates, but without applying them. This can be done in 2 ways:
  * When using `dockerwrapper`, export these environment variables before starting the
    `dockerwrapper` script:
    * `ANSIBLE_SKIPTAGS=deploy`
    * `ANSIBLE_TAGS=ecs,alb,route53`
  * When using the `ansible-playbook` command, add `--tags=alb,ecs,route53 --skip-tags=deploy`
    to the commandline
* Now, got to the AWS console and update the `ECS` stack with the template you created in the
  previous step. This will remove the service and the dependency with the _TargetGroup_
* Next, update the loadbalancer template(s), this step will remove (among others)
  the _TargetGroup_

## Links

* [https://github.com/rik2803/aws-create-deleted-tagged-cfn-stacks]()
* [https://github.com/rik2803/aws-delete-tagged-cfn-stacks]()
