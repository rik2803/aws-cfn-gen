# ECR

## Description

A list of repositories to create on the AWS account. A default lifecycle configuration
is assigned to the _repository_. The lifecycle policy will remove all untagged images
older than 14 days.

This implicitely creates 2 users,`ECRPush` and `ECRPull` and their minimal permissions
on all defined repositories.

It is also possible to optionally provide a list of AWS account id's that can pull
the image.

## Properties

| Property                    | Required? | Description                                            | Default |
|-----------------------------|-----------|--------------------------------------------------------|---------|
| `name`                      | yes       | Repository name                                        |         |
| `cfn_name`                  | yes       | Name for the CloudFormation resource                   |         |
| `cross_account_access.pull` | no        | List of **existing** AWS account id's with pull access |         |
| `scanonpush`                | no        | Scan Docker images on push                             |         |
| `public`                    | no        | Make the repo publicly available (anon pulls)          | `false` |

## Example Configuration

```yaml
ecr:
  repositories:
    - name: acme/mydockerimage
      cfn_name: AcmeMyDockerImage
      cross_account_access:
        pull:
          - 112233445566
          - 223344556611
      scanonpush:
```
