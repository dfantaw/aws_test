# The configuration for the `remote` backend.
    terraform {
      backend "remote" {
        # The name of your Terraform Cloud organization.
        organization = "aws_test_organization_for_react_dotnet"

        # The name of the Terraform Cloud workspace to store Terraform state files in.
        workspaces {
          name = "aws_test-2"
        }
      }
    }