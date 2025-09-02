# fluentd

An AppSRE customized version of fluentd including several plugins built into the Docker image:
- fluent-plugin-s3
- fluent-plugin-slack
- fluent-plugin-splunk-enterprise
- fluent-plugin-cloudwatch-logs
- fluent-plugin-teams

This image uses [fluentd-upstream](https://quay.io/repository/app-sre/fluentd-upstream?tab=info) as a base image and adds the plugins mentioned above.

Used as a sidecar for logging [qontract-reconcile](https://github.com/app-sre/qontract-reconcile/) & 
[vault-manager](https://github.com/app-sre/vault-manager/) and other AppSRE projects.
