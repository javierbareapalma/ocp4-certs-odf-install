# 1.

```bash
oc apply -f operator-cert-manager-declaration.yaml

sleep 5

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

```bash
cd bookimport-app

oc apply -f operator-cert-manager-declaration.yaml
```