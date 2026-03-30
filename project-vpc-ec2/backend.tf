terraform {
    backend "s3" {
        bucket = "cm-bucket-terraform"
        key    = "prod/terraform.tfstate"
        encrypt = true
        dynamodb_table = "demo-terraform-db"
        region = "ap-south-1"
    }
}