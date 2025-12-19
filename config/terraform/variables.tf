variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Folder ID"
  type        = string
}

variable "zone" {
  description = "Default availability zone"
  type        = string
}

variable "sa_key_file" {
  description = "Path to service account key file"
  type        = string
}

variable "subnets" {
  description = "Map of subnets"
  type = map(object({
    zone   = string
    cidr   = list(string)
    public = bool
  }))
}
