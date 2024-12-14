# variables.tf
variable "project_id" {
    default = "codimite-assignment-444413"
}
variable "region" {
  default = "us-central1"
}
variable "subnet_cidr" {
  default = "10.0.0.0/16"
}
variable "terraform_sa_email" {
    default = "github-actions@codimite-assignment-444413.iam.gserviceaccount.com"
}


