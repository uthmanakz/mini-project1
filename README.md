# mini-project1
## 3 tier application installation (2 forntend, 2 backend, 2 databases)
## Installation
- export AWS_ACCESS_KEY_ID=, export AWS_SECRET_ACCESS_KEY=
- terraform plan -var-file mini-project1.tfvars
- terraform apply -var-file mini-project1.tfvars
- ssh into machines with ssh key and ip address-outputted when provisioned
- nc command can be used to see accesiblity of port with telnet command on local machine