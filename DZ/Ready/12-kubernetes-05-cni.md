# Домашнее задание к занятию "12.5 Сетевые решения CNI"
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.
## Задание 1: установить в кластер CNI плагин Calico
Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 
* установка производится через ansible/kubespray;
* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

## Ответ
---
```javascript
ubuntu@cp1:~/kubespray/12-5$ kubectl get pods -n policy-demo -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP              NODE    NOMINATED NODE   READINESS GATES
access                  1/1     Running   0          92m   10.233.97.135   node5   <none>           <none>
nginx-76d6c9b8c-xn7zh   1/1     Running   0          24h   10.233.75.3     node2   <none>           <none>
ubuntu@cp1:~/kubespray/12-5$ kubectl get pods test-14155 -o wide
NAME         READY   STATUS    RESTARTS   AGE   IP              NODE    NOMINATED NODE   READINESS GATES
test-14155   1/1     Running   0          71m   10.233.97.136   node5   <none>           <none>
```

Политика запретить все [policy-nginx-deny-all.yaml](./12-5/policy-nginx-deny-all.yaml)
```javascript
ubuntu@cp1:~/kubespray/12-5$ kubectl apply -f ./policy-nginx-deny-all.yaml 
networkpolicy.networking.k8s.io/access-nginx-from-default created
```
Pod access
```javascript
ubuntu@cp1:~$ kubectl run --namespace=policy-demo access --rm -ti --image busybox /bin/sh
If you dont see a command prompt, try pressing enter.
/ # wget -q --timeout=5 nginx -O -
wget: download timed out
```
Pod test-14155
```javascript
ubuntu@cp1:~$ kubectl run test-$RANDOM --namespace=default --rm -i -t --image=alpine -- sh
If you don't see a command prompt, try pressing enter.
/ # wget -q --timeout=5 10.233.3.226 -O -
wget: download timed out 
```
Политика разрешить из пода access [policy-nginx-from-access.yaml](./12-5/policy-nginx-from-access.yaml)
```javascript
ubuntu@cp1:~/kubespray/12-5$ kubectl apply -f ./policy-nginx-from-access.yaml 
networkpolicy.networking.k8s.io/access-nginx created
```
Pod access
```javascript
ubuntu@cp1:~$ kubectl run --namespace=policy-demo access --rm -ti --image busybox /bin/sh
/ # wget -q --timeout=5 nginx -O -
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
```
Pod test-14155
```javascript
ubuntu@cp1:~$ kubectl run test-$RANDOM --namespace=default --rm -i -t --image=alpine -- sh
If you dont see a command prompt, try pressing enter.
/ # wget -q --timeout=5 nginx -O -
wget: download timed out
```
Политика разрешить вес траффик [policy-nginx-from-all-ns.yaml](./12-5/policy-nginx-from-all-ns.yaml)
```javascript
ubuntu@cp1:~/kubespray/12-5$ kubectl apply -f ./policy-nginx-from-all-ns.yaml 
networkpolicy.networking.k8s.io/access-nginx-from-default configured
```
Pod access
```javascript
ubuntu@cp1:~$ kubectl run --namespace=policy-demo access --rm -ti --image busybox /bin/sh
If you dont see a command prompt, try pressing enter.
/ # wget -q --timeout=5 nginx -O -
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
```
Pod test-14155
```javascript

ubuntu@cp1:~$ kubectl run test-$RANDOM --namespace=default --rm -i -t --image=alpine -- sh
If you dont see a command prompt, try pressing enter.
/ # wget -q --timeout=5 10.233.3.226 -O -
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
```
Контролер
```javascript

ubuntu@cp1:~/kubespray/12-5$ curl 10.233.3.226
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
```
---
## Задание 2: изучить, что запущено по умолчанию
Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
Требования: 
* установить утилиту calicoctl;
* получить 3 вышеописанных типа в консоли.

## Ответ
---
```javascript
ubuntu@cp1:~/kubespray/12-5$ calicoctl get nodes
NAME    
cp1     
node1   
node2   
node3   
node4   
node5   

ubuntu@cp1:~/kubespray/12-5$ calicoctl get ipPool
NAME           CIDR             SELECTOR   
default-pool   10.233.64.0/18   all()      

ubuntu@cp1:~/kubespray/12-5$ sudo calicoctl get profile
NAME                                                 
projectcalico-default-allow                          
kns.default                                          
kns.kube-node-lease                                  
kns.kube-public                                      
kns.kube-system                                      
kns.policy-demo                                      
ksa.default.default                                  
ksa.kube-node-lease.default                          
ksa.kube-public.default                              
ksa.kube-system.attachdetach-controller              
ksa.kube-system.bootstrap-signer                     
ksa.kube-system.calico-kube-controllers              
ksa.kube-system.calico-node                          
ksa.kube-system.certificate-controller               
ksa.kube-system.clusterrole-aggregation-controller   
ksa.kube-system.coredns                              
ksa.kube-system.cronjob-controller                   
ksa.kube-system.daemon-set-controller                
ksa.kube-system.default                              
ksa.kube-system.deployment-controller                
ksa.kube-system.disruption-controller                
ksa.kube-system.dns-autoscaler                       
ksa.kube-system.endpoint-controller                  
ksa.kube-system.endpointslice-controller             
ksa.kube-system.endpointslicemirroring-controller    
ksa.kube-system.ephemeral-volume-controller          
ksa.kube-system.expand-controller                    
ksa.kube-system.generic-garbage-collector            
ksa.kube-system.horizontal-pod-autoscaler            
ksa.kube-system.job-controller                       
ksa.kube-system.kube-proxy                           
ksa.kube-system.namespace-controller                 
ksa.kube-system.node-controller                      
ksa.kube-system.nodelocaldns                         
ksa.kube-system.persistent-volume-binder             
ksa.kube-system.pod-garbage-collector                
ksa.kube-system.pv-protection-controller             
ksa.kube-system.pvc-protection-controller            
ksa.kube-system.replicaset-controller                
ksa.kube-system.replication-controller               
ksa.kube-system.resourcequota-controller             
ksa.kube-system.root-ca-cert-publisher               
ksa.kube-system.service-account-controller           
ksa.kube-system.service-controller                   
ksa.kube-system.statefulset-controller               
ksa.kube-system.token-cleaner                        
ksa.kube-system.ttl-after-finished-controller        
ksa.kube-system.ttl-controller                       
ksa.policy-demo.default                              


```
---


### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
