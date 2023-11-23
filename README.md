# kube-utils

Some utility files to develop on a kubernetes cluster.

## Prepare Docker image and push to Dockerhub

```bash
docker login
docker build -t human0815/repo-name:latest .
docker push human0815/repo-name:latest
```

If necessary you can tag your image using this command:
```bash
docker tag human0815/repo-name:latest human0815/repo-name:new
docker rmi human0815/repo-name:latest
```

## Usage
To setup a persistent volume claim for the current user, run:
```bash
kubectl apply -f ./kube/pvc.yaml
```

To setup a config map for any user, run:
```bash
kubectl apply -f ./kube/config_map.yaml
```

To setup a deployment for the current user, run:
```bash
kubectl apply -f ./kube/deployment.yaml
```