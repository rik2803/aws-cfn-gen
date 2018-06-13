# AWS CloudFormation Template Generator

This repository consists of:

* A _Ansible_ playbook
* A number of _Ansible_ templates that generate AWS CloudFormation templates with an external configuration
  file as driver

## Resources that can be created using this repository

* AWS Application Load Balacders (ALB)
* AWS ECR
* AWC ECS Cluster
* AWS ECS Tasks and Services
* S3 buckets
* Route 53 private Hosted Zones
* IAM Users, Roles and Policies

## Links and Resources

* General Elastic Beanstalk options for all environments: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html
* Platform specific options: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-specific.html

## Order of installation is important

## Configuration file

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

## Links
