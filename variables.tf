variable "db_instance_id" {
  type        = string
  description = "RDS Instance ID"
}

variable "prefix" {
  type        = string
  default     = ""
  description = "Alarm Name Prefix"
}

variable "evaluation_period" {
  type        = string
  default     = "5"
  description = "The evaluation period over which to use when triggering alarms."
}

variable "statistic_period" {
  type        = string
  default     = "60"
  description = "The number of seconds that make each statistic period."
}

variable "create_high_cpu_alarm" {
  type        = bool
  default     = true
  description = "Whether or not to create the high cpu alarm.  Default is to create it (for backwards compatible support)"
}

variable "create_low_cpu_credit_alarm" {
  type        = bool
  default     = true
  description = "Whether or not to create the low cpu credit alarm.  Default is to create it (for backwards compatible support)"
}

variable "create_high_queue_depth_alarm" {
  type        = bool
  default     = true
  description = "Whether or not to create the high queue depth alarm.  Default is to create it (for backwards compatible support)"
}

variable "create_low_disk_space_alarm" {
  type        = bool
  default     = true
  description = "Whether or not to create the low disk space alarm.  Default is to create it (for backwards compatible support)"
}

variable "create_low_disk_burst_alarm" {
  type        = bool
  default     = true
  description = "Whether or not to create the low disk burst alarm.  Default is to create it (for backwards compatible support)"
}

variable "create_low_memory_alarm" {
  type        = bool
  default     = true
  description = "Whether or not to create the low memory free alarm.  Default is to create it (for backwards compatible support)"
}

variable "create_swap_alarm" {
  type        = bool
  default     = true
  description = "Whether or not to create the high swap usage alarm.  Default is to create it (for backwards compatible support)"
}

variable "create_anomaly_alarm" {
  type        = bool
  default     = true
  description = "Whether or not to create the fairly noisy anomaly alarm.  Default is to create it (for backwards compatible support), but recommended to disable this for non-production databases"
}

variable "create_read_iops_alarm" {
  type        = bool
  default     = true
  description = "Whether or not to create the Read IOPS too high alarm. Default is to create it."
}

variable "create_write_iops_alarm" {
  type        = bool
  default     = true
  description = "Whether or not to create the Write IOPS too high alarm. Default is to create it."
}

variable "anomaly_period" {
  type        = string
  default     = "600"
  description = "The number of seconds that make each evaluation period for anomaly detection."
}

variable "anomaly_band_width" {
  type        = string
  default     = "2"
  description = "The width of the anomaly band, default 2.  Higher numbers means less sensitive."
}

variable "actions_alarm" {
  type        = list(any)
  default     = []
  description = "A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution."
}

variable "actions_ok" {
  type        = list(any)
  default     = []
  description = "A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution."
}

variable "cpu_utilization_too_high_threshold" {
  type        = string
  default     = "90"
  description = "Alarm threshold for the 'highCPUUtilization' alarm"
}

variable "cpu_credit_balance_too_low_threshold" {
  type        = string
  default     = "100"
  description = "Alarm threshold for the 'lowCPUCreditBalance' alarm"
}

variable "disk_queue_depth_too_high_threshold" {
  type        = string
  default     = "64"
  description = "Alarm threshold for the 'highDiskQueueDepth' alarm"
}

variable "disk_free_storage_space_too_low_threshold" {
  type        = string
  default     = "10000000000" // 10 GB
  description = "Alarm threshold for the 'lowFreeStorageSpace' alarm"
}

variable "disk_burst_balance_too_low_threshold" {
  type        = string
  default     = "100"
  description = "Alarm threshold for the 'lowEBSBurstBalance' alarm"
}

variable "memory_freeable_too_low_threshold" {
  type        = string
  default     = "256000000" // 256 MB
  description = "Alarm threshold for the 'lowFreeableMemory' alarm"
}

variable "memory_swap_usage_too_high_threshold" {
  type        = string
  default     = "256000000" // 256 MB
  description = "Alarm threshold for the 'highSwapUsage' alarm"
}

variable "read_iops_too_high_threshold" {
  type        = string
  default     = "100"
  description = "Alarm threshold for the 'read-iops-too-high' alarm"
}

variable "write_iops_too_high_threshold" {
  type        = string
  default     = "10000"
  description = "Alarm threshold for the 'write-iops-too-high' alarm"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to attach to each alarm"
}

variable "db_instance_class" {
  type        = string
  description = "The rds instance class, e.g. db.t3.medium"
}

variable "engine" {
  type        = string
  description = "The RDS engine being used. Used for postgres or mysql specific alarms"
  default     = ""
}

variable "maximum_used_transaction_ids_too_high_threshold" {
  type        = string
  default     = "1000000000" // 1 billion. Half of total.
  description = "Alarm threshold for the 'maximumUsedTransactionIDs' alarm"
}
