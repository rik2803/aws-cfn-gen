# Release notes

## `0.1.1` (20180912)

### Features

#### _CloudFormation_

* Introduce `priority` in `cloudfront_distributions[*].origins_and_cachebehaviors[*]` to
  order the cachebehaviours, lower number is higher priority. The behaviors are
  processed in order of creation, the list gets sorted on the `priority` attribute.
  Default value is `999`.
* The string `asterisk` in `cloudfront_distributions[*].origins_and_cachebehaviors[*]`
  results `['*']` and in all headers being forwarded to the _Origin_.
* Add `protocol_policy` to `cloudfront_distributions[*].origins_and_cachebehaviors[*]`.
  Default value is `http-only`. Possible values are:
  * `http-only`
  * `match-viewer`
  * `https-only`
* Add `domain` property to `cloudfront_distributions[*].origins_and_cachebehaviors[*]`
  and determines the type of the origin. If missing, a S# bucket is assumed and
  implicitely created. The `domain` is a _dict_ with 2 keys: `type` and `name`. Type
  can be any of `s3` or `import`. `name` is the name of an existing S3 bucket (for tpye `s3`)
  or the name of a variable to import (the CloudFormation way).
* Add `custom_error_responses` to `cloudfront_distributions[*]`. This defines what to do in
  case a (any) origin returns a certain HTTP code
  
An example of the new functionalities:

```yaml
cloudfront_distributions:
    origins_and_cachebehaviors:
      - origin_name: "myOrigin"
        domain:
          type: import
          name: LarsTstLBALBExt-ALBExtDNS
        forward_headers:
          - 'asterisk'
        allowed_http_methods: options
        protocol_policy: "match-viewer"
        priority: 100
```

### Bugfixes

* The CloudFront changes introduced a new dependency (possibility to define a LB
  as an origin). Therefor, LB's must be created before the CloudFront distributions.

### Misc

* Update documentation

## `0.1.0`: First release

