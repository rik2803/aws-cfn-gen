# Release notes

[toc]

## Release Remarks
* `M.m.p`
* `m` release: Carefully read the release notes, changes might cause
  interruptions in the service.
* `p` release: Bugfixes, introduction of new features that can normally
  be used without any interruption or rebuild of resources.

## `0.6.46` (20241016): Add object_ownership to S3 bucket options

Setting the option `object_ownership` will set the bucket ACLs on (or off)

Possible values are:

* `ObjectWriter` Enables ACLs and puts owner of new objects to the writer
* `BucketOwnerPreferred` Enabled ACLs and puts owner of new object preferably to the owner, unless ACLs change this
* `BucketOwnerEnforced` Disables ACLs and enforces bucket owner as owner of all files

```yaml
s3:
  - name: mybucket
    cfn_name: MyBucket
    access_control: Private
    object_ownership: ObjectWriter
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
    tags:
      - key: "ass:s3:backup-and-empty-bucket-on-stop"
        value: "yes"
      - key: "ass:s3:backup-and-enpty-bucket-on-stop-acl"
        value: "private"
      - key: "..."
        value: "..."  
```

## `0.6.37` (20230120): Grant `ecr:DescribeImages` permissions to accounts with pull permissions for an ECR repo

## `0.6.36` (20230110): Introduce skip_user_creation property

Setting the property `skip_user_creation: true` will skip the creation of functional
AWS users in:

* `ECSMgmt`
* `ECR`
* `Cloudfront`

To enable this:

* Add `skip_user_creation: true` in the configuration YAML file
* Update the `GITTAG` default value in `dockerwrapper`
* Run the command `ANSIBLE_TAGS=ecs,cloudfront.ecsmgmt ./dockerwrapper`

Add one or both properties to the account's config file to skip the creation
of the related resource:
## `0.6.25` (20220103): Provide a way to not create NatGW/IGW

Add one or both properties to the account's config file to skip the creation
of the related resource:

```yaml
vpc:
  skip_natgw: true
  skip_igw: true
```

## `0.6.24` (202111)

Fix condition in logic to skip deploy user creation (again)

## `0.6.23` (20211207): Apply lifecycle rule to CloudFront log buckets

* Default: remove after 14 days
* Set `logging.expiration_in_days` property in the cloudfront definition to override that setting

## `0.6.22` (20211201): ECR policy support for cross-account Lambda pulls

