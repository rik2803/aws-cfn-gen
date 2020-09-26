# SGRules

## Description

Add ingress rules to existing _Security Groups_.

## Properties

| Property       | Required? | Description                                | Default |
|----------------|-----------|--------------------------------------------|---------|
| `cfn_name`     | yes       | Name for the CloudFormation resource       |         |
| `type`         | yes       | Type, only `ingress` is available now      |         |
| `sg_id`        | yes       | The id of the SG to add the rule to        |         |
| `source_sg_id` | yes       | The id of the SG that's allowed the access |         |
| `description`  | no        | Description                                | `NA`    |
| `protocol`     | no        | Protocol                                   | `tcp`   |
| `from_port`    | yes       | Lower end of the range of ports to allow   |         |
| `to_port`      | yes       | Upper end of the range od ports to allow   |         |

## Example Configuration

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
