# Experiment: Persistent data with named volumes

```bash
sudo docker volume create lab-data
sudo docker run --rm -v lab-data:/data alpine sh -c 'echo "persistent data" > /data/notes.txt'
sudo docker run --rm -v lab-data:/data alpine cat /data/notes.txt
sudo docker volume inspect lab-data
```

## Expected result

The final command prints `persistent data`, even though the writing container has already been removed.

Cleanup:

```bash
sudo docker volume rm lab-data
```
