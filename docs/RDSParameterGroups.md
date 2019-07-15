# RDS Parameter Groups

## Example Configuration

```yaml
rds_parameter_groups:
  - description: stats
    cfn_name: Stats
    family: postgres9.6
    parameters:
      - key: shared_preload_libraries
        value: pg_stat_statements
      - key: pg_stat_statements.track
        value: ALL
      - key: track_activity_query_size
        value: 16384
```

## Properties