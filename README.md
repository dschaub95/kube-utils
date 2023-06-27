# kube-utils

Some utility files to develop on a kubernetes cluster.

## Usage
To setup a persistent volume claim for the current user, run:
```bash
kubectl apply -f ./kube/pvc.yaml
```

To setup a pod for the current user, run:
```bash
kubectl apply -f ./kube/pod.yaml
```

Here apply also updates the pod if it already exists.