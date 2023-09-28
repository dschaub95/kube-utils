# kube-utils

Some utility files to develop on a kubernetes cluster.

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