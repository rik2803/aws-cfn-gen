# AWS Secrets Manager resources

When the property `secrets_manager` is set, these resources will be created:

* A secret **without a value**.
* A IAM resource policy that will be attached to the secret and
  allows access to AWS principals listed in the resource's configuration

## Properties

### Main (`secrets_manager`)

| Property  | Required? | Description                                | Default |
|-----------|-----------|--------------------------------------------|---------|
| `secrets` | yes       | A list of secrets to add to SecretsManager |         |

### `secrets`

| Property                                 | Required? | Description                                                                                     | Default |
|------------------------------------------|-----------|-------------------------------------------------------------------------------------------------|---------|
| `name`                                   | yes       | The name of the secret                                                                          |         |
| `cfn_name`                               | yes       | A valid _CloudFormation_ logical resource name                                                  |         |
| `kms_key_id_import`                      | yes       | A _CloudFormation_ output that contains the ARN of the KMS key to be used to encrypt the secret |         |
| `policy.principals`                      | yes       | A list of dicts with keys `name` and `principal_string`                                         |         |
| `policy.principals.[n].name`             | no        | A description for the access, this is not used in any resource                                  |         |
| `policy.principals.[n].principal_string` | yes       | The principal that will be able to access (`secretsmanager:GetSecretsValue`) the secret         |         |

## Example configuration

```yaml
secrets_manager:
  secrets:
    - name: "my/first/secret"
      cfn_name: "MyFirstSecret"
      kms_key_id_import: "OutputNameOfKMSKey"
      policy:
        principals:
          - name: "Description, not used in the resource itself"
            principal_string: "arn:aws:iam::123456789012:role/access_to_a_secret"
```

