#!/bin/bash

set -x

REGION=us-east-1

# Output colours
COL='\033[1;34m'
NOC='\033[0m'

##########################################################################################
aws eks --region us-east-1 update-kubeconfig --name wiz-eks-cluster
##########################################################################################
cat <<EOF > mongodbconfig.yml 
apiVersion: v1
kind: Secret
metadata:
  name: mongodb-connstring
data: 
  mongoconnstring: bW9uZ29kYjovL3l1c3dpejoxMjNNb25nb0A0NC4yMDEuMTEzLjc5OjI3MDE3L2ludGVydmlldwo=
type: Opaque 
---
apiVersion: v1
kind: Secret
metadata:
  name: mongodb-password
data: 
  password: MTIzTW9uZ28K
type: Opaque 
---
apiVersion: v1
data:
  HOST: 44.201.113.79
  PORT: "27017"
  DATABASE: "interview"
  USER: "yuswiz"
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: mongo-config

EOF
##########################################################################################
kubectl apply -f mongodbconfig.yml  
##########################################################################################
cat <<EOF > jenkins-deployment.yml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-sa
---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-app
  labels:
    app: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      serviceAccountName: jenkins-sa
      containers:
        - name: jenkins
          image: jenkins/jenkins:lts
          envFrom:
          - configMapRef:
              name: mongo-config
          - secretRef:
              name: mongodb-password
          resources:
            limits:
              memory: "2Gi"
              cpu: "1000m"
            requests:
              memory: "500Mi"
              cpu: "500m"
          ports:
            - name: httpport
              containerPort: 8080
            - name: jnlpport
              containerPort: 50000
          volumeMounts:
            - name: mongodb-volume-secret
              mountPath: /etc/mongojenkins      
      volumes:
      - name: mongodb-volume-secret
        secret:
          secretName: mongodb-connstring 

EOF
##########################################################################################
echo -e "\n$COL> deploying jenkins app on EKS."
##########################################################################################
kubectl apply -f jenkins-deployment.yml
##########################################################################################
kubectl get deploy jenkins-app
##########################################################################################
cat <<EOF > loadbalancer-svc.yml
apiVersion: v1
kind: Service
metadata:
  name: jenkins-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: jenkins
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
EOF
##########################################################################################
echo -e "> applying loadbalancer service"
##########################################################################################
kubectl apply -f loadbalancer-svc.yml
##########################################################################################
kubectl get service/jenkins-loadbalancer|  awk {'print $1" " $2 " " $4 " " $5'} | column -t
##########################################################################################
echo -e "\n$COL> Loadbalancer service created."
##########################################################################################
cat <<EOF > adminrole.yml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-admin
rules:
  -
    apiGroups:
      - ""
      - apps
      - autoscaling
      - batch
      - extensions
      - policy
      - rbac.authorization.k8s.io
    resources:
      - componentstatuses
      - configmaps
      - daemonsets
      - deployments
      - events
      - endpoints
      - horizontalpodautoscalers
      - ingress
      - jobs
      - limitranges
      - namespaces
      - nodes
      - pods
      - persistentvolumes
      - persistentvolumeclaims
      - resourcequotas
      - replicasets
      - replicationcontrollers
      - serviceaccounts
      - services
    verbs: ["*"]
  - nonResourceURLs: ["*"]
    verbs: ["*"]
EOF
##########################################################################################
kubectl apply -f adminrole.yml
##########################################################################################
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts
##########################################################################################



##########################################################################################
# To delete all 
##########################################################################################
# kubectl delete -f mongodbconfig.yml \

# kubectl delete -f jenkins-deployment.yml\

# kubectl delete -f loadbalancer-svc.yml\

# kubectl delete -f adminrole.yml\

# kubectl delete clusterrolebinding permissive-binding

# kubectl cp /Users/yustao/wiz/wizeks/mongoDB.sh jenkins-app-564688c6c4-d7bgr:/var/jenkins_home

# k exec jenkins-app-564688c6c4-d7bgr -it bash 

# helm repo add mongodb https://mongodb.github.io/helm-charts

# helm install community-operator mongodb/community-operator --namespace mongodb [--create-namespace]