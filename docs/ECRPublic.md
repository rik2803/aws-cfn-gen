# ECRPublic

## Description

A list of repositories to create on the AWS account in the `us-east-1` region, as this
is the onlyu region where public repositories can be created.

It is also possible to optionally provide a list of AWS account id's that can pull
the image.

## Properties

| Property                    | Required? | Description                                            | Default |
|-----------------------------|-----------|--------------------------------------------------------|---------|
| `name`                      | yes       | Repository name                                        |         |
| `cfn_name`                  | yes       | Name for the CloudFormation resource                   |         |
| `cross_account_access.pull` | no        | List of **existing** AWS account id's with pull access |         |
| `scanonpush`                | no        | Scan Docker images on push                             |         |

## Example Configuration

```yaml
ecrpublic:
  repositories:
    - name: acme/mydockerimage
      cfn_name: AcmeMyDockerImage
      cross_account_access:
        pull:
          - 112233445566
          - 223344556611
      scanonpush:
```
