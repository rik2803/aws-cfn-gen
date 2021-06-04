# EFS S3ToEFSCopy

## Description

Use this module to create a _S3 Bucket_, _Elastic File Systems_ and a _Lambda Function_ with the required permissions
to make the process of tranferring the files to the _Elastic File Systems_ easy.

The user needs to transfer the files to the S3 Bucket.

S3 Bucket (`tst-sand-efs-fs-d9ce6d82`) -> Lambda copy to EFS -> EFS (`fs-d9ce6d82`)

**Files inside the S3 bucket will be deleted automaticly after 30 days !**

## Properties

| Property                                    | Required? | Description                                                     | Default |
|---------------------------------------------|-----------|-----------------------------------------------------------------|---------|
| `cfn_name`                                  | yes       | Name for the CloudFormation resource                            |         |
| `s3_to_efs_copy`                            | yes       | Activate the efs copy setup                                     |         |
| `s3_to_efs_copy[n].lambda_key`              | yes       | The lambda s3 object key. Found inside the S3 Lambda bucket     |         |


## Example Configuration

```yaml
efs:
  - cfn_name: MyS3ToEFSCopy
    s3_to_efs_copy:
      lambda_key: aws-lambda-s3-trigger-to-efs-c78524de709fb97bce19e0e5b4bda04329a0f082.zip
```
