# Discover XRay Daemon in ECS Cluster

## Why?

Using XRay in an ECS Cluster requires the services to instrument
to be able to reach the _XRay_ agent, also running as a task in
ECS cluster. The communication between the instrumented services
and the _XRay_ agent is over `tcp`/`udp`. Consequently it is not
sufficient to put the agent behind a load balancer.

## How?

The solution described here uses a _CloudWatch Event Rule_ and a
_Lambda_ function. The _CloudWatch Event Rule_ listens for ECS task
state change events where current and desired status are `RUNNING`.
When such an event occurs, the rule triggers a _Lambda_ function.
The _Lambda_ function requires 3 environment variables to be able
to successfully finish the task:

* `HOSTED_ZONE_ID`: The ID of the hosted zone where the resource
  record should be added
* `RR_NAME`: The name of the DNS record to add to the private
  _Route 53_ hosted zone.
* `TASK_GROUP`: To avoid that the _Lambda_ function creates or
  updates the DNS record at every launch of any ECS task, it
  checks the task group in the incoming event against the value
  of this environment variable.
  
The _Lambda_ function performs these steps:

* Check if the task group is correct, stop if it isn't
* Determine the _ECS Container Instance ID_
* From the _ECS Container Instance ID_, determine the
  _EC2 Instance ID_
* Get the EC2 instance details and retrieve the private
  IP address
* `UPSERT` (i.e. update or insert) the _Route 53 Resource Record_

The services to be instrumented can simply find the _XRay_ agent 

## Configuration example

Strings between `<` and `>` in the configuration below should be
replaced with the values for your environment.

It might also be a good idea to use your own domain name instead of
`acme.com`. But that's not a hard requirement, it's a private hosted
zone.

```
# Create a Route 53 private hosted zone
route53:
  private_hosted_zones:
    - name: acme.com
      cfn_name: AcmeCom

# Create the CloudWatch Event Rule
cw:
  event_rules:
    - name: ECSTaskChangeToRunningRunning
      description:
      pattern:
        source:
          - aws.ecs
        detail-type:
          - ECS Task State Change
        detail:
          desiredStatus:
            - RUNNING
          lastStatus:
            - RUNNING
      targets:
        - type: import
          value: SandboxLambda-TaskToR53XrayArn

# Create the XRay service
  - name: "xray-daemon"
    cfn_name: XRayDaemon
    target: "ecs"
    deploymentconfiguration:
      max_percent: 100
      min_healthy_percent: 0
    ecs:
      image: "amazon/aws-xray-daemon"
      containerport: 3000
      extra_portmappings:
        - container_port: 2000
          host_port: 2000
          protocol: udp
        - container_port: 2000
          host_port: 2000
          protocol: tcp
      memory: 256
      cpu: 128
      desiredcount: 1
      task_role_arn: "arn:aws:iam::{{ target_account.account_id }}:role/<taskrolename>"
      
# Create the iam resources required for the Lambda function
managed_policies:
  - name: LambdaTaskToR53
    policy_document:
      Version: '2012-10-17'
      Statement:
        - Sid: AllowEC2DescribeInstances
          Effect: Allow
          Action: ec2:DescribeInstances
          Resource: "*"
        - Sid: AllowListAndDescribeContainerInstances
          Effect: Allow
          Action:
            - ecs:ListContainerInstances
            - ecs:DescribeContainerInstances
          Resource: "*"
        - Sid: VisualEditor0
          Effect: Allow
          Action: route53:ChangeResourceRecordSets
          Resource: "*"
awsroles:
  - name: LambdaTaskToR53
    policy_arns:
      - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
      - LambdaTaskToR53
    assumerole_policy_document:
      Version: '2012-10-17'
      Statement:
        - Sid: ''
          Effect: Allow
          Principal:
            Service: lambda.amazonaws.com
          Action: sts:AssumeRole

# Create the Lambda function
lambda_functions:
  - name: task-to-r53-xray
    function_name: TaskToR53XRay
    handler: main
    runtime: go1.x
    timeout: 20
    role: LambdaTaskToR53
    code:
      s3_bucket: "ixortooling-prd-s3-lambda-function-store-public"
      s3_key: aws-lambda-task-to-r53.zip
    environment:
      - name: HOSTED_ZONE_ID
        value_from_import: "<ProjectCfnName>Route53-Route53PrivateHostedZoneAcmeCom"
      - name: RR_NAME
        value: "xray.acme.com"
      - name: TASK_GROUP
        value: "service:<projectname>-xray-daemon"
    invoke_permissions:
      - type: predefined
        description: "Allows CloudWatch event rule to trigger this lambda function"
        name: events
        event_basename: rule/ECSTaskChangeToRunningRunning

```
