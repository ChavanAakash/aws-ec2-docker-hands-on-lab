# Experiment: User-defined Docker network

```bash
sudo docker network create lab-net
sudo docker run -d --name lab-web --network lab-net nginx:alpine
sudo docker run --rm --network lab-net alpine wget -qO- http://lab-web
sudo docker rm -f lab-web
sudo docker network rm lab-net
```

## What to observe

The temporary Alpine container can reach Nginx using the container name `lab-web` because both containers are attached to the same user-defined network.
