terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

// CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_too_high" {
  count               = var.create_high_cpu_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-highCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.cpu_utilization_too_high_threshold
  alarm_description   = "Average database CPU utilization is too high."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_too_low" {
  count               = var.create_low_cpu_credit_alarm ? length(regexall("(t2|t3|t4g)", var.db_instance_class)) > 0 ? 1 : 0 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-lowCPUCreditBalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.cpu_credit_balance_too_low_threshold
  alarm_description   = "Average database CPU credit balance is too low, a negative performance impact is imminent."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = var.tags
}

// Disk Utilization
resource "aws_cloudwatch_metric_alarm" "disk_queue_depth_too_high" {
  count               = var.create_high_queue_depth_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-highDiskQueueDepth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.disk_queue_depth_too_high_threshold
  alarm_description   = "Average database disk queue depth is too high, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "disk_free_storage_space_too_low" {
  count               = var.create_low_disk_space_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-lowFreeStorageSpace"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.disk_free_storage_space_too_low_threshold
  alarm_description   = "Average database free storage space is too low and may fill up soon."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "disk_burst_balance_too_low" {
  count               = var.create_low_disk_burst_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-lowEBSBurstBalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "BurstBalance"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.disk_burst_balance_too_low_threshold
  alarm_description   = "Average database storage burst balance is too low, a negative performance impact is imminent."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = var.tags
}

// Memory Utilization
resource "aws_cloudwatch_metric_alarm" "memory_freeable_too_low" {
  count               = var.create_low_memory_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-lowFreeableMemory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.memory_freeable_too_low_threshold
  alarm_description   = "Average database freeable memory is too low, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_swap_usage_too_high" {
  count               = var.create_swap_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-highSwapUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.memory_swap_usage_too_high_threshold
  alarm_description   = "Average database swap usage is too high, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
  tags = var.tags
}

// Connection Count
resource "aws_cloudwatch_metric_alarm" "connection_count_anomalous" {
  count               = var.create_anomaly_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-anomalousConnectionCount"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = var.evaluation_period
  threshold_metric_id = "e1"
  alarm_description   = "Anomalous database connection count detected. Something unusual is happening."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, ${var.anomaly_band_width})"
    label       = "DatabaseConnections (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "DatabaseConnections"
      namespace   = "AWS/RDS"
      period      = var.anomaly_period
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = var.db_instance_id
      }
    }
  }
  tags = var.tags
}

// [postgres, aurora-postgres] Early Warning System for Transaction ID Wraparound
// more info - https://aws.amazon.com/blogs/database/implement-an-early-warning-system-for-transaction-id-wraparound-in-amazon-rds-for-postgresql/
resource "aws_cloudwatch_metric_alarm" "maximum_used_transaction_ids_too_high" {
  count               = contains(["aurora-postgresql", "postgres"], var.engine) ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-maximumUsedTransactionIDs"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "MaximumUsedTransactionIDs"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.maximum_used_transaction_ids_too_high_threshold
  alarm_description   = "Nearing a possible critical transaction ID wraparound."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok
}

# SOC2 requirements
resource "aws_cloudwatch_metric_alarm" "read_iops_too_high" {
  count               = var.create_read_iops_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-read-iops-too-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.read_iops_too_high_threshold
  alarm_description   = "Average Read IO over last ${(var.evaluation_period * var.statistic_period / 60)} minutes too high, performance may suffer"
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "write_iops_too_high" {
  count               = var.create_write_iops_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-write-iops-too-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "WriteIOPS"
  namespace           = "AWS/RDS"
  period              = var.statistic_period
  statistic           = "Average"
  threshold           = var.write_iops_too_high_threshold
  alarm_description   = "Average Write IO over last ${(var.evaluation_period * var.statistic_period / 60)} minutes too high, performance may suffer"
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}


resource "aws_cloudwatch_metric_alarm" "trx_rseg_history_len" {
  count               = var.create_trx_rseg_history_len_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-trx-rseg-history-len-too-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  threshold           = var.trx_rseg_history_len_too_high_threshold
  alarm_description   = "Rseg History Length over last ${var.statistic_period} seconds too high, performance may suffer"

  metric_query {
    id          = "e1"
    expression  = "DB_PERF_INSIGHTS('RDS', '${var.db_instance_resource_id}' , 'db.Transactions.trx_rseg_history_len.avg')"
    label       = "db.Transactions.trx_rseg_history_len"
    return_data = "true"
    period      = var.statistic_period
  }

  alarm_actions = var.actions_alarm
  ok_actions    = var.actions_ok
}

resource "aws_cloudwatch_metric_alarm" "innodb_row_lock_time" {
  count               = var.create_innodb_row_lock_time_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-innodb-row-lock-time-too-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  threshold           = var.innodb_row_lock_time_too_high_threshold
  alarm_description   = "Row Lock Time over last ${var.statistic_period} seconds too high, performance may suffer"

  metric_query {
    id          = "e1"
    expression  = "DB_PERF_INSIGHTS('RDS', '${var.db_instance_resource_id}' , 'db.Locks.Innodb_row_lock_time.avg')"
    label      = "db.Locks.Innodb_row_lock_time"
    return_data = "true"
    period      = var.statistic_period
  }

  alarm_actions = var.actions_alarm
  ok_actions    = var.actions_ok
}


#db.Cache.innoDB_buffer_pool_hits.avg



resource "aws_cloudwatch_metric_alarm" "innodb_buffer_pool_hits" {
  count               = var.create_innodb_buffer_pool_hits_alarm ? 1 : 0
  alarm_name          = "${var.prefix}rds-${var.db_instance_id}-innodb-buffer-pool-hits-too-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  threshold           = var.innodb_buffer_pool_hits_too_high_threshold
  alarm_description   = "Buffer Pool Hits over last ${var.statistic_period} seconds too high, performance may suffer"

  metric_query {
    id          = "e1"
    expression  = "DB_PERF_INSIGHTS('RDS', '${var.db_instance_resource_id}' , 'db.Cache.innoDB_buffer_pool_hits.avg')"
    label      = "db.Cache.innoDB_buffer_pool_hits"
    return_data = "true"
    period      = var.statistic_period
  }

  alarm_actions = var.actions_alarm
  ok_actions    = var.actions_ok
}
