# Create a new VM in Azure using Terraform
This repo contains the code for provisioning a new VM in Microsoft Azure using Terraform and then logging in it using SSH.



## Prerequisites
- Microsoft Azure account  
If you don't have an account then signup go for free using the [Signup to Microsoft Azure](https://azure.microsoft.com/en-in/free/open-source) link

- Azure CLI on your host machine  
Azure CLI is a set of commands used to create and manage Azure resources.
Install Azure CLI using the [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) link  

- Terraform on your host machine  
Terrform is an Infrastructure as Code (IaC) tool used for provisioning resources on the cloud.  
Installation guide => [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


## Steps to run the code from this repository
__1. Login into the Azure account__  
Open the terminal and execute the following command:  
`az login`  
If the Azure cli is installed properly then you will be redirected to a web page to login into your Azure account

__2. Clone this repository__  
Open the command prompt and execute the following command:  
`git clone https://github.com/VishalLokam/Terraform-Azure-Miniproject.git`  
This will clone the project repo inside a new folder named *Terraform-Azure-Miniproject*

__3. Create a new file to initialize variables__  
Create a new file name `terraform.tfvars` and copy paste the below code into that file  
```
# Add a prefix before every resource name eg:- dev_env_resource_group
prefix = "dev_env"

# Set the location of the resources to centralindia
location = "centralindia"

# Set the username of the vm
username = "azureadmin"
```

__4. Execute the Terraform code__    
Open the terminal and run the below set of command  
- Initialise Terraform providers  
    `terraform init` 

- See what resources will be provisioned  
    `terraform plan`  
    	:heavy_plus_sign: : a green plus will show the resources that will be created. If everything looks fine then proceed  

- Run the Terraform script  
    `terraform apply -auto-approve`  
    Wait for the execution to be completed. Once execution is done, you will find a new file named *private_ssh_key_azure.pem* created in the same folder. This is the private key which will help in connecting to the vm.

- Get the public IP address assigned to the VM  
    `terraform output vm_public_ip`
  Take a note of this Ip address. It will be use full in the next step
 > [!WARNING]  
  > Private key created after executing the terraform script doesn't work out of the box when trying to SSH into the VM on Windows host.  
  > - One workaround that works is to run __bash__ terminal from VS code and then execute commands in it or atleast the SSH command.  
  > - Or change the file permissions manually from _Windows Explorer_. For more info Checkout the first solution [Windows SSH: Permissions for 'private-key' are too open](https://superuser.com/questions/1296024/windows-ssh-permissions-for-private-key-are-too-open)
  > - No issue if executing on a Linux host or using a terminal like [Hyper](https://hyper.is/)
- Connect to the VM using SSH 
    Run the below command  
    `ssh -i "private_ssh_key_azure.pem" azureadmin@<ip_noted_earlier>`  
    Type *yes* when prompted. You will be logged into the remote VM provisoned on the Microsoft Azure.

__5. Cleanup__  
Run the below command to destroy all the resources created.  
`terraform destroy -auto-approve`








