
root@kube-master:/home/devops/.kube# kubectl create ns prod, kubectl create ns qa , kubectl create ns dev
namespace/prod created

mkdir -p /home/users/certs
cd /home/users/certs

#step 1 
Create a private key for your user. In this example, we will name the file prod-user.key:

openssl genrsa -out prod-user.key 2048
openssl genrsa -out qa-user.key 2048
openssl genrsa -out dev-user.key 2048

#step 2
Create a certificate sign request prod-user.csr using the private key we just created (prod-user.key in this example). Make sure you specify your username and group in the -subj section (CN is for the username and O for the group).

openssl req -new -key prod-user.key -out prod-user.csr -subj "/CN=prod-user/O=devops"
openssl req -new -key qa-user.key -out qa-user.csr -subj "/CN=qa-user/O=devops"
openssl req -new -key dev-user.key -out dev-user.csr -subj "/CN=dev-user/O=devops"

#Step 3 
#Locate Kubernetes cluster certificate authority (CA). This will be responsible for approving the request and generating the necessary certificate to access the cluster API. Its location is normally /etc/kubernetes/pki/ca.crt


openssl x509 -req -in prod-user.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out prod-user.crt -days 1000 ; ls -ltr
openssl x509 -req -in dev-user.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out dev-user.crt -days 1000 ; ls -ltr
openssl x509 -req -in qa-user.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out qa-user.crt -days 1000 ; ls -ltr

#Step 4
#Generate the final certificate prod-user.crt by approving the certificate sign request, prod-user.csr, we made earlier.

openssl x509 -req -in prod-user.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out prod-user.crt -days 1000 ; ls -ltr
openssl x509 -req -in qa-user.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out qa-user.crt -days 1000 ; ls -ltr
openssl x509 -req -in dev-user.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out dev-user.crt -days 1000 ; ls -ltr

#Step 5  https://172.17.0.40:6443
Create kubeconfig file for the prod-user
Add cluster details to configuration file:
kubectl config --kubeconfig=k8s-user.conf set-cluster production --server=https://172.31.4.237:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt

#Step 6 
Add user details to your configuration file:
kubectl config --kubeconfig=k8s-user.conf set-credentials prod-user --client-certificate=/home/users/certs/prod-user.crt --client-key=/home/users/certs/prod-user.key
kubectl config --kubeconfig=k8s-user.conf set-credentials qa-user --client-certificate=/home/users/certs/qa-user.crt --client-key=/home/users/certs/qa-user.key
kubectl config --kubeconfig=k8s-user.conf set-credentials dev-user --client-certificate=/home/users/certs/dev-user.crt --client-key=/home/users/certs/dev-user.key

#Step 7 
Add context details to your configuration file:

kubectl config --kubeconfig=k8s-user.conf set-context prod --cluster=production --user=prod-user
kubectl config --kubeconfig=k8s-user.conf set-context dev --cluster=production --user=dev-user
kubectl config --kubeconfig=k8s-user.conf set-context qa --cluster=production  --user=qa-user

#Step 8 
Set prod context for use:
#kubectl config --kubeconfig=k8s-user.conf get-contexts
kubectl config --kubeconfig=k8s-user.conf use-context prod

```
controlplane $ kubectl config --kubeconfig=k8s-user.conf get-contexts
CURRENT   NAME   CLUSTER      AUTHINFO    NAMESPACE
          dev    production   dev-user    prod
*         prod   production   prod-user   prod
          qa     production   qa-user     prod
```

kubectl --kubeconfig k8s-user.conf version --short



#Step 9 

Providing the Authorization to prod-user
kubectl create role dev-read-only-role --verb=get,list,watch --resource=pods,deployment,services,replicasets --namespace=dev
kubectl create role qa-role --verb=get,list,watch,create --resource=pods,deployment,services,replicasets --namespace=qa
kubectl create role prod-role --verb="*" --resource=*.* --namespace=prod 
#Binding 
kubectl create rolebinding dev-user-role-binding --role=dev-read-only-role  --user dev-user --namespace=dev
kubectl create rolebinding qa-user-role-binding --role=qa-role --user qa-user --namespace=qa
kubectl create rolebinding prod-user-role-binding --role=prod-role  --user prod-user --namespace=prod


controlplane $ kubectl config --kubeconfig=k8s-user.conf use-context dev
Switched to context "dev".
controlplane $ kubectl config --kubeconfig=k8s-user.conf get-contexts
CURRENT   NAME   CLUSTER      AUTHINFO    NAMESPACE
*         dev    production   dev-user    
          prod   production   prod-user   
          qa     production   qa-user     
controlplane $ kubectl get pods --kubeconfig=k8s-user.conf  -n dev
No resources found in dev namespace.

# kubectl auth can-i run pods --as dev-user -n prod 


#kubectl auth can-i drain nodes --as prod-user 


Clusterole: and binding 
#kubectl create clusterrole mycluster-role-read-only-admin --verb=list,get,create,delete --resource=nodes
#kubectl create clusterrolebinding mycluster-role-binding --clusterrole=mycluster-role-read-only-admin --user=prod-user
#kubectl auth can-i list nodes  --as prod-user  -n dev





apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: prod
  name: dev-user-role
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]


apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: prod
  name: qa-user-role
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["run", "logs", "run", "get", "watch"]


apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: prod
  name: prod-user-role
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["delete", "run", "logs", "run", "get", "watch"]


apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "dave" to read secrets in the "development" namespace.
# You need to already have a ClusterRole named "secret-reader".
kind: RoleBinding
metadata:
  name: dev-user-rolebinding
  #
  # The namespace of the RoleBinding determines where the permissions are granted.
  # This only grants permissions within the "development" namespace.
  namespace: prod
subjects:
- kind: User
  name: dev-user # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name:  dev-user-role
  apiGroup: rbac.authorization.k8s.io


apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "dave" to read secrets in the "development" namespace.
# You need to already have a ClusterRole named "secret-reader".
kind: RoleBinding
metadata:
  name: qa-user-rolebinding
  #
  # The namespace of the RoleBinding determines where the permissions are granted.
  # This only grants permissions within the "development" namespace.
  namespace: prod
subjects:
- kind: User
  name: qa-user # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name:  qa-user-role
  apiGroup: rbac.authorization.k8s.io

apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "dave" to read secrets in the "development" namespace.
# You need to already have a ClusterRole named "secret-reader".
kind: RoleBinding
metadata:
  name: prod-user-rolebinding
  #
  # The namespace of the RoleBinding determines where the permissions are granted.
  # This only grants permissions within the "development" namespace.
  namespace: prod
subjects:
- kind: User
  name: prod-user # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name:  prod-user-role
  apiGroup: rbac.authorization.k8s.io


