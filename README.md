# AWS EC2 Docker Hands-On Lab

A practical Docker learning project designed to be run on an **Ubuntu EC2 instance**. It covers Docker installation, images, containers, port mapping, logs, volumes, networks, and a small Nginx web server.

> This repository contains lab instructions and scripts. Run commands on your own AWS account and review AWS charges before creating resources.

## Architecture

```text
Your laptop (Git Bash)
       |
       | SSH (TCP 22, restrict to your IP)
       v
AWS EC2 - Ubuntu
       |
       +-- Docker Engine
       |     +-- hello-lab container
       |     +-- Nginx container (host port 8080 -> container port 80)
       |     +-- Volume persistence lab
       |     +-- Custom network lab
       |
       +-- Git repository cloned from GitHub
```

## What you'll practice

- Connect to an Ubuntu EC2 instance using SSH
- Install and verify Docker Engine
- Run and inspect containers
- Build a custom Docker image from a Dockerfile
- Publish a web server port
- Persist data with a Docker volume
- Create a user-defined Docker network
- Capture evidence and document troubleshooting

## Prerequisites

- AWS account and basic EC2 knowledge
- An Ubuntu EC2 instance (Ubuntu 22.04 or 24.04 LTS recommended)
- A key pair (`.pem`) downloaded when the instance was created
- Git for Windows / Git Bash on your laptop
- GitHub account

## 1. Create the EC2 instance

In AWS Console, open **EC2 → Launch instance**:

1. Name: `docker-lab-ubuntu`
2. AMI: Ubuntu Server 22.04 LTS or 24.04 LTS
3. Instance type: a small instance suitable for a learning lab, such as `t3.micro` if available for your account/region and eligible for your pricing plan
4. Create or select a key pair and safely store the `.pem` file
5. Security group inbound rules:
   - SSH, TCP 22: **My IP** only
   - Custom TCP, port 8080: **My IP** only (needed for the Nginx test)
6. Leave other inbound ports closed unless you have a specific reason.
7. Launch the instance.

AWS pricing and free-tier eligibility vary. Stop or terminate the instance when you're done; stopping may not remove all charges (for example, storage or reserved public IPv4 charges may still apply).

## 2. Connect from Git Bash

In Git Bash, move to the folder containing your key. Replace the sample values:

```bash
chmod 400 my-ec2-key.pem
ssh -i my-ec2-key.pem ubuntu@EC2_PUBLIC_IP
```

Replace `my-ec2-key.pem` with your key filename and `EC2_PUBLIC_IP` with the instance's public IPv4 address or DNS name.

If SSH times out, check that the instance is running and that the security group allows SSH from your current public IP. Never upload your `.pem` key to GitHub.

## 3. Install Docker on Ubuntu EC2

After connecting to the instance over SSH, run:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo docker run hello-world
```

The commands use Docker's official Ubuntu repository. See Docker's official installation documentation if repository setup differs for your Ubuntu release.

For this lab, use `sudo docker ...` commands. You can optionally configure non-root Docker access later, but membership in the `docker` group effectively grants root-level privileges.

## 4. Get this project onto EC2

Option A: clone after pushing the project to GitHub:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/aws-ec2-docker-hands-on-lab.git
cd aws-ec2-docker-hands-on-lab
```

Option B: if you already copied the folder to the instance, `cd` into that folder.

## 5. Build and run your custom image

```bash
sudo docker build -t ec2-docker-hello:v1 .
sudo docker run --name hello-lab ec2-docker-hello:v1
sudo docker ps -a
sudo docker logs hello-lab
sudo docker rm hello-lab
```

Expected output includes:

```text
Hello from Docker running on AWS EC2 Ubuntu!
This image was built from my own Dockerfile.
```

The container exits after printing the messages. That is expected.

## 6. Run Nginx and test port mapping

```bash
sudo docker run -d --name nginx-lab --restart unless-stopped -p 8080:80 nginx:alpine
sudo docker ps
curl http://localhost:8080
```

From your laptop browser, open:

```text
http://EC2_PUBLIC_IP:8080
```

Replace `EC2_PUBLIC_IP` with your instance's public IPv4 address. The EC2 security group must allow TCP 8080 from your IP. Do not open this port to the whole internet unless you intentionally want public access.

Clean up:

```bash
sudo docker stop nginx-lab
sudo docker rm nginx-lab
```

## 7. Practice persistent data with a volume

```bash
sudo docker volume create lab-data
sudo docker run --rm -v lab-data:/data alpine sh -c 'echo "Saved on $(date -u)" > /data/notes.txt'
sudo docker run --rm -v lab-data:/data alpine cat /data/notes.txt
sudo docker volume inspect lab-data
```

The second container can read the file written by the first because both use the same named volume.

Cleanup when you no longer need the lab data:

```bash
sudo docker volume rm lab-data
```

## 8. Practice a user-defined network

```bash
sudo docker network create lab-net
sudo docker run -d --name lab-web --network lab-net nginx:alpine
sudo docker run --rm --network lab-net alpine wget -qO- http://lab-web
sudo docker rm -f lab-web
sudo docker network rm lab-net
```

The temporary Alpine container requests the Nginx page by container name over the user-defined network.

## 9. Useful troubleshooting commands

```bash
sudo docker ps -a
sudo docker images
sudo docker logs CONTAINER_NAME
sudo docker inspect CONTAINER_NAME
sudo docker system df
sudo systemctl status docker --no-pager
sudo journalctl -u docker --no-pager -n 50
```

Common issues:

- **SSH timeout:** check EC2 state, public IP, route table, and inbound TCP 22 rule.
- **Website not reachable:** check `docker ps`, `curl http://localhost:8080`, and inbound TCP 8080 from your IP.
- **Port already allocated:** choose another host port, e.g. `-p 8081:80`.
- **Permission denied on Docker socket:** use `sudo docker ...` for this lab.
- **No public IPv4 address:** assign/review network connectivity or use an appropriate private access method.

## 10. GitHub evidence checklist

After running the labs, add your own screenshots to `screenshots/`:

- [ ] Docker version and `sudo docker run hello-world`
- [ ] Successful `docker build`
- [ ] `sudo docker ps -a` showing your test container
- [ ] Nginx page loaded from the EC2 public address
- [ ] Volume persistence test output
- [ ] Network connectivity test output

Do not include private keys, AWS credentials, access tokens, or sensitive account details in screenshots.

## Cleanup

Stop and remove lab containers and any resources you created. Then stop or terminate the EC2 instance when finished. Check the AWS Billing console to confirm whether any billable resources remain.


## Author

Aakash Chavan
