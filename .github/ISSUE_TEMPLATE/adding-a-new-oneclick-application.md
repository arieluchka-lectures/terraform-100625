---
name: Adding a new OneClick Application
about: OneClickApp template
title: 'Adding terraform template for [SERVICE_NAME] '
labels: enhancement
assignees: ''

---

## Deploy [SERVICE_NAME] on AWS


### Setup Checklist
#### 1) Research the Service
- [ ] Find the official Docker image and documentation
- [ ] Get it running locally with `docker run` or `docker compose` (write down the command you used)
- [ ] Document the port(s) it uses: _______ (what you needed to `-p HOST_PORT:CONTAINER_PORT`)
- [ ] Try to find the instance requirements (RAM/storage) in the docs: _______ (this will help you choose the most suitable EC2)

<br>

#### 2) Deploy manually on AWS
- [ ] Create a **VPC**
- [ ] Create a **subnet** + **Internet Gateway** + **Route Table** (make sure to configure the routing table to point 0.0.0.0 to the GW)
- [ ] Create an Elastic IP
- [ ] Create a **NACL** with inbound/outbound rules for your service's ports
- [ ] Create a **Security Group** with inbound rules for your service's ports
- [ ] Launch an **EC2 instance** (Amazon Linux 2023) with:
  - [ ] The security group attached
  - [ ] Enough storage for the service
  - [ ] Connect to the Elastic IP
  - [ ] (Try to choose the most suitable EC2 type, for that specific service)
- [ ] SSM/SSH in, install Docker, and run the service manually 
- [ ] Try to connect to the service with your browser (and debugging/fixing what needed, to get it working)

> [!TIP]
> When figuring out the commands needed to download/install docker and the other programs, write down what worked for you (in a notepad, or straight into the future user_data script)

<br>


#### 3) Writing the terraform configuration
- [ ] Clone the repo and create a new branch
- [ ] Create `010-One_Click_Apps/[service-name]/[your-name]/main.tf`
- [ ] `git add` + `git commit` + `git push`
- [ ] Re-Create your setup for the service in terraform.
- [ ] Write a `script.sh` that will download/install/setup everything in the VM + Pass it with user_data.

> [!TIP]
> Start slow, resource after resource, and `terraform apply` after each one. 
> This will help you verify there are no טעויות נגררות

<br>

####  4) README.md 📄

- [ ] Create a file named `README.md`, and write a summary of what this service is, what your script does and what command is needed to run this service.

<br>

#### 5) Submit PR
- [ ] You know what to do 😎


> [!NOTE]  
> ## Tips and tricks!
> - Use terraform outputs and variables!
> - Break the terraform main file into separate file! (will make it easier on the eyes 👀)
