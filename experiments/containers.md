# Experiment: Container lifecycle

Run these commands on the Ubuntu EC2 instance:

```bash
sudo docker run -d --name web-lab -p 8080:80 nginx:alpine
sudo docker ps
sudo docker ps -a
sudo docker logs web-lab
sudo docker exec -it web-lab sh
```

Inside the container, try `ls` and `exit`.

Then clean up:

```bash
sudo docker stop web-lab
sudo docker rm web-lab
```

## Notes

- `docker ps` lists running containers.
- `docker ps -a` includes stopped containers.
- `docker logs` displays container output.
- `docker exec` runs a command in a running container.
