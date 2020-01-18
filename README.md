# Terraform Module for AWS RDS Cloudwatch Alarms

This Terraform module manages Cloudwatch Alarms for an RDS instance. It does NOT create or manage RDS, only Metric Alarms.

**Requires**:
- AWS Provider
- Terraform 0.12

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
  name                 = "my-db"
  username             = "foo"
  password             = "bar"
  parameter_group_name = "default.mysql5.7"
  apply_immediately    = "true"
  skip_final_snapshot  = "true"
}

module "aws-rds-alarms" {
  source            = "lorenzoaiello/aws-rds-alarms"
  db_instance_id    = aws_db_instance.default.id
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| actions\_alarm | A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution. | `list` | `[]` | no |
| actions\_ok | A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution. | `list` | `[]` | no |
| anomaly\_period | The number of seconds that make each evaluation period for anomaly detection. | `string` | `"600"` | no |
| db\_instance\_id | RDS Instance ID | `string` | n/a | yes |
| evaluation\_period | The evaluation period over which to use when triggering alarms. | `string` | `"5"` | no |
| prefix | Alarm Name Prefix | `string` | `""` | no |
| statistic\_period | The number of seconds that make each statistic period. | `string` | `"60"` | no |

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
