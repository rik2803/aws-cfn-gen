### `Cloudfront`: Cloudfront Distributions

## Properties

| Property                       | Required? | Description                                                                                    | Default    |
|--------------------------------|-----------|------------------------------------------------------------------------------------------------|------------|
| `name`                            | yes        | Define the name of the Cloudfront service  |            |
| `cnames.[n]`                      | yes        | Define the Cname(s) of the Cloudfront service       |            |
| `cfn_name`                        | yes        | Define the Cloudformation name        |            |
| `default_root_object`             | no         | Specify the default root object        | index.html   |
| `logging`                         | no         | Enable access logs logging to S3-bucket       |            |
| `logging.prefix`                  | no        |         |            |
| `logging.includecookies`          | no        |         |            |
|&nbsp;|&nbsp;|&nbsp;|&nbsp;|
| `origins_and_cachebehaviors`                            | no        |         |            |
| `origins_a_cacheb.[n].origin_name`                | yes        | Resource naming origin    |            |
| `origins_a_cacheb.[n].forward_headers.[n]` | no | [deprecated] Which headers cloudfront needs to cache        |            |
| `origins_a_cacheb.forward_cookies`                                    | no  | [deprecated]   |            |
| `origins_a_cacheb.forward_cookies.[n].forward`                            | yes   | [deprecated] Not include cookies in the cache key         |            |
| `origins_a_cacheb.forward_cookies.[n].whitelisted_names`                  | Conditional     | [deprecated] How many different cookies CloudFront forwards        |            |
| `origins_a_cacheb.[n].allowed_http_methods`  | no | HTTP methods cloudfront needs to forward        |            |
| `origins_a_cacheb.[n].path_pattern`               | yes  | The pattern that specifies which requests to apply the behavior to |  /* |
| `origins_a_cacheb.[n].viewer_protocol_policy`     | yes   | The protocol that viewers can use to access   | redirect-to-https  |
| `origins_a_cacheb.[n].protocol_policy`            | yes        | The protocol that CloudFront uses to connect to the origin | http-only |
| `origins_a_cacheb.[n].origin_ssl_protocols`            | no        | The minimum SSL/TLS protocol that CloudFront uses when connecting to your origin | TLSv1.2  |
| `origins_a_cacheb.[n].min_ttl`      | no        | [deprecated] Minimum amount of time in CloudFront caches  |            |
| `origins_a_cacheb.[n].max_ttl`                            | no        | [deprecated] Maximum amount of time in CloudFront caches        |            |
| `origins_a_cacheb.[n].default_ttl`                        | no        | [deprecated] Default amount of time  in CloudFront caches        |            |
| `origins_a_cacheb.[n].certificate_arn`      | Conditional  | The Amazon Resource Name of the ACM certificate        |            |
| `origins_a_cacheb.[n].minimum_protocol_version`           | Conditional  |  The minimum SSL/TLS protocol/ciphers with viewers  |  TLSv1 |
|&nbsp;|&nbsp;|&nbsp;|&nbsp;|
| `origins_a_cacheb.origin_custom_headers`                            | no        | Custom headers send to the origin |            |
| `origins_a_cacheb.[n].origin_custom_headers.name`                   | yes        |         |            |
| `origins_a_cacheb.[n].origin_custom_headers.value`                  | yes        |         |            |
|&nbsp;|&nbsp;|&nbsp;|&nbsp;|
| `origins_a_cacheb.domain`                    | no        |         |  arn:aws:s3:::" + origin.origin_name + "/*" |
| `origins_a_cacheb.domain.type`               | yes        | Type of the origin  |            |
| `origins_a_cacheb.domain.name`               | yes        | DomainName (type import/s3)  |            |
| `origins_a_cacheb.domain.origin_domain_name` | yes        | DomainName (type custom)  |            |
| `origins_a_cacheb.domain.origin_path`        | no        | Path that CloudFront appends to the origin domain name |    |
|&nbsp;|&nbsp;|&nbsp;|&nbsp;|
| `origins_a_cacheb.custom_error_responses`    | no        | CloudFront replaces HTTP custom error messages|            |
| `origins_a_cacheb.custom_error_responses.error_caching_min_ttl`     | no        | Minimum time to let CloudFront cache the ErrorCode |  300  |
| `origins_a_cacheb.custom_error_responses.error_code`                | yes        | Status code custom error page |  404  |
| `origins_a_cacheb.custom_error_responses.response_code`             | Conditional  | Status code along with the custom error page  |  200 |
| `origins_a_cacheb.custom_error_responses.response_page_path`        | Conditional  | path to the custom error page  | /index.html |
|&nbsp;|&nbsp;|&nbsp;|&nbsp;|
| `origins_a_cacheb.lambda_function_associations.[n]`          | no        | Lambda function associations for a cache behavior  |            |
| `origins_a_cacheb.lambda_function_associations.[n].event_type`             | no        | event type that triggers a Lambda function |            |
| `origins_a_cacheb.lambda_function_associations.[n].lambda_function_arn`    | no        | ARN of the Lambda function |            |
| `origins_a_cacheb.lambda_function_associations.[n].lambda_function_version`    | no        | Version of the Lambda function   |            |
| S3 |&nbsp;|&nbsp;|&nbsp;|
| `origins_a_cacheb.origin_cors_rules`                                     | no        | The cross-origin access rule for an Amazon S3 bucket |            |
| `origins_a_cacheb.origin_cors_rules.[n].allowed_headers.[n]`  | no        | Allow header that are specified  |  |
| `origins_a_cacheb.origin_cors_rules.[n].allowed_methods.[n]`  | yes       | An HTTP method that you allow the origin to run |   |
| `origins_a_cacheb.origin_cors_rules.[n].allowed_origins.[n]`  | yes       | One or more origins you want customers to be able to access the bucket from  | |
| `origins_a_cacheb.origin_cors_rules.[n].exposed_headers.[n]`  | no        | One or more headers in the response ||
| `origins_a_cacheb.origin_cors_rules.[n].max_age`                             | no        |         |       |
|&nbsp;|&nbsp;|&nbsp;|&nbsp;|
| `origins_a_cacheb.origin_bucket_redirects`                                    | no        |  Specifies how requests are redirected |   |
| `origins_a_cacheb.origin_bucket_redirects.[n].redirect_rule`                  | yes        |  Container for redirect information  |    |
| `origins_a_cacheb.origin_bucket_redirects.[n].redirect_rule.hostname`         | no        | The host name to use in the redirect request |     |
| `origins_a_cacheb.origin_bucket_redirects.[n].redirect_rule.http_redirect_code`   | no        | The HTTP redirect code to use on the response  | 301 |
| `origins_a_cacheb.origin_bucket_redirects.[n].redirect_rule.protocol`             | no        | Protocol to use when redirecting requests | HTTPS  |
| `origins_a_cacheb.origin_bucket_redirects.[n].redirect_rule.replace_key_with`     | no        | The object key prefix to use in the redirect request |   |
| `origins_a_cacheb.origin_bucket_redirects.[n].routing_rule_condition`             | no        | The condition that must be met for the specified redirect  |   |
| `origins_a_cacheb.origin_bucket_redirects.[n].routing_rule_condition.type`        | yes        | Type of routing role  |   |
| `origins_a_cacheb.origin_bucket_redirects.[n].routing_rule_condition.value`       | Conditional | The HTTP error code when the redirect is applied | 404 |
```yaml
cloudfront_distributions:
  - name: apps
    cfn_name: Apps
    cnames:
      - "apps.acme.com"
    certificate_arn: "arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxxxx"
    minimum_protocol_version: "SSLv3" | "TLSv1" | "TLSv1_2016" | "TLSv1.1_2016" | "TLSv1.2_2018"
    logging:
      prefix: apps
    origins_a_cacheb:
      - origin_name: "apps-{{ application }}-{{ env }}"
        forward_headers:
          - Origin
        path_pattern: "/*"
        allowed_http_methods: options
        lambda_function_associations:
          - event_type: viewer-request
          - lambda_function_arn_export: Cfnname-
        priority: 999
        origin_custom_headers:
          - name: "{{ cloudfront.header_name }}"
            value: "{{ cloudfront.header_value }}"
```

```
cloudfront_distributions:
  - name: redirect-test
    cfn_name: RedirectTest
    cnames:
      - "redirect.acme.com"
    certificate_arn: "arn:aws:acm:us-east-1:123456789012:certificate/xxxxxxxx"
    origins_a_cacheb:
      - origin_name: "redirect-test"
        forward_headers:
          - Origin
        priority: 100
        origin_bucket_redirects:
          - routing_rule_condition:
              type: http_error_code_returned_equals
              value: 404
            redirect_rule:
              hostname: www.acme.com
              http_redirect_code: 301
              protocol: https
              replace_key_with: "index.html"
```

### Create _CloudFront_ distributions, including:

* the S3 bucket (default origin) when:
  * `origin.domain` is not defined *or*
  * `origin.domain.type` is `s3`
* _Route53 Record Sets_ for all the distribution's `cname`s if `route53.public_hosted_zoned`
  is defined and it contains an element where the public hosted zone name equals the
  name of the DNS domain of the distribution's `cname`.

**NOTE** - The certificate must be created in the `us-east-1` region.

* `name`
* `cfn_name`
* `cnames`

#### `Working with custom origins`

The default behaviour, when no `domain` property is defined, is to use a
S3 bucket as the origin for the distribution.

In that case, the bucket will be implicitely created and be given the name `origin.name`.

When using the `domain` property and `type` `s3`, the bucket is assumed to already exist in
the AWS account where the CloudFormation template is bing deployed.


```yaml
    origins_a_cacheb:
      - ...
      - origin_name: "{{ application }}-{{ env }}-name"
        domain:
          type: import
          name: TheNameACloudformationExport
          origin_path: /mypath
        ...  
```

```yaml
    origins_a_cacheb:
      - ...
      - origin_name: "{{ application }}-{{ env }}-name"
        domain:
          type: s3
          name: my-bucket
          origin_path: /prefix
        ...  
```

```yaml
    origins_a_cacheb:
      - ...
      - origin_name: "{{ application }}-{{ env }}-name"
        domain:
          type: custom
          origin_domain_name: "google.be"
          orinig_path: "/nl"
        ...  
```

##### `origins_a_cacheb[n].origin_name`

The value of this propery is used to:

* Name the origin
* Implicitely create a bucket with the same name (mind the global uniqueness!!)

##### `origins_a_cacheb[n].domain.type`

Can be one of these values:

* `import`: When `type` is `import`, following properties are allowed:
  * `name`: The name of the _CloudFormation_ export to be used for the import
  * `origin_path` (**optional**): If you want _CloudFront_ to request your content from a 
                                  directory in your Amazon S3 bucket or your custom origin,
                                  enter the directory name here, beginning with a `/`.
                                  _CloudFront_ appends the directory name to the value of
                                  `origin_domain_name` when forwarding the request to your origin,
                                  for example, `myawsbucket/production`. Do not include a `/`
                                  at the end of the directory name. 

* `s3`: Use the value of the `name` property as the name of the bucket in the
        same region as the region where the _CloudFormation_
        stack is being deployed. The domain that will be used by the _CloudFront_
        distribution will be
        `{{ origin.domain.name }}.s3-website.{{ target_account.region }}.amazonaws.com`
  * `name`
  * `origin_path` (**optional**): If you want _CloudFront_ to request your content from a 
                                  directory in your Amazon S3 bucket or your custom origin,
                                  enter the directory name here, beginning with a `/`.
                                  _CloudFront_ appends the directory name to the value of
                                  `origin_domain_name` when forwarding the request to your origin,
                                  for example, `myawsbucket/production`. Do not include a `/`
                                  at the end of the directory name.

* `custom`: When `type` is `custom`, following porperties are allowed:
  * `origin_domain_name`: The name of the domain to use as the origin, for example `google.com`.
  * `origin_path` (**optional**): If you want _CloudFront_ to request your content from a 
                                  directory in your Amazon S3 bucket or your custom origin,
                                  enter the directory name here, beginning with a `/`.
                                  _CloudFront_ appends the directory name to the value of
                                  `origin_domain_name` when forwarding the request to your origin,
                                  for example, `myawsbucket/production`. Do not include a `/`
                                  at the end of the directory name. 

#### Custom Error Responses

```yaml
cloudfront_distributions:
  - name: servicedesk
    ...
    custom_error_responses:
      - error_caching_min_ttl: 300
        error_code: 404
        response_code: 200
        response_page_path: /index.html
```

#### `origin_bucket_redirects`

Add redirect statements to the origin bucket.

Also see the [AWS documentation for routing rules](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-websiteconfiguration-routingrules-redirectrule.html) and the
[AWS documentation for routing rule conditions](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-websiteconfiguration-routingrules-routingrulecondition.html)
for full details on the redirection.


```
cloudfront_distributions:
  - name: redirect-test
    ...
    origins_a_cacheb:
      - origin_name: "redirect-test"
        ...
        origin_bucket_redirects:
          - routing_rule_condition:
              type: http_error_code_returned_equals
              value: 404
            redirect_rule:
              hostname: www.acme.com
              http_redirect_code: 301
              protocol: https
              replace_key_with: "index.html"
```

##### `origin_custom_headers`
```yaml
cloudfront_distributions:
  - name: headers-test
    ...
    origins_a_cacheb:
        - ...
          origin_custom_headers:
            - name: auth
              value: 4JtljybqYMrjIpbidH8L
```
##### `routing_rule_condition`

##### `redirect_rule`




