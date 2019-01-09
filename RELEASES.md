# Release notes

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

