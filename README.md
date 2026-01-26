# kube-utils

Some utility files to develop on a Kubernetes cluster.

## Prepare Docker image and push to Dockerhub

Here we only build using the `docker/default/Dockerfile` (suitable for Kubernetes cluster). Change the username, repo, and tag inside the Dockerfile or via build args as shown below:

```bash
docker login
docker build -t human0815/cuda-conda:12.8.1-v4 docker/default
docker push human0815/cuda-conda:12.8.1-v4
```

You need to customize the build command with build args, the first two are important if your are building from the official work network (not all others shown, see Dockerfile):

```bash
docker build -t human0815/cuda-conda:12.8.1-v4 --build-arg http_proxy=http://proxy1.zmnh.uni-hamburg.de:8888 --build-arg https_proxy=http://proxy1.zmnh.uni-hamburg.de:8888 --build-arg CONDA_PATH=/path/to/desired/conda/env/location
```

If necessary, you can tag your image using this command:

```bash
docker tag human0815/repo-name:latest human0815/repo-name:new
docker rmi human0815/repo-name:latest
```

## Create Statefulset in Kubernetes

To create a statefulset run (you need to adapt the mount paths in the file, according to your username etc.):

**Make sure to replace all mentions of darius inside the file!**

```bash
kubectl apply -f ./kube/latest/statefulset_small.yaml
```

To setup a persistent volume claim for the current user, run:

```bash
kubectl apply -f ./kube/pvc.yaml
```

To setup a config map for any user, run:

```bash
kubectl apply -f ./kube/config_map.yaml
```
