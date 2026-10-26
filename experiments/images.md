# Experiment: Build and inspect an image

```bash
sudo docker build -t ec2-docker-hello:v1 .
sudo docker images
sudo docker image inspect ec2-docker-hello:v1
sudo docker history ec2-docker-hello:v1
sudo docker run --rm ec2-docker-hello:v1
```

## Challenge

Change one output line in `hello.sh`, rebuild as `ec2-docker-hello:v2`, and compare the image tags.