The `cross_account_access.lambda` property in the ECR repo definition will add a statement
to the ECR policy that allows all Lambda's in the specified AWS accounts to pull the
ECR image. Also see [this AWS blog post](https://aws.amazon.com/blogs/compute/introducing-cross-account-amazon-ecr-access-for-aws-lambda/).

```yaml
ecr:
  - name: "repoName"
    cfn_name: RepoName
    cross_account_access:
      push:
        - 000000000000
      pull:
        - 111111111111
        - 222222222222
      lambda:
        - 333333333333
```

## `0.6.21` (20211128): ECS Autoscaling based on Custom CW Metric

```yaml
applicationconfig:
  - name: "myservice"
    ...
    ecs:
      ...
      autoscaling:
        - name: MyMetric
          type: custom
          scale_in_cooldown: 60
          scale_out_cooldown: 60
          target_value: 75
          custom_metric:
            dimensions:
              - dim1
              - dim2
            metric_name: MyMetric
            namespace: MyNameSpace
            statistic: Sum
```

## `0.6.20` (20211116)

Fix condition in logic to skip deploy user creation

## `0.6.19` (20211026)

Fix autoscaling mincapacity

## `0.6.18` (20211008)

Allow to skip deploy user creation based on a cloudfront or a global property.

## `0.6.17` (20210813)

### EFS: Create a SSM parameter for each S3 to EFS deploy bucket

## `0.6.16` (20210715)

### LambdaCloudfront: use AWS::Serverless::Function to created versioned functions in us-east-1

## `0.6.15` (20210715)

### CloudFront: Re-use a s3 origin for multiple distributions

### ECS: Add property `execution_schedule_state` to allow ECS scheduled task rule to be disabled

## `0.6.14` (20210617)

### ECS2: Fix indentation error

Adding ACM certificates to a ALB in ECS2 failed because of an indentation error. This
version fixes that error.

### BastionHost: Update AMI

The AMI used for the bastion host is updated to the latest version.

## `0.6.13` (20210604)

### EFS: S3 to EFS copy

* Transfer files to an EFS volume more easily **without** having to log in to the bastion account.
* Uploading the files to the S3 bucket will automatically transfer the files to the s3 bucket.

```yaml
efs:
  - cfn_name: MyS3ToEFSCopy
    s3_to_efs_copy:
      lambda_key: aws-lambda-s3-trigger-to-efs-c78524de709fb97bce19e0e5b4bda04329a0f082.zip
```

## `0.6.12` (20210415)

### ECS and ECS2: Support for autoscaling

* Only if `app.launchtype == "FARGATE"`

```yaml
applicationconfig:
  - name: "myservice"
    ...
    ecs:
      ...
      autoscaling:
        - name: cpu
          scale_in_cooldown: 60
          scale_out_cooldown: 60
          target_value: 75
          predefined_metric_type: "ECSServiceAverageCPUUtilization"
        - name: memory
          scale_in_cooldown: 60
          scale_out_cooldown: 60
          target_value: 75
          predefined_metric_type: "ECSServiceAverageMemoryUtilization"
```

## `0.6.11` (20210308)

### ECS2

* Fix: The Lambda LambdaCumulativeReservationMetric was not updated in ECS2

## `0.6.10` (20210308)

### ECSMgmt

* Feature: exclude ADAG alarms with `ecsmgmt.monitoring.adag_alarm_exclude_list` property

## `0.6.9` (20210303)

* Add (optional) creation of EFS access points.
* Add tags to AWS::ECS::Service resources

## `0.6.8` (20210129)

* Update Bastion AMIs in the _BastionHost_ module
* Update S3 key for a lambda function in the _ECS_ module

## `0.6.7` (20210107)

Fix name of IAM role that should have been correct in `v0.6.6`

## `0.6.6` (20210102) (OBSOLETE - Do not use)

Implicitly create the role `ECSExecutionRoleAwsCfnGen` and use it as the
`ExecutionRoleArn` in the task definitions if no `execution_role_arn` is defined
in the service configuration.

## `0.6.5` (20201229)

Allow multiple certificates on 1 ALB HTTPS listener (fixes #53)

## `0.6.3` (20201210) and `0.6.4` (20201212)

AWS decided to stop support for their case error in `FileSystemId`, so we are
forced to follow and change to `FilesystemId`.

The old case string will result in stacks failing as from March 1, 2021, as stated in
CloudFormation event logs:

```
Stack operations on resource TaskDistribution would fail starting from
03/01/2021 as the template has invalid properties. Please refer to the
resource documentation to fix the template. Properties validation failed
for resource TaskDistribution with message:
#/Volumes/0/EFSVolumeConfiguration:required key [FilesystemId] not found
```

## `0.6.2` (20201201)

You can now skip linter checks using the Ansible `--skip-tags` option.

Available tags:

* `linter` or `cfn-lint` to skip all lint checks
* Resource specific tags in the form `lint-<resource>`:
  * `linter-vpc`
  * `linter-vpcendpoints`
  * `linter-sgrules`
  * `linter-kms`
  * `linter-secretemanager`
  * `linter-rdsparametergroups`
  * `linter-rds`
  * `linter-chatnotifications`
  * `linter-bastion`
  * `linter-ecr`
  * `linter-ecsmgmt`
  * `linter-route53delegation`
  * `linter-iam`
  * `linter-lambda`
  * `linter-lambdacloudfront`
  * `linter-cloudwatch`
  * `linter-efs`
  * `linter-dynamodb`
  * `linter-loadbalancers`
  * `linter-sns`
  * `linter-s3`
  * `linter-cloudfront`
  * `linter-route53`
  * `linter-ecs`
  * `linter-ecs2`
  * `linter-wafassociations`


## `0.6.1` (20201130)

* Update Policy version from `2008-10-17` to `2012-10-17` to satisfy linter check

## `0.6.0` (20201124)

### Warning

Upgrading to this version will possibly cause downtime because new AMI's will be used

### Changes
 
* Default TLS policies for ALB and CloudFront are updated to `ELBSecurityPolicy-FS-1-2-Res-2019-08`
  and `TLSv1.2_2019` respectively
* AMI's for Bastion and ECS cluster are updated
* Only Amazon2 linux AMI's are allowed for EC2 based ECS clusters and Bastion hosts

## `0.5.12` (20201118)

Bugfixes in CloudFormation lint checker

## `0.5.11` (20201118)

Bugfixes in CloudFormation lint checker

## `0.5.10` (20201117)

Add `cfn-lint` check after template generation, but before template deploy

## `0.5.8` (20201105)

Fix indentation bug in `ECSMgmt.yml`

## `0.5.7` (20201014)

Fix issue where ECS EC2 instances are added to the cluster even when all
services are configured as `FARGATE` service.

## `0.5.6`

* Block all public access on bucket where template is uploaded
* Remove start/stop metric filter and cw alarm from ecs service cloudwatch loggroups
* Allow cross account ECR push for selected accounts


## `0.5.5` (20200926)

A new module SGRules to add ingress rule to existing security groups.

```yaml
sgrules:
  - cfn_name: AddTcp8080ToSGInternal
    type: "ingress"
    sg_id: "sg_123456789"
    source_sg_id: "sg_123456789"
    description: "Allow intra SG traffic to port 8080"
    protocol: "tcp"
    from_port: "8080"
    to_port: "8080"
```

## `0.5.3` (20200924)

Re-assign required AmazonEC2ContainerRegistryFullAccess to ecr-push user

## `0.5.2` (20200924)

ECS2: Remove obsolete outputs

## `0.5.1` (20200923)

Bugfix in multiline yaml string in ECS2

## `0.5.0` (20200922)

### `ECS2`

A new template that combines ALB and ECS to avoid circular dependencies and
problems when changing or removing services.

Uses `ecs2` and `loadbalancer2` top-level properties in the config files. When using `ecs2`, service
names are not defined in the cloudformation template and will vary. Keep this into account when
changing from `ecs` to `ecs2` as this will require ci/cd pipelines to be updated as well.

### Bastion

* `bastion.eip` creates an EIP and attaches it to the bastion host
* `bastion.encrypt_ebs` will encrypt the bastion storage

### `IAM`

* Set the top-level property `iam_accesskey_serial` to re-create access keys in
  following templates:
  * `CloudFront`
  * `ECR`
  * `ECSMgmt`
  * `IAM`
* Stop using inline policies in favor of group, policies and group membership in
  following templates:
  * `CloudFront`
  * `ECR`
  
### `S3`

* `bucket.public_access_block_configuration` can be used to block public bucket access:

```yaml
s3:
  - name: myBucket
    ...
    bucket.public_access_block_configuration: true
``` 

```yaml
s3:
  - name: myBucket
    ...
    bucket.public_access_block_configuration:
      block_public_acls: true
      block_public_policy: true
      ignore_public_acls: true
      restrict_public_buckets: true
```

* `bucket.send_create_events_to_lambda_import` can be used to run a Lambda on
  `s3:ObjectCreated:*` bucket events../
### `ALB`

* Force TLS on internal LBs with `force_tls`

```yaml
loadbalancers:
  - name ALBInt
    ...
    force_tls: true
```

* Allow fixed responses in ALB listener rules

```yaml
loadbalancers:
  - name: myAlb
    ...
    fixed_responses:
      - cfn_name: "FixedResponse001"
        path_pattern: "/path"
        priority: 5
        status_code: "404"
        content_type: "text/html"
        message_body: "<h1>404 - page not found</h1>"
```

* End to End TLS when `applicationconfig[n].lb.protocol` is `HTTPS`
* Make all health check settings configurable

### `Cloudfront`

* S3 origins with OAI and bucket policy for cloudfront access

```yaml
cloudfront_oai:
  - myOai

cloudfront_distributions:
  - name: c19distributionmyDistribution
    ...
    origins_and_cachebehaviors:
      - origin_name: myOrigin
        ...
        oai: "myOai"
```

### `WAF`

Add `waf_associations` to associate an existing (manually created) web acl to a
loadbalancer.

```yaml
waf_associations:
  # The WebACL needs to be created manually for now. Only the association of the WebACL with the external
  # LoadBalancer is automatic.
  - name: WafToAlbExt
    waf_arn: "arn:aws:wafv2:{{ target_account.region }}:{{ target_account.account_id }}:regional/webacl/{{ target_account.waf_alb.name }}/{{ target_account.waf_alb.id }}"
    arn_import: "{{ app_cfn }}{{ env_cfn }}ECS2-ALBExt"
```

### `ECS`

* `ecs.cluster.encrypt_ebs` will encrypt the ECS cluster instance storage
* `applicationconfig[n].launchtype` can be set to `FARGATE` to run the service on a _FARGATE_
  cluster. If all services are `FARGATE` services, no cluster instances will be created.
 
### `VPC`

* Add VPC interface endpoint support

```yaml
vpc_interface_endpoints:
  - cfn_name: "SSM"
    aws_service: "com.amazonaws.eu-central-1.ssm"
    subnet_imports:
      - "VPCFor{{ app_and_env_cfn }}-PrivateSubnetAZ1"
      - "VPCFor{{ app_and_env_cfn }}-PrivateSubnetAZ2"
      - "VPCFor{{ app_and_env_cfn }}-PrivateSubnetAZ3"
    sg_imports:
      - "VPCFor{{ app_and_env_cfn }}-SGAPP"
    vpc_import: "VPCFor{{ app_and_env_cfn }}-VPC"
  - cfn_name: "SecretsManager"
    aws_service: "com.amazonaws.eu-central-1.secretsmanager"
    subnet_imports:
      - "VPCFor{{ app_and_env_cfn }}-PrivateSubnetAZ1"
      - "VPCFor{{ app_and_env_cfn }}-PrivateSubnetAZ2"
      - "VPCFor{{ app_and_env_cfn }}-PrivateSubnetAZ3"
    sg_imports:
      - "VPCFor{{ app_and_env_cfn }}-SGAPP"
    vpc_import: "VPCFor{{ app_and_env_cfn }}-VPC"
```

### `ECR`

* Add task definition and ECS service permissions to `ecr-push` user

### `ecsmgmt`

* `ecsmgmt.ass.disable` skips the creation of `ASS` resources.

### `chat_notifications`

* Add template to add resources that subscribe to the monitoring SNS topic to
  send notifications. Works for Slack and Google chat.

```yaml
chat_notifications:
  - host: "hooks.slack.com"
    path: "{{ target_account.slack_notifications_path }}"
    cfn_name: "Slack{{ app_and_env_cfn }}"
```

## `0.4.1` (20200708)

### Features

#### `S3` CORS

Optionally set CORS rules on the bucket.

#### `ECS` AMI override

Use `amzami` or `amz2ami` to override the default AMI:

* Use the ECS AMI
* Use the AMI for the region you are deploying in

## `0.4.0` (20200604)

### Features

#### `ECS` Update AMIs to latest version

Update the ECS AMI's to the latest version.

**Downtime Warning**: Using this version for the first time will cause the ECS
cluster to be rebuild because of the new AMI's.

## `0.3.6` (20200311)

### Improvements

* Add `ssl_policy` property to loadbalancer to determine the SSL policy to
  use on the HTTPS listener.

## `0.3.5` (20191120)

### Improvements

* `ECSMgmt`: make memory and cpu for fargate tasks configurable
 
## `0.3.4` (20191006)

### Features

* The _S3_ module now exports outputs for the created resources,
 
## `0.3.3` (20191002)

### Fixes

* Quote principals in KMS IAM to avoid failure when account-id starts with zero

### Improvements

* Set deletion tag on cloudfront resources, default is 0 (no deletion), change
  to non-zero in environment config to instruct ASS to delete the CloudFront stack

## `0.3.2` (20190912)

### Fixes

* Fix failure when cw property is not defined

## `0.3.1` (20190907)

### Features

* Add `aws-cfn-gen` version to the CloudFormation stack description

### Fixes

#### _Lambda_

* Add Golang
* Source account not allowed in invoke permission for CW Event rule
* Environment variable values can be an exported CloudFormation output

```
lambda_functions:
  - name: mylambdafunction
    function_name: MyLambdaFunction
    ...
    environment:
      - name: ENVVAR_FROM_IMPORT
        value_from_import: "NameOfTheImport"
```

#### _CloudWatch_

* Allow Event Rule creation with free event pattern
* Add some extra checks on property existence and validity
* The CloudWatch stack is unconditionally created because it
  contains resources other stacks depend on

## `0.3.0` (20190901)

This is a minor release, updating to this release might cause service
interruptions because of the support for AMZN2 images in the ECS module.

### Features

* `ECS`: ECS AMZN2 support, set `ecs.cluster.amzn2` to `true` to enable
* `CloudFront`: Add property `cloudfront.default_root_object`
* `ECSMgmt`: Add custom scheduled tasks to the management ECS cluster

## `0.2.4` (20190731)

### Features

* RDS Cluster Parameter Group creation
* Allow cross account ECR repository pulls for selected AWS
  accounts
* RDS Instance module

## `0.2.3` (20190617)

### Features

#### `ecs`

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

Setting the property `targetgroup_attributes` will add the target group attributes to
the target group for the application. Consult the AWS CloudFormation documentation for
`AWS:ElasticLoadBalancerV2::TargetGroup` for accepted values.

## `0.2.2` (20190617)

### Features

#### General Feature

Run without updating resources, only creating change sets and printing a basic report at the end of the playbook run.
This can be achieved by adding the commandline switch `--extra-vars create_changeset=yes` to the `ansible-playbook`
commandline.

#### CloudFront

##### Extent customizable properties

* Allow definition of CORS rules for S3 origins (see example)
* Make `ViewerProtocolPolicy` customizable with property `viewer_protocol_policy`
* Make `MaxTTL`, `MinTTL` and `DefaultTTL` customixable with the properties
  `max_ttl`, `min_ttl` and `default_ttl`.


```yaml
cloudfront_distributions:
  - name: my-distributions
    cfn_name: MyDistribution
    cnames:
      - "dist.acme.com"
    certificate_arn: "arn:aws:acm:us-east-1:{{ target_account.account_id }}:certificate/{{ certificate }}"
    logging: true
    origins_and_cachebehaviors:
      - origin_name: "origin-1"
        origin_cors_rules:
          allowed_headers: [ 'access-token', 'content-type', 'cache-control', 'pragma' ]
          allowed_methods: [ 'PUT', 'GET', 'POST', 'DELETE' ]
          allowed_origins: [ '*' ]
          max_age: 300
        forward_headers:
          - Origin
        priority: 100
        path_pattern: "/static/*"
        allowed_http_methods: options
        viewer_protocol_policy: "allow-all"
        default_ttl: 300
```

#### ECS

##### Allow `MemoryReservation` in `ContainerDefinition`

It is now possible to set the `memory_reservation` property in the `ecs` part of
an application definition. This will allow the running container to exceed the
memory limit set by the property, but only when the ECS cluster node has
memory to spare. When another container requires memory within its memory
settings, the ECS Agent will try to reclaim the memory from containers that
exceed their `MemoryReservation` first.

This property is stronger than the `memory` property.

```yaml
  - name: "servicename"
    cfn_name: ServiceName
    target: "ecs"
    ...
    ecs:
      image: "123456789012.dkr.ecr.eu-central-1.amazonaws.com/example/service:latest"
      containerport: 8080
      memory_reservation: 2048
      cpu: 512
      desiredcount: 2
    ...
```

## `0.2.1` (20190606)

This is a patch release, with only minor and non-disrupitve changes.

### Bugfixes

#### ECS

Fix case where ECS template fails when no `bastion` data is present in the
project configuration file. An extra test was added to skip the part where
the variable was referenced.

## `0.2.0` (20190308)

This is a minor release, updating to this release might cause service
interruptions because of:

* a change in the ECS _Launchconfiguration_ (install SSM Agent on ECS instances)

### Features

#### ECS

* Update AMI to version
* Add installation of SSM Agent to the ECS LaunchConfiguration. This is required
  to allow for the automatic installation of the Amazon CloudWatch Agent on ECS
  AMI based instances
  
#### `sns`

* Add SNS topic subscription filter support
* Introduce possibility to specify a endpoint arn for sns topic subscriptions
* Add cross account topic policies

#### ECSMgmt

* Add scheduled tasks from config for existing task definitions

#### Lambda

* Add Lambda invoke permissions and subscriptions for other AWS accounts

### Improvements

#### General

* Add `stack_deletion_order` logic for `vpc` and `vpcendpoints`
* Prerequisites for CloudWatch Agent installation on ECS instances and bastion hosts

#### CW

* Reduce nr of metrics in CloudWatch Agent config file

#### ECSMgmt

* New version of start/stop resources, will exist together with the old version (for now).

#### `s3`

Enable versioning by default.

#### Lambda

* Possibility to customize timeout and memory configuration
* Add service based lambda permissions by defining invoke
  permissions as shown below.

```
lambda:
- name: MyLambda
invoke_permissions:
- type: "service"
principal: "apigateway.amazonaws.com"
source_arn: "arn:aws:execute-api:eu-central-1:123456789012:dj48dhw934g/*/*/fanout-setup"
name: "fanout_setup"
```

#### Bastion

* Upgrade to latest AMZ2 image

### Bugfixes

#### `route53delegation`

* Fix typo in the Lambda function key

#### Lambda

* Fix confusing lambda permission naming

#### ECS

* Use variable for `dm.basesize` instead of fixed 20G

## `0.1.9` (20190213)

### Features

#### `ecs.task_change_state_rule`

Use `ecs.task_change_state_rule` to enable or disable ECS Service State
Change alerts. Allowed values are `ENABLED` and `DISABLED` (default).

Use `applicationconfig[n].monitoring.alarm_actions_enabled` to control
alarm action execution. Allowed values are `true` and `false` (default).

#### `cloudfront`: Creation of _Route53_ record sets for cnames

Create _Route53 Record Sets_ for all the distribution's `cname`s if
`route53.public_hosted_zoned` is defined and it contains an element
where the public hosted zone name equals the name of the DNS domain
of the distribution's `cname`.
 
#### `cw`: Define _CloudWatch_ scheduled events

An example:

```yaml
cw:
  scheduled_rules:
    - name: MyDaily6AMSchedule
      description: "Trigger daily at 6 AM"
      schedule_expression: "cron(0 6 * * ? *)"
      targets:
        - type: import
          value: MyCloudformationTemplate-MyLambdaFunction
```

## `0.1.8` (20180201)

### Features

#### `ecs`: Allow multiple endpoints in `domain` within the same parent domain

The optional `cfn_name_suffix` in `applicationconfig[n].domains[n]` can be used
if 2 service endpoints within the same parent domain should be directed to this
service's target group.

The value of the property will be appended to the _CloudFormation_ resource name
for the Route53 recordset.

The property is optional to guarantee backward compatibility with existing
environments.

For example:

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

#### `lambda`: Specify fixed name for the Lambda function

Possibility to assign fixed name to Lambda function, if the property
`lambda[n].function_name` is present. Changing this name will cause the
resource to be re-created (and the old resource to be removed). This is
at risk of the user.

#### `cw`: CloudWatch configuration

This new _module_ creates roles, poliicies and Lambda's in the _CloudWatch_
biotope. This first version provides all elements to automatically onboard
newly create CW log groups in the chosen log subscription setup, for example
to integrate with a log forwarder (DataDogHQ, ...)

Checkout the `README.md` for moe information.

### Fixes

#### `sns`: `subscriptions` property is optional, set default value if absent

#### `alb`

Separate CW log group creation from CW log group subscription for loadbalancer access
logs. Before this change, all configuration was done in `cw_logs_subscription_filter`,
this has been changed to:

* `cw_logs` for the log group creation
* `cw_logs_subscription_filter` for the subscription related configuration.


## `0.1.7` (20180121)

### Features

#### `bastionhost`: Create Bastion Host

#### `stack_deletion_order`: Secure `prd` environments

Set `stack_deletion_oder` to `0` if `env == 'prd'`

## `0.1.6` (20180115)

### Features

#### `route53`

Do not create _RecordSet_ when domain is same as _Route53_
hosted zone name. This would otherwise fail, because it
should be a APEX RecordSet.

#### `alb`

Add redirect rule as default action for HTTP listener for external loadbalancers.

## `0.1.5` (20180102)

### Features

#### `route53`

* Add test on domain match when creating Route53 RecordSets in private hosted zones
* Introduce `skiproute53public` and `skiproute53private`


#### `Route53Delegation`

This functionality was moved from `aws-route53` to `aws-cfn-gen`.

See the README file for more details.

#### The `ecsmgmt` ECS cluster

When the property `ecsmgmt` is set, these resources will be created:

* a ECS FARGATE cluster. This cluster is not backed by EC2 instances and
  does not add to your AWS bill unless a FARGATE service is run
* an execution role
* a task role
* 2 task definitions
  * `tryxcom/aws-delete-tagged-cfn-stacks:latest`
  * `tryxcom/aws-create-deleted-tagged-cfn-stacks:latest`

See these github repositories for more information on what these
images do:

* https://github.com/rik2803/aws-create-deleted-tagged-cfn-stacks
* https://github.com/rik2803/aws-delete-tagged-cfn-stacks

#### `loadbalancers`: Define a S3 trigger on the access log bucket

When `access_logs` is defined and `state` is `enabled`,
following resources are created:

* A S3 bucket named `{{application }}-{{ env }}-accesslogs-{{ lbname }}`
* An lifecycle rule that expires the access logs after `log_expiry_days` days
* A bucket policy that allows the AWS ALB account in the current region to
  write to that bucket
* A `s3.ObjectCreated` trigger to a lambda function if
  `accesslogs.s3_objectcreated_lambda_import` is defined. That *Lambda* function can, for example,
  be used to ship the S3 logs to *CloudWatch*.

#### `loadbalancers`: redirect rule

This functionality was finally available in _CloudFormation_ and now
allows the create a redirection rule in the loadbalancer configuration.

#### `sns`: Introduction of the `SNS` definition

```
sns:
  - display_name: mytopic
    topic_name: mytopic
    subscriptions:
      - name: subscr01
        endpoint_export: mysubscriptionexport
        subscription_protocol: lambda
```

See the README file for more details.


#### `vpc`: Introduction of the `VPC` definition

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

See README.md for more details.

#### `S3` and versioning

Enable (`Enabled`) or disable (`Suspended`) bucket versioning.

```yaml
s3:
  - name: mybucket
    ...
    versioning: Enabled
```

#### `cloudfront_distribution` and origin `S3` website bucket redirects

```
cloudfront_distributions:
  - name: redirect-test
    cfn_name: RedirectTest
    cnames:
      - "redirect.acme.com"
    certificate_arn: "arn:aws:acm:us-east-1:{{ target_account.account_id }}:certificate/xxxxxxxx"
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

#### `cloudfront_distribution` and `origin_path`

Add the `origin_path` property to the origin configuration.

This is path that CloudFront uses to request content from an S3 bucket or custom origin. The combination of the DomainName and OriginPath properties must resolve to a valid path. The value must start with a slash mark (/) and cannot end with a slash mark.

See
[here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cloudfront-distribution-origin.html#cfn-cloudfront-distribution-origin-originpath)
for more information.

#### `cloudfront_distribution` and `LambdaCloudfront` and associated functions

Allow Lambda functions to be associated with a cloudfront distribution. This requires
Lambda functions to be deployed to `us-east-1`.

#### `DynamoDB` backup

```yaml
dynamodb:
  - table_name: mytable
    backup: true
    ...
```

#### `DynamoDB` billing mode

```
dynamodb:
  - table_name: mytable
    ...
    billing_mode: PROVISIONED | PAY_PER_REQUEST
    provisioned_throughput:
      read_capacity_units: 5
      write_capacity_units: 5

```

#### 'lambda': Add `vpc` property to configure Lambda inside a VPC

```
lambda_functions:
  - name: aws-lambda-s3-logs-to-cloudwatch
    vpc: true
```

The function will be in the (private) application subnets defined by `vpc_privatesubnet_az*` and
the associated _Security Group_ will be `vpc_sg_app`.

### Improvements

#### `lambda`: Allow the creation of multiple Lambda functions from the same code

Sometimes, the same function needs to be used more than once, for example if there are different
triggers or a different set onf environment variables that influence the execution and the result
of the function.

To achieve this, create identical blocks (with different envvars or whatever changes), and the
`name` should have a suffix that starts with un underscore.

If the name contains an underscore, the part before the underscore is used to determine
the function name, and the complete string is used, after some _CFN_ related transformation,
as the _CloudFormation_ resource name.

#### Specify managed policies for `IAM` users with full _arn_ or with policy name only

Before `0.1.5`, managed policies for `iam_users` were interpreted as a policy name and
extended to `arn:aws:iam::123456789012:policy/<name>`. From version `0.1.5`, the full
`arn` can also be specified.

#### `ECS`: Use `ecsEventsRole` as default role for scheduled tasks

Use `role/ecsEventsRole` if `task_role_arn` is not specified for a `ecs_scheduled_task`.

### Bugfixes

#### `s3` bucket policies

Do not create a bucket policy if no policy doment is defined in the project configuration.


## `0.1.4` (20181017)

**Downtime Warning**: Using this version for the first time will cause the ECS
cluster (if any) to be rebuild.

### Features

#### `ecs` EBS and container volume settings

* Setting the property `ecs.cluster.dm_basesize` configures the _Docker_
  devicemapper storage to assign that amount of thin-provisioned storage
  to every container on the ECS instance. Specify the unit (i.e. `G`)
* Setting the property `ecs.cluster.ebs_size` changes the size of the
  volume attached to the ECS instance for the _DeviceMapper_ LVOL. Use
  numbers only, the unit is `GB`.
  
**Downtime Warning**: Changing these settings will cause the launch configuration
to change and will consequently spawn new ECS instances.

**Downtime Warning**: Using this version for the first time will cause the ECS
cluster to be rebuild.

### Bugfixes

## `0.1.3` (20181011)

### Features

#### `ECS` Update AMIs to latest version

Update the ECS AMI's to the latest version.

**Downtime Warning**: Using this version for the first time will cause the ECS
cluster to be rebuild because of the new AMI's.


#### Keep generated files when using `dockerwrapper`

Make generated files directory configurable to enable to retain those
files when using dockerwrapper ([ixor/ansible-aws-cfn-gen](https://hub.docker.com/r/ixor/ansible-aws-cfn-gen/) docker image).

#### Create or Update _CloudFormation_ stacks from templates on a S3 bucket

Because the template size limit was hit for some projects, the _CloudFormation_
templates have to be installed from a location on S3.

The bucket is created by the playbooks, a signed URL with limited validity in
time in generated and uses to access the template on S3. That way, the
bucket can remain private.

#### `S3` Lifecycle Rules

Introduce lifecycle rules. Refer to the README.md for details on how to use lifecycle rules.

```yaml
s3:
  - name: mybucket
    cfn_name: MyBucket
    access_control: Private
    static_website_hosting: no
    lifecycle_configuration: |
      Rules:
        - ExpirationInDays: 14
```

#### `ALB` idle time-out


#### `ALB` Access Logs

Enable or disable ALB access logs by adding this to the ALB definition:

```yaml
loadbalancers:
  - name: ALBInt
     ...
     accesslogs:
      state: enabled
      log_expiry_days: 14    

```

It creates:

* A S3 bucket named `{{application }}-{{ env }}-accesslogs-{{ lbname }}`
* An lifecycle rule that expires the access logs after `log_expiry_days` days
* A bucket policy that allows the AWS ALB account in the current region to
  write to that bucket

### Documentation

Misc documentation updates

### Bugfixes

## `0.1.2` (20180923)

### Features

#### IAM

Before this enhancement, `ManagedPolicyArns` in a role could only be specified by the
name of the role, not by the full _ARN_. To be able to alse attach AWS Managed policies
to a role, the policy can now also be defined by its full _ARN_:

```yaml
awsroles:
  - name: MyAWSRole
    policy_arns:
      - MyCustomPolicy
      - arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
      - arn:aws:iam::aws:policy/AmazonSNSFullAccess
    assumerole_policy_document:
      Version: '2012-10-17'
      Statement:
        - Sid: ''
          Effect: Allow
          Principal:
            Service: ecs-tasks.amazonaws.com
          Action: sts:AssumeRole
```

#### Lambda

Allow the creation of _Lambda_ functions. `lambda_functions` is a list of functions to be created. The 
function code should be available from a S3 bucket where the _CloudFormation_ template has access to. 

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
        value: MyAppName
      - name: ENVIRONMENT
        value: "{{ env }}"
      - name: DD_API_KEY
        value: 123456789123456789
    invoke_permissions:
      - type: predefined
        name: logs
```

The `invoke_permissions` only support `type: predefined`. Future requirements allow the mechanism
to be extended.

#### DynamoDB

Offers the possibility to create _DynamoDB_ tables. Does not support _Global Secondary Indexes_ yet.

An example:

```yaml
dynamodb:
  - table_name: snapshots
    attributes:
      - attribute_name: par
        attribute_type: S
      - attribute_name: seq
        attribute_type: N
      - attribute_name: ts
        attribute_type: N
    key_schema:
      - attribute_name: par
        key_type: HASH
      - attribute_name: seq
        key_type: RANGE
    local_secondary_indexes:
      - index_name: ts-idx
        key_schema:
          - attribute_name: par
            key_type: HASH
          - attribute_name: ts
            key_type: RANGE
        projection:
          projection_type: ALL
    provisioned_throughput:
      read_capacity_units: 5
      write_capacity_units: 5
```

#### ECS

* By specifying `ecs.cluster.spot_price` in the configuration file, the ECS cluster will run
  on _Spot Instances_.
* The `extra_portmappings` in `applicationconfig.ecs` can be used to expose extra ports from the
  container, for example to allow debuggers to attach to the corresponding host port over a ssh
  tunnel. Only `container_port` is required. Default for `protocol` is `tcp` and default for
  `host_port` is for it to be dynamic.
  
```yaml
applicationconfig:
  - name: myapp
    ...
    ecs:
      ...
      extra_portmappings:
        - container_port: 8002
          protocol: tcp
       ...
     ...
```

#### CloudWatch

Possibility to attach _Subscription Filters_ to a _CloudWatch Log Group_. This requires a
lambda function and a new attribute for the `application` configuration.

See above on how to create a _Lambda_ function.

And using that _Lambda_ function as the log subscription filter:

```yaml
applicationconfig:
  - name: "myapp"
    cfn_name: MyApp
    target: "ecs"
    logs_subscription_filter:
      type: lambda
      ### lambda_cfn_export_name only has to contain the last part (after the dash) of the export.
      ### The first part is (cfn_project) prepended by the templates
      lambda_cfn_export_name: AwsLambdaDatadogLogshipperArn
      filter_pattern: "-DEBUG"
```

#### CloudFront

Set the property `forward_cookies` in the list of `origins_and_cachebehaviors` for a
dictribution to forward cookies to the origin.

The `forward` property can have `all` or `whitelist` as the value. In case of `whitelist`,
a list `whitelisted_names` is required.

```yaml
cloudfront_distributions:
  - name: my-cloudfront
    origins_and_cachebehaviors:
      - origin_name: "my-cloudfront"
        forward_cookies:
          forward: whitelist
          whitelisted_names:
            - cookie1
            - cookie2
```

An example:

```yaml
cloudfront_distributions:
  - name: my-cloudfront
    ...
    origins_and_cachebehaviors:
      - origin_name: "my-cloudfront"
        ...
        forward_cookies:
          forward: all
        ...
     ...
```

### Bugfixes

#### CloudFront

S3 bucket name was incorrectly referenced in the `AWS::CloudFront::Distribution` definition.

#### Documentation

* Add warning about the valid characters in the name of an application

## `0.1.1` (20180912)

### Features

#### _CloudFront_

* Introduce `priority` in `cloudfront_distributions[*].origins_and_cachebehaviors[*]` to
  order the cachebehaviours, lower number is higher priority. The behaviors are
  processed in order of creation, the list gets sorted on the `priority` attribute.
  Default value is `999`.
* The string `asterisk` in `cloudfront_distributions[*].origins_and_cachebehaviors[*]`
  results `['*']` and in all headers being forwarded to the _Origin_.
* Add `protocol_policy` to `cloudfront_distributions[*].origins_and_cachebehaviors[*]`.
  Default value is `http-only`. Possible values are:
  * `http-only`
  * `match-viewer`
  * `https-only`
* Add `domain` property to `cloudfront_distributions[*].origins_and_cachebehaviors[*]`
  to determine the type of the origin. If missing, a S3 bucket is assumed and
  implicitely created. The `domain` is a _dict_ with 2 keys: `type` and `name`. Type
  can be any of `s3` or `import`. `name` is the name of an existing S3 bucket (for type `s3`)
  or the name of a variable to import (the _CloudFormation_ way).
* Add `custom_error_responses` to `cloudfront_distributions[*]`. This defines what to do in
  case a (any) origin returns a certain HTTP code
  
An example of the new functionalities:

```yaml
cloudfront_distributions:
    origins_and_cachebehaviors:
      - origin_name: "myOrigin"
        domain:
          type: import
          name: LarsTstLBALBExt-ALBExtDNS
        forward_headers:
          - 'asterisk'
        allowed_http_methods: options
        protocol_policy: "match-viewer"
        priority: 100
```

### Bugfixes

* The CloudFront changes introduced a new dependency (possibility to define a LB
  as an origin). Therefor, LB's must be created before the CloudFront distributions.

### Misc

* Update documentation

## `0.1.0`: First release

