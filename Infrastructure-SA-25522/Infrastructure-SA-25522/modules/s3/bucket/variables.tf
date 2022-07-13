variable "name" {
  description = "Name of the bucket."
}

/*variable "versioning" {
  description = "Versioning enabled true/false."
}*/

variable "acl" {
  description = "ACL of the bucket."
  default     = "private"
}

variable "tags" {
  description = "Tags of the bucket."
  default = {
    Repository = "https://github.com/VacaAPI/Infrastructure/tree/master/modules/s3/bucket"
  }
}

variable "encryption" {
  description = "Encryption enabled true/false. Ignored if encryption_key defined."
  default     = false
}

variable "encryption_key" {
  description = "AWS KMS key used for server-side encryption."
  default     = null
}

variable "object_lock_configuration" {
  description = "Object lock config for S3 bucket"
  default     = {}
}

variable "logging_bucket" {
  description = "AWS S3 bucket for loggin access."
  default     = null
}

variable "lifecycle_rules" {
  description = "List of S3 objects lifecycle rules."
  default     = []
}

variable "public_access_blocking" {
  description = "Definition of public access blocking."
  default     = {}
}
