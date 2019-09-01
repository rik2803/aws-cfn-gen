# `ecs`: _Elastic Container Services_

## Description

Create an (empty) ECS cluster.

## Properties

| Property                       | Required? | Description                                                                                    | Default    |
|--------------------------------|-----------|------------------------------------------------------------------------------------------------|------------|
| `task_change_state_rule`       | no        | `?Will a task stutus change in the cluster post an event to the accounts `MonitoringSNSTopic`? | `DISABLED` |
| `efs`                          | no        | List of EFS volumes to mount on the ECS instances                                              |            |
| `efs.mountpoint`               | yes       | The mountpoint to use on the ECS instance                                                      |            |
| `efs.export_name`              | yes       | The name of CloudFormation export of the EFS volume in the EFS template                        |            |
| `metadata`                     | no        | Use to configure the LaunchConfiguration metadata                                              |            |
| `metadata.commands`            | no        | List of commands to add to the LaunchConfigutations metadata                                   |            |
| `metadata.commands.id`         | no        |                                                                                                |            |
| `metadata.commands.command`    | no        |                                                                                                |            |
| `cluster.keypair`              | yes       | The keypair to set on the ECS cluster instances                                                |            |
| `cluster.dm_basesize`          | no        | Change the size of a Docker containers devicemapper size (Amazon Linux 1 only)                 |            |
| `cluster.ebs_size`             | no        | Set EBS root volume size (for AMZN2) or the size of an extra volume (for Amazon 1 AMI)         |            |
| `cluster.spot_price`           | no        | Use spot instances when set, use property to set max bid price                                 |            |
| `cluster.instance_type`        | yes       | The EC2 instance type to use for the cluster                                                   |            |
| `cluster.amzn2`                | no        | Should a AMZN2 image be used for the cluster?                                                  | `false`    |
| `cluster.cluster_size`         | no        | A description for the access, this is not used in any resource                                 |            |
| `cluster.cluster_size.min`     | no        | Minimal cluster size                                                                           | `1`        |
| `cluster.cluster_size.max`     | no        | Maximal cluster size                                                                           | `1`        |
| `cluster.cluster_size.desired` | no        | Desired cluster size                                                                           | `1`        |

## Example Configuration

```yaml
ecs:
  task_change_state_rule: "ENABLED|DISABLED"
  cluster:
    keypair: "id_rsa_ixor.ixordocs-prd"
    instance_type: "t2.xlarge"
    amzn2: true
    cluster_size:
      min: 2
      max: 5
      desired: 2
    ebs_size: 40
    dnm_basesize: 20G
```
## Detailed properties description

### `ecs.task_change_state_rule`

`ENABLE` or `DISABLE` the _CloudWatch_ event rule that sends events to the monitoring
SNS topic (and possibly notifications on Slack, Vhat, ...).

Valid values:

* `ENABLED`
* `DISABLED` (default)


### `ecs.cluster.ebs_size`

Override the default 30GB ECS Cluster instance EBS size. Unit is `GB`. It will
not add an additional volume, but extend the AMI volume to the requested size.

Must be larger than 30 to avoid stack failure.

**Downtime Warning**: Changing this setting will cause the launch configuration
to change and will consequently spawn new ECS instances.

### `ecs.cluster.dm_basesize`

Override the default 10GB of thin provisioned container storage. Unit is required (i.e. `20G`)

**Downtime Warning**: Changing this setting will cause the launch configuration
to change and will consequently spawn new ECS instances.