# Stirling-PDF on AWS (EC2)

## What is Stirling-PDF?
Stirling-PDF is a locally hosted web application that allows you to perform various operations on PDF files (merge, split, convert, compress, OCR, and more) through a browser UI.

## What the user-data script does
The scripts/user-data-stirling-pdf.sh script runs on the first boot of the EC2 instance and:
- Updates system packages
- Installs Docker
- Enables and starts the Docker service
- Creates a persistent data/config directory for Stirling-PDF
- Runs the Stirling-PDF Docker container:
  - Exposes the web UI on port 8080 (-p 8080:8080)
  - Mounts a volume for persistent configs/data (-v <host-dir>:/configs)
  - Uses a restart policy (--restart unless-stopped) so the container comes back after reboot

## How to run / access the service
1) Deploy with Terraform:
terraform init
terraform apply

2) View Terraform outputs (public IP / URL):
terraform output


3) Open the Stirling-PDF Web UI in your browser:
http://<EC2_PUBLIC_IP>:8080


