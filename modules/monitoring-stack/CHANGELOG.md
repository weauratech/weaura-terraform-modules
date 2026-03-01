# Changelog

## [1.1.0](https://github.com/weauratech/weaura-terraform-modules/compare/monitoring-stack/v1.0.0...monitoring-stack/v1.1.0) (2026-03-01)


### Features

* add monitoring-stack terraform module ([c104914](https://github.com/weauratech/weaura-terraform-modules/commit/c104914236c33b7bcfa83ab2f2138e31646d16d0))
* **monitoring-stack:** add dedicated gp3 StorageClass with WaitForFirstConsumer ([7d028a7](https://github.com/weauratech/weaura-terraform-modules/commit/7d028a71a64cfdec3099cc41ac2304bf1109a33a))
* **monitoring-stack:** add default Kubernetes alert rules via Grafana unified alerting ([9923031](https://github.com/weauratech/weaura-terraform-modules/commit/9923031b2f3c1d76b81f9d35416badc75d881db0))
* **monitoring-stack:** add Google Chat and Teams alerting support ([a96cfea](https://github.com/weauratech/weaura-terraform-modules/commit/a96cfea3d0c41c20bd1789ebb08eb9cb01e3937f))
* **monitoring-stack:** add Grafana alerting, folders, AWS secrets, and TLS external secret ([d9661ab](https://github.com/weauratech/weaura-terraform-modules/commit/d9661ab23e8f2e54d8d291266dee3856187c93ac))
* **monitoring-stack:** add Helm releases with Harbor OCI and value templates ([af5559b](https://github.com/weauratech/weaura-terraform-modules/commit/af5559bd31307709ea3e3cf725053ac6098081cd))
* **monitoring-stack:** port core infrastructure from grafana-oss-aws module ([3efe8aa](https://github.com/weauratech/weaura-terraform-modules/commit/3efe8aa04676da0aedc4eb624b51b4c0f207cba4))
* **monitoring-stack:** replace ECR with Harbor chart registry ([467db69](https://github.com/weauratech/weaura-terraform-modules/commit/467db69c83bea1f63cc31cf9342432bb90dc475b))
* **monitoring-stack:** switch GitHub SSO to generic_oauth, upgrade Grafana to 11.6, enable Drilldown ([7aac872](https://github.com/weauratech/weaura-terraform-modules/commit/7aac8721cc6105814441ebe037f670203058f6b6))
* **monitoring-stack:** switch SSO from generic_oauth to native auth.github ([b8ad452](https://github.com/weauratech/weaura-terraform-modules/commit/b8ad45255cda4680dc424a09697ff43201b642b0))
* **monitoring-stack:** v2.1.0 - Grafana 12.4.0, SSO slug-based team matching, standalone mimir/tempo/pyroscope helm releases ([9e8e150](https://github.com/weauratech/weaura-terraform-modules/commit/9e8e1507d919803e52485c4dcd1eb168493ae858))


### Bug Fixes

* **alert-rules:** move thresholds from PromQL to Grafana threshold expression ([55baf2a](https://github.com/weauratech/weaura-terraform-modules/commit/55baf2a90c35e8012111a935fd18b0abd94b6cbd))
* **alerting:** remove unsupported default pipe filter from message template ([b18d919](https://github.com/weauratech/weaura-terraform-modules/commit/b18d919e7342d87b8a1adae4d5d48731c83742d6))
* **module:** Monitoring stack - correct node-exporter and retention configuration ([f15792f](https://github.com/weauratech/weaura-terraform-modules/commit/f15792f1d39f92279dac4859c9ca737b6a5fa1a9))
* **monitoring-stack:** add required relative_time_range to all grafana_rule_group data blocks ([49ea82a](https://github.com/weauratech/weaura-terraform-modules/commit/49ea82a2163c9c88c07195d34245b8f9cb315473))
* **monitoring-stack:** disable admission webhooks to fix patch job failure ([41623a5](https://github.com/weauratech/weaura-terraform-modules/commit/41623a5bb2f8c5307618cae0435019741c3e2e62))
* **monitoring-stack:** disable TLS on prometheus-operator to fix CrashLoopBackOff ([0230227](https://github.com/weauratech/weaura-terraform-modules/commit/02302272108d68dae1aad155377d42d6b47bd8f7))
* **monitoring-stack:** enable recording rules and kube-state-metrics ServiceMonitor ([7e9ac9d](https://github.com/weauratech/weaura-terraform-modules/commit/7e9ac9d7fcc958d91c52b4629ead966426d246da))
* **monitoring-stack:** replace emoji surrogates with ASCII in alert titles ([35a50ac](https://github.com/weauratech/weaura-terraform-modules/commit/35a50ac48b104748b608e88365960b60d594414d))
* rewrite notification templates for Google Chat compatibility ([d1fbb89](https://github.com/weauratech/weaura-terraform-modules/commit/d1fbb894857eb5c47408ebb9b98f74afc85f8f49))
