### Configure an AWS user for accessing Route 53

#!/bin/bash

set -x

## Env
DIR=$(pwd)

aws iam create-user --user-name route53-openshift

cat << fin > policy.json
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Effect": "Allow",
           "Action": "route53:GetChange",
           "Resource": "arn:aws:route53:::change/*"
       },
       {
           "Effect": "Allow",
           "Action": [
               "route53:ChangeResourceRecordSets",
               "route53:ListResourceRecordSets"
           ],
           "Resource": "arn:aws:route53:::hostedzone/*"
       },
       {
           "Effect": "Allow",
           "Action": [
               "route53:ListHostedZones",
               "route53:ListResourceRecordSets",
               "route53:ListHostedZonesByName"
           ],
           "Resource": "*"
       }
   ]
}
fin

aws iam create-policy --policy-name AllowDNSUpdates --policy-document  file://policy.json

arnpolicytoapply=$(aws iam list-policies --query 'Policies[?PolicyName==`AllowDNSUpdates`].Arn' --output text)

#aws iam list-policies --query 'Policies[?PolicyName==`AllowDNSUpdates`].Arn' --output table
#aws iam list-policies --query 'Policies[?PolicyName==`AllowDNSUpdates`].Arn' --output json
#aws iam list-policies --query 'Policies[?PolicyName==`AllowDNSUpdates`].Arn' --output yaml

aws iam attach-user-policy --policy-arn $arnpolicytoapply --user-name route53-openshift

rm secretos-iam-user-route53-openshift

aws iam create-access-key --user-name route53-openshift --output json | tee -a secretos-iam-user-route53-openshift

echo "AccessKeyId: "
AKI=$(cat secretos-iam-user-route53-openshift | grep "AccessKeyId" | awk -F'"' '{print $4}' )
echo "AccessKeyId: $AKI"
echo "SecretAccessKey: "
SAK=$(cat secretos-iam-user-route53-openshift | grep "SecretAccessKey" | awk -F'"' '{print $4}' )
echo "SecretAccessKey: $SAK"
echo "Base Domain: "
OCPBaseDomain=$(oc get dns.config/cluster -o jsonpath='{.spec.baseDomain}' )
echo "Base Domain: $OCPBaseDomain"

echo "create generic secret" 
oc create secret generic route53-credentials-secrets --from-literal secret-access-key=$SAK --from-literal access-key-id=$AKI -n cert-manager

#exit 

cat clusterissuer-letsencrypt.yaml | \
  CLUSTER_DOMAIN=$(oc get dns.config/cluster -o jsonpath='{.spec.baseDomain}') \
  envsubst | oc apply -f -

sleep 10

cat certificate-ocp-ingress.yaml | \
  CLUSTER_DOMAIN=$(oc get dns.config/cluster -o jsonpath='{.spec.baseDomain}') \
  envsubst | oc apply -f -

sleep 200
