terraform {
  backend "gcs" {
    bucket = "project-b0c0dfc1-64aa-430f-a96-tfstate"
    prefix = "project04/java-app"
  }
}
