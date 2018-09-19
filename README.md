# AWS CloudFormation Template Generator

## TL;DR

This repository consists of:

* A _Ansible_ playbook
* A number of _Ansible_ templates that generate AWS CloudFormation templates with an external configuration
  file as driver

In combination with the configuration file, the _Ansible_  playbook creates a set of
AWS CloudFormation templates, and deploys these templates to you AWS account.

## Dependencies and Prerequisites

* A _Docker_ engine when using the `dockerwrapper` to build and deploy the templates
* A local _Ansible_ and _AWS CLI_ client installation when **not** using the
  `dockerwrapper`
* The templates use resources created by the `VPC.yml` template in
  [this repository](https://github.com/rik2803/aws-cfn-templates). This should disappear
  in the future, but until then, we've got to deal with it.

## Running the playbook in a controlled manner

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

### `applicationconfig`

`applicationconfig` is a list of applications to run in the ECS cluster. Each
element in tha `applicationconfig` list contains the application description.

```javascript
  - name: "servicename"
    cfn_name: ServiceName
    target: "ecs"
    environment:
      - name: JAVA_OPTS
        value: "-Xmx2048m"
    ecs:
      image: "123456789012.dkr.ecr.eu-central-1.amazonaws.com/example/service:latest"
      containerport: 8080
      memory: 2048
      cpu: 512
      desiredcount: 2
      healthcheckgraceperiodseconds: 3600
      task_role_arn: "arn:aws:iam::123456789012:role/ECSTaskRole"
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

#### `applicationconfig.name`

**Important**: The `name` should only contain letters, numbers, hyphens and colons, underscores are not allowed.

#### `applicationconfig.target`

*TODO*: Refactor this property away 

#### `applicationconfig.environment`

A list of key-value pairs to add to the environment variables of the running container

```javascript
    environment:
      - name: JAVA_OPTS
        value: "-Xmx2048m"
```

#### `application.ecs`

##### `application.ecs.image`

##### `application.ecs.containerport`
##### `application.ecs.memory`
##### `application.ecs.cpu`

The number of CPU shares to allocate to the running container. Each vCPU on AWS
accounts for 1024 CPU shares. The available number of CPI shares on the cluster is
`1024 * sum_of_vCPUs_of_all_clusternodes`.

For a list of vCPUs per instance type, look [here](http://aws.amazon.com/ec2/instance-types/).

##### `application.ecs.desiredcount`

##### `application.ecs.deploymentconfiguration`

##### `application.ecs.deploymentconfiguration.max_percent`

##### `application.ecs.deploymentconfiguration.min_healthy_percent`


#### `application.lb`

##### `application.lb.name`

##### `application.lb.type`

##### `application.lb.healthcheckpath`

##### `application.lb.healthcheckokcode`

##### `application.lb.targetgroup`

### `ecr`: _Elastic Container Registry_

A list of repositories to create on the AWS account. This implicitely creates 2 users,
`ECRPush` and `ECRPull` and their obvious permissions on all those repositories.

```yaml
ecr:
  repositories:
    - name: acme/mydockerimage
      cfn_name: AcmeMyDockerImage
```

### `ecs`: _Elastic Container Services_

Create an (empty) ECS cluster.

```yaml
ecs:
  cluster:
    keypair: "id_rsa_ixor.ixordocs-prd"
    instance_type: "t2.xlarge"
    cluster_size:
      min: 2
      max: 5
      desired: 2
```

### `loadbalancers`: Create _Application Load Balancers_

`loadbalancers` is a list of, you guessed it, loadbalancers.

It creates a typical loadbalancer, with these components:

* An application loadbalancer (`AWS::ElasticLoadBalancingV2::LoadBalancer`). This can be an
  internet-facing loadbalancer (`scheme: internet-facing`), or an internal loadbalancer (`scheme: internal`).
  The _Security Groups_ and subnets used for the loadbalancer are extracted from the
  VPC stack mentioned before. That stack uses AWSs reference architecture and matches most setups.
* A HTTP listener on both internet-facing andinternal loadbalancers.
* A HTTPS listener on the ointernet-facing loadbalancer. This requires a certificate for TLS
  termination.
* A default target group for HTTP and HTTPS

```yaml
loadbalancers:
  - name: ALBExt
    scheme: "internet-facing"
    certificate_arn: "arn:aws:acm:eu-central-1:632928949881:certificate/2e225841-3a4a-41cd-a677-325f7d2cf262"
    def_tg_http_healthcheckpath: /health
    def_tg_https_healthcheckpath: /health
  - name: ALBInt
    scheme: "internal"
```

### `route53`

TODO

### `s3`

Create S3 buckets.

Other S3 buckets might be created implicitely by the other components (i.e. _CloudFront_), but `s3` can be used
to explicitely create buckets.


```yaml
s3:
  - name: mybucket
    cfn_name: MyBucket
    access_control: Private
    static_website_hosting: no
```

### `cloudfront_distributions`

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
    certificate_arn: "arn:aws:acm:us-east-1:123456789012:certificate/1d2e5c3-2f5e-a8e8dw8-f2c5-5d42170bbe0"
    logging:
      prefix: apps
    origins_and_cachebehaviors:
      - origin_name: "apps-{{ application }}-{{ env }}"
        forward_headers:
          - Origin
        path_pattern: "/*"
        allowed_http_methods: options
        priority: 999
```
## Links
