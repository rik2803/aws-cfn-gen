# Run multiple ECS Clusters in the same VPC


This document describes how to run more than one ECS cluster in the same VPC using
`aws-cfn-gen`.

The key to accomplish this is to split the configuration file:

* One for the VPC
* One for each ECS cluster

Because resources within the same account-region cannot have the same name,
it is also important to have different namespaces for the resources of each
configuration file. Namespaces are based on the properties `project.name` and
`project.cfn_name`. The former is used to name the AWS resources, the latter
to build the _CloudFormation_ logical ids.

Even while this is possible, it is best practice to separate applications
and environments as much as possible, even in a separate AWS account.

