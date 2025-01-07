# Terraform Module for AWS RDS Cloudwatch Alarms

This Terraform module manages Cloudwatch Alarms for an RDS instance. It does NOT create or manage RDS, only Metric Alarms.

**Requires**:
- AWS Provider
- Terraform 0.13 or higher

If you need Terraform 0.12, you should use version `2.x` of this module and contribute changes to the `tf-0.12` branch.

## Alarms Created

Alarms Always Created (default values can be overridden):
- CPU Utilization above 90%
- Disk queue depth above 64
- Disk space less than 10 GB
- EBS Volume burst balance less than 100
- Freeable memory below 256 MB
- Swap usage above 256 MB
- Anomalous connection count

If the instance type is a T-Series instance type (automatically determind), the following alarms are also created:
- CPU Credit Balance below 100

If the database engine is any of postgres type (configured with var.engine), then the following alarms are also created:
- Maximum used transaction IDs over 1,000,000,000 [[reference](https://aws.amazon.com/blogs/database/implement-an-early-warning-system-for-transaction-id-wraparound-in-amazon-rds-for-postgresql/)]

**Estimated Operating Cost**: $ 1.00 / month

- $ 0.10 / month for Metric Alarms (7x)
- $ 0.30 / month for Anomaly Alarm (1x)

## Example

```hcl-terraform
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier_prefix    = "rds-server-example"
  db_name               = "my-db"
  username             = "foo"
  password             = "bar"
  parameter_group_name = "default.mysql5.7"
  apply_immediately    = "true"
  skip_final_snapshot  = "true"
}

resource "aws_sns_topic" "default" {
  name_prefix = "my-premade-topic"
}

module "aws-rds-alarms" {
  source            = "lorenzoaiello/rds-alarms/aws"
  version           = "x.y.z"
  db_instance_id    = aws_db_instance.default.identifier
  db_instance_class = "db.t2.micro"
  actions_alarm     = [aws_sns_topic.default.arn]
  actions_ok        = [aws_sns_topic.default.arn]
}
```

This above can pair very nicely for example with an [module which creates an SNS topic which sends your alerts into Slack](https://github.com/terraform-aws-modules/terraform-aws-notify-slack).  For example:

```hcl-terraform
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier_prefix    = "rds-server-example"
  db_name              = "my-db"
  username             = "foo"
  password             = "bar"
  parameter_group_name = "default.mysql5.7"
  apply_immediately    = "true"
  skip_final_snapshot  = "true"
}

module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 4.0"

  sns_topic_name = "slack-topic"

  slack_webhook_url = "https://hooks.slack.com/services/AAA/BBB/CCC"
  slack_channel     = "aws-notification"
  slack_username    = "reporter"
}

module "aws-rds-alarms" {
  source            = "lorenzoaiello/rds-alarms/aws"
  version           = "x.y.z"
  db_instance_id    = aws_db_instance.default.identifier
  db_instance_class = "db.t2.micro"
  actions_alarm     = [module.notify_slack.slack_topic_arn]
  actions_ok        = [module.notify_slack.slack_topic_arn]
}
```



## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| actions\_alarm | A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution. | `list` | `[]` | no |
| actions\_ok | A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution. | `list` | `[]` | no |
| anomaly\_period | The number of seconds that make each evaluation period for anomaly detection. | `string` | `"600"` | no |
| anomaly_band_width | The width of the anomaly band detection.  Higher numbers means less sensitive | `string` | `"2"` | no |
| db\_instance\_id | RDS Instance ID | `string` | n/a | yes |
| engine | The RDS engine being used. Used for database engine specific alarms | `string` | `""` | no |
| evaluation\_period | The evaluation period over which to use when triggering alarms. | `string` | `"5"` | no |
| prefix | Alarm Name Prefix | `string` | `""` | no |
| statistic\_period | The number of seconds that make each statistic period. | `string` | `"60"` | no |
| tags | Tags to attach to each alarm | `map(string)` | `{}` | no |
| db_instance_class | The rds instance-class, e.g. `db.t3.medium` | `string` |  | yes |
| cpu_utilization_too_high_threshold | Alarm threshold for the 'highCPUUtilization' alarm | `string` | `"90"` | no |
| cpu_credit_balance_too_low_threshold | Alarm threshold for the 'lowCPUCreditBalance' alarm | `string` | `"100"` | no |
| disk_queue_depth_too_high_threshold | Alarm threshold for the 'highDiskQueueDepth' alarm | `string` | `"64"` | no |
| disk_free_storage_space_too_low_threshold | Alarm threshold for the 'lowFreeStorageSpace' alarm (in bytes) | `string` | `"10000000000"` | no |
| disk_burst_balance_too_low_threshold | Alarm threshold for the 'lowEBSBurstBalance' alarm | `string` | `"100"` | no |
| maximum_used_transaction_ids_too_high_threshold | Alarm threshold for the 'maximumUsedTransactionIDs' alarm | `string` | `"1000000000"` | no |
| memory_freeable_too_low_threshold | Alarm threshold for the 'lowFreeableMemory' alarm (in bytes) | `string` | `"256000000"` | no |
| memory_swap_usage_too_high_threshold | Alarm threshold for the 'highSwapUsage' alarm (in bytes) | `string` | `"256000000"` | no |
| create_high_cpu_alarm | Whether or not to create the high cpu alarm | `bool` | `true` | no |
| create_low_cpu_credit_alarm | Whether or not to create the low cpu credit alarm | `bool` | `true` | no |
| create_high_queue_depth_alarm | Whether or not to create the high queue depth alarm | `bool` | `true` | no |
| create_low_disk_space_alarm | Whether or not to create the low disk space alarm | `bool` | `true` | no |
| create_low_disk_burst_alarm | Whether or not to create the low disk burst alarm | `bool` | `true` | no |
| create_low_memory_alarm | Whether or not to create the low memory free alarm | `bool` | `true` | no |
| create_swap_alarm | Whether or not to create the high swap usage alarm | `bool` | `true` | no |
| create_anomaly_alarm | Whether or not to create the fairly noisy anomaly alarm | `bool` | `true` | no |


## Outputs

| Name | Description |
|------|-------------|
| alarm\_connection\_count\_anomalous | The CloudWatch Metric Alarm resource block for anomalous Connection Count |
| alarm\_cpu\_credit\_balance\_too\_low | The CloudWatch Metric Alarm resource block for low CPU Credit Balance |
| alarm\_cpu\_utilization\_too\_high | The CloudWatch Metric Alarm resource block for high CPU Utilization |
| alarm\_disk\_burst\_balance\_too\_low | The CloudWatch Metric Alarm resource block for low Disk Burst Balance |
| alarm\_disk\_free\_storage\_space\_too\_low | The CloudWatch Metric Alarm resource block for low Free Storage Space |
| alarm\_disk\_queue\_depth\_too\_high | The CloudWatch Metric Alarm resource block for high Disk Queue Depth |
| alarm\_memory\_freeable\_too\_low | The CloudWatch Metric Alarm resource block for low Freeable Memory |
| alarm\_memory\_swap\_usage\_too\_high | The CloudWatch Metric Alarm resource block for high Memory Swap Usage |
| alarm_maximum_used_transaction_ids_too_high | The CloudWatch Metric Alarm resource block for postgres' Transaction ID Wraparound |
