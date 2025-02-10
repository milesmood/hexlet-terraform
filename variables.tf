variable "db_password" {
  type        = string
  sensitive   = true
}

variable "yc_iam_token" {
  description = "Yandex Cloud authorization token. Use 'yc iam create-token' to receive"
  type        = string
  sensitive   = true
}

variable "yc_token" {
  description = "Yandex Cloud authorization token. Use 'yc iam create-token' to receive"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  type        = string
  sensitive   = true
}

variable "yc_folder_id" {
  type        = string
  sensitive   = true
}

variable "db_name" {
  type        = string
  sensitive   = false
}

variable "db_user" {
  type        = string
  sensitive   = false
}

variable "yc_postgresql_version" {
  type        = string
  sensitive   = false
  default = 15
}