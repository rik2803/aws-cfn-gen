# Release notes

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

