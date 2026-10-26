#!/bin/sh
set -eu
echo "Hello from Docker running on AWS EC2 Ubuntu!"
echo "This image was built from my own Dockerfile."
echo "Container hostname: $(hostname)"
