# The `ecsmgmt` FARGATE ECS cluster

When the property `ecsmgmt` is set, these resources will be created:

* a ECS FARGATE cluster. This cluster is not backed by EC2 instances and
  does not add to your AWS bill unless a FARGATE service is run
* an execution role
* a task role
* 2 task definitions
  * `tryxcom/aws-delete-tagged-cfn-stacks:latest`
  * `tryxcom/aws-create-deleted-tagged-cfn-stacks:latest`
* Custom task definitions defined in the property `acsmgmt.fargate_tasks[]`.
  Following resources are created for each task:
  * a IAM user
  * a set of credentials (available in the _CloudFormation_ template's output)
    that allow the `ecs:RunTask` action
  * A task role to be used in the task definition
  * A _CloudWatch_ log group where the task's log streams will be
    sent to
  * And the _Task Definition_, of course
* Custom scheduled task definitions

See these github repositories for more information on what these
images do:

* [https://github.com/rik2803/aws-create-deleted-tagged-cfn-stacks]()
* [https://github.com/rik2803/aws-delete-tagged-cfn-stacks]()

## Properties

### Main

| Property          | Required? | Description                                                                                |
|-------------------|-----------|--------------------------------------------------------------------------------------------|
| `ass.tag_prefix`  | no       | Prefix used to set the `ASS_TAG_PREFIX` in the `ASS` task definitions                       |
| `fargate_tasks`   | no       | List of dicts that define custom task definitions to run in the _FARGATE_ cluster           |
| `scheduled_tasks` | no       | List of dicts that define custom scheduled task definitions to run in the _FARGATE_ cluster |
| `monitoring`      | no       | Properties related to monitoring                                                            |

### Fargate task definition

| Property             | Required? | Description                                                                                      | Default |
|----------------------|-----------|--------------------------------------------------------------------------------------------------|---------|
| `name`               | yes       | Used as name for the _Task Family_ and to name related resources                                 |         |
| `cfn_name`           | yes       | _CloudFormation_ resource compatible name                                                        |         |
| `image`              | yes       | The docker image used to run the task                                                            |         |
| `task_role_policies` | yes       | A list of existing managed policies to add to the task role                                      |         |
| `environment`        | no        | A list of dicts with `name` and `value` keys used to set the environment for the task definition |         |
| `memory`             | no        | Memory (MB) for the fargate task                                                                 | `1024`  |
| `cpu`                | no        | CPU (unit 1/1000 vcpu) used for the fargate task                                                 | `512`   |

**Remark**: Check [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ecs-taskdefinition.html)
for allowed `memory`/`cpu` combinations. Invalid combinations will cause the stack to fail.

### Scheduled task definition

| Property                            | Required? | Description                                                              |
|-------------------------------------|-----------|--------------------------------------------------------------------------|
| `cfn_name`                          | yes       | _CloudFormation_ resource compatible name                                |
| `schedule_expression`               | yes       | Schedule expression, `cron()` or `rate()`, see AWS docs for details      |
| `task_definition_cfn_resource_name` | yes       | The task definition to use. Define task definitions with `fargate_tasks` |

### Monitoring properties

| Property                  | Required? | Description                                                                              |
|---------------------------|-----------|------------------------------------------------------------------------------------------|
| `adag_alarm_exclude_list` | no        | Alarm names matching one of the strings in this space separated list will not be created |

## Example configuration

```yaml
ecsmgmt:
  ass:
    tag_prefix: "prefix_string"
  monitoring:
    adag_alarm_exclude_list: "5XX"
  fargate_tasks:
    - name: task-name
      cfn_name: TaskName
      image: "acme/myimage:latest"
      task_role_policies:
        - "arn:aws:iam::aws:policy/ExistingPolicyName"
        - "arn:aws:iam::aws:policy/AnotherExistingPolicyName"
      environment:
        - name: "ENV"
          value: "tst"
        - name: "PROJECT"
          value: "myproject"
```

