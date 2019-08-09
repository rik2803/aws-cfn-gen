# The AWS Key Management Service

When the property `kms` is set, these resources will be created:

* A KMS Custom Managed Key (CMK) for every element in the list
  `kms.keylist`
* An alias to the key
* A key resource policy, attached to the key

## Properties

### Main (`kms`)

| Property  | Required? | Description           | Default |
|-----------|-----------|-----------------------|---------|
| `keylist` | yes       | A list of keys to add |         |

### `keylist`

| Property                                 | Required? | Description                                                                             | Default    |
|------------------------------------------|-----------|-----------------------------------------------------------------------------------------|------------|
| `cfn_name`                               | yes       | A valid _CloudFormation_ logical resource name                                          |            |
| `description`                            | no        | Key description                                                                         | `cfn_name` |
| `policy.principals`                      | yes       | A list of dicts with keys `name` and `principal_string`                                 |            |
| `policy.principals.[n].name`             | no        | A description for the access, this is not used in any resource                          |            |
| `policy.principals.[n].principal_string` | yes       | The principal that will be able to access (`secretsmanager:GetSecretsValue`) the secret |            |

## Example configuration

```yaml
kms:
  keylist:
    - cfn_name: "SecretsManagerKey"
      description: "Key used to encrypt Secrets"
      policy:
        principals:
          - name: "testaccount"
            principal_string: "123456789012"
          - name: "stagingaccount"
            principal_string: "456789012345"
          - name: "anotheraccount"
            principal_string: "789012345678"
```

