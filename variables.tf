variable "db_instance_id" {
  type        = "string"
  description = "RDS Instance ID"
}

variable "prefix" {
  type        = "string"
  default     = ""
  description = "Alarm Name Prefix"
}

variable "evaluation_period" {
  type        = "string"
  default     = "5"
  description = "The evaluation period over which to use when triggering alarms."
}

variable "statistic_period" {
  type        = "string"
  default     = "60"
  description = "The number of seconds that make each statistic period."
}

variable "anomaly_period" {
  type        = "string"
  default     = "600"
  description = "The number of seconds that make each evaluation period for anomaly detection."
}

variable "actions_alarm" {
  type        = "list"
  default     = []
  description = "A list of actions to take when alarms are triggered. Will likely be an SNS topic for event distribution."
}

variable "actions_ok" {
  type        = "list"
  default     = []
  description = "A list of actions to take when alarms are cleared. Will likely be an SNS topic for event distribution."
}
