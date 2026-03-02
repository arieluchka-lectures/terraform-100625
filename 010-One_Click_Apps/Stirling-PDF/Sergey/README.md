
Stirling-PDF is a web application that allows you to perform multiple operations on PDF files.

In order to prepare the instaltion app follow next steps:

1. Open Windows PowerShell and clone the repo with the Project by this command:
   git clone https://github.com/arieluchka-lectures/terraform-100625

2. Enter the repo location:
   cd /010-One_Click_Apps/Stirling-PDF/Sergey

3. run both terraform commands:
   terraform init
   terraform apply 
   (terraform init command creates a required terraform files, while terraform apply command creates a AWS VPS with a EC2 instance with public ip and additional resources, in order succeed a proper ssh server connection. 
   Additional used files are: output.tf file, which presents an output of the App login credentials, a public ip and a ssh comand for the server connection. After ssh server connectivity, start_script.sh is running in order to update system packages, installs docker, creates app directory, installs git, download docker compose cli-plugins and at last, run a docker compose up command which downloads the Apps image, creates container and raise the Stirling-PDF App)

4. A login command is:
   http://localhost:9080/login (unstead of localhost, use the public ip created via AWS and presented at the PowerShell output)


Default Login Credentials to the App:

Username: admin
Password: stirling

(After that set a new password)