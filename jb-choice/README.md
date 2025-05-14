# 1.

```bash
oc apply -f operator-cert-manager-declaration.yaml

oc apply -k cert-manager-monitoring
```

# 2. CR certmanager/cluster

```bash
oc apply -f certmanager-cluster.yaml
```

# 3. Create all the stuff.

Run `progressing-commands.sh` script. 
Create CR ClusterIssuer of Let's Encrypt type.
Create CR Certificate for ns openshift-ingress.

# 4.

