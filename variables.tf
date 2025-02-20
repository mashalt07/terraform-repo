variable "app_name" {
    type = string 
    description = "The name of app"
    default = "maltamash"
}

variable "db_password" {
    type = string
    description = "DB password"
    sensitive = true
}