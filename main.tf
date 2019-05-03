# Source the data from hashijit/vault workspace
data "terraform_remote_state" "vault" {
  backend = "remote"
  config {
    organization = "hashijit"
    workspaces {
      name = "vault"
    }
  }
}

provider "vault" {
  address         = "http://${data.terraform_remote_state.vault.vault_lb_dns}:8200"
}

data "vault_aws_access_credentials" "creds" {
  backend = "aws"
  role    = "tfe"
}

provider "aws" {
  access_key = "${data.vault_aws_access_credentials.creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.creds.secret_key}"
  region     = "us-east-1"
}

resource "aws_instance" "ubuntu" {
  count             = 1
  ami               = "ami-2e1ef954"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"

  tags {
    Owner = "ranjit"
    TTL   = "1d"
  }
}
