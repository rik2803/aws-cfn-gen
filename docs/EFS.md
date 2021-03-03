# EFS

## Description

Use this module to create _Elastic File Systems_ on the AWS account.

## Properties

| Property                                    | Required? | Description                                            | Default |
|---------------------------------------------|-----------|--------------------------------------------------------|---------|
| `cfn_name`                                  | yes       | Name for the CloudFormation resource                   |         |
| `accesspoints`                              | no        | List of access points to create for the EFS            |         |
| `accesspoints[n].cfn_name`                  | yes       | Name for the Access Point CloudFormation resource      |         |
| `accesspoints[n].cfn_path`                  | no        | The path on the EFS to mount                           | `/`     |
| `accesspoints[n].posix_user`                | no        |                                                        | `/`     |
| `accesspoints[n].posix_user.uid`            | no        |                                                        | `0`     |
| `accesspoints[n].posix_user.gid`            | no        |                                                        | `0`     |
| `accesspoints[n].posix_user.secondary_gids` | no        |                                                        |         |
| `accesspoints[n].creation_info`             | no        |                                                        |         |
| `accesspoints[n].creation_info.owner_uid`   | no        |                                                        | `0`     |
| `accesspoints[n].creation_info.owner_gid`   | no        |                                                        | `0`     |
| `accesspoints[n].creation_info.permissions` | no        |                                                        | `0755`  |

Also see [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-efs-accesspoint.html).

## Example Configuration

```yaml
efs:
  - cfn_name: MyEFS
    accesspoints:
      - cfn_name: "MyEFS_AP01"
        path: "/"
      - cfn_name: "MyEFS_AP02"
        path: "/"
        posix_user:
          uid: "123"
          gid: "456"
          secondary_gids:
            - "789"
            - "321"
        creation_info:
          owner_gid: "456"
          owner_uid: "123"
          permissions: "0750"
```
