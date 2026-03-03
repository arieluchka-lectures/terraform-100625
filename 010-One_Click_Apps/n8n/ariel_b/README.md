This terraform configuration builds an ec2 instance that runs the n8n web service.

n8n is a service that lets it's users build automations and run them through a simple workflow.

It's key capabilities are multiple code languages, a visual interface, AI agent workflows and an active community with constant integrations and ready-to-use templates.

This terraform build includes a script that is inserted in the ec2's user_data on creation that installs Docker and runs the container with the n8n running.

We first donwload Docker on the instance using this command:
- sudo yum install docker -y
The script then makes sure the Docker daemon is running and working with the command:
- sudo systemctl start docker
The script then creates the n8n volume and runs the service:
- sudo docker volume create n8n_data
- sudo docker run -d --name n8n -p 5678:5678 -e N8N_HOST=0.0.0.0 -e N8N_PORT=5678 -e      N8N_PROTOCOL=http -e N8N_SECURE_COOKIE=false -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n 

The docker run command runs detached (-d), under the name n8n and maps the port 5678 for the container which is the port the n8n service uses.
We set the following environment variables:
- N8N_HOST=0.0.0.0 - allows all network interfaces to connect.
- N8N_PORT=5678 - the HTTP port n8n listens on.
- N8N_PROTOCOL=http - the protocol used to reach n8n.
- N8N_SECURE_COOKIE=false - disables secure cookies (message pops up when entering the web page).

The final part of the docker run command is using the volume that we created:
- n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n 
