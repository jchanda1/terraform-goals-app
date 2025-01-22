variable "cluster_name" {
    description = "name of the cluster"
    type = string
    default = "default-name"
}

variable "task_def_family_name" {
    description = "task definition family name"
    type = string
    default = "default-task-def-name"
}

variable "service_name" {
    description = "name for the service"
    type = string
    default = "default-service-name"
}