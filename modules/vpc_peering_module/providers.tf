provider "aws" {
  region = var.region_n_virginia
  alias  = "N-virginia"
}

provider "aws" {
  region = var.region_mumbai
  alias  = "mumbai"
}
