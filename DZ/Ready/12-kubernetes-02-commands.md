# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods


## Ответ
---
```javascript
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/12-2$ kubectl apply -f nginx-deployment.yml
deployment.apps/nginx-deployment created
tim@tim-VirtualBox:~$ kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
hello-minikube     1/1     1            1           7d22h
hello-node         2/2     2            2           6d23h
nginx-deployment   2/2     2            2           3d
tim@tim-VirtualBox:~$ kubectl get pods
NAME                                READY   STATUS    RESTARTS       AGE
hello-minikube-65dc654df9-8ptc6     1/1     Running   1 (7d1h ago)   7d22h
hello-node-7f48bfb94f-954cg         1/1     Running   0              6d23h
hello-node-7f48bfb94f-t82m8         1/1     Running   0              2d23h
nginx-deployment-7fb96c846b-mwrbs   1/1     Running   0              3d
nginx-deployment-7fb96c846b-rzkng   1/1     Running   0              3d
```
---

## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования: 
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

## Ответ
---
```javascript
tim@tim-VirtualBox:~/dev$ openssl genrsa -out dev2.key 2048
Generating RSA private key, 2048 bit long modulus (2 primes)
.............................................................................................+++++
.................................+++++
e is 65537 (0x010001)
tim@tim-VirtualBox:~/dev$ openssl req -new -key dev2.key -out dev2.csr -subj "/CN=dev2"
"
tim@tim-VirtualBox:~/dev$ openssl x509 -req -in dev2.csr -CA /home/tim/.minikube/ca.crt -CAkey /home/tim/.minikube/ca.key -CAcreateserial -out dev2.crt -days 500
Signature ok
subject=CN = dev2
Getting CA Private Key
tim@tim-VirtualBox:~/dev$ kubectl config set-credentials dev2 --client-certificate=/home/tim/dev/dev2.crt --client-key=/home/tim/dev/dev2.key
User "dev2" set.
tim@tim-VirtualBox:~/dev$ kubectl config set-context dev2 --namespace=default --cluster=minikube --user=dev2
Context "dev2" created.
tim@tim-VirtualBox:~$ cat <<EOF | kubectl apply -f -
> kind: Role
> apiVersion: rbac.authorization.k8s.io/v1
> metadata:
>   namespace: default
>   name: develop-logs
> rules:
> - apiGroups: [""]
>   resources: ["pods", "pods/log"]
>   verbs: ["get", "list"]
> EOF
role.rbac.authorization.k8s.io/develop-logs created
tim@tim-VirtualBox:~/dev$ cat <<EOF | kubectl apply -f -
> kind: RoleBinding
> apiVersion: rbac.authorization.k8s.io/v1
> metadata:
>   name: devevelop-view
>   namespace: default
> subjects:
> - kind: User
>   name: dev2
>   namespace: default
> roleRef:
>   apiGroup: rbac.authorization.k8s.io
>   kind: Role
>   name: develop-logs
> EOF
rolebinding.rbac.authorization.k8s.io/devevelop-view configured
tim@tim-VirtualBox:~/dev$ kubectl config use-context dev2
Switched to context "dev2".
tim@tim-VirtualBox:~/dev$ kubectl get pods
NAME                                READY   STATUS    RESTARTS        AGE
hello-minikube-65dc654df9-8ptc6     1/1     Running   2 (3h39m ago)   10d
hello-node-7f48bfb94f-954cg         1/1     Running   1 (3h39m ago)   9d
hello-node-7f48bfb94f-bkh22         1/1     Running   1 (3h39m ago)   2d20h
hello-node-7f48bfb94f-h6hmx         1/1     Running   1 (3h39m ago)   2d20h
hello-node-7f48bfb94f-hnrv5         1/1     Running   1 (3h39m ago)   2d20h
hello-node-7f48bfb94f-t82m8         1/1     Running   1 (3h39m ago)   5d21h
nginx-deployment-7fb96c846b-mwrbs   1/1     Running   1 (3h39m ago)   5d22h
nginx-deployment-7fb96c846b-rzkng   1/1     Running   1 (3h39m ago)   5d22h
tim@tim-VirtualBox:~/dev$ kubectl describe pod hello-node-7f48bfb94f-954cg
Name:             hello-node-7f48bfb94f-954cg
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Thu, 06 Oct 2022 21:00:15 +0300
Labels:           app=hello-node
                  pod-template-hash=7f48bfb94f
Annotations:      <none>
Status:           Running
IP:               172.17.0.6
IPs:
  IP:           172.17.0.6
Controlled By:  ReplicaSet/hello-node-7f48bfb94f
Containers:
  echoserver:
    Container ID:   docker://6be2db252ecb964863201a9f31b7fd33dd9ea2fe70da50ee90158993d6a232e1
    Image:          registry.k8s.io/echoserver:1.4
    Image ID:       docker-pullable://registry.k8s.io/echoserver@sha256:5d99aa1120524c801bc8c1a7077e8f5ec122ba16b6dda1a5d3826057f67b9bcb
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 16 Oct 2022 15:06:29 +0300
    Last State:     Terminated
      Reason:       Error
      Exit Code:    255
      Started:      Thu, 06 Oct 2022 21:00:34 +0300
      Finished:     Sun, 16 Oct 2022 15:06:01 +0300
    Ready:          True
    Restart Count:  1
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5xxjd (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-5xxjd:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
tim@tim-VirtualBox:~/dev$ kubectl logs hello-minikube-65dc654df9-8ptc6 
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2022/10/16 12:06:29 [notice] 1#1: using the "epoll" event method
2022/10/16 12:06:29 [notice] 1#1: nginx/1.23.1
2022/10/16 12:06:29 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6) 
2022/10/16 12:06:29 [notice] 1#1: OS: Linux 5.15.0-50-generic
2022/10/16 12:06:29 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2022/10/16 12:06:29 [notice] 1#1: start worker processes
2022/10/16 12:06:29 [notice] 1#1: start worker process 31
2022/10/16 12:06:29 [notice] 1#1: start worker process 32
2022/10/16 12:06:29 [notice] 1#1: start worker process 33
2022/10/16 12:06:29 [notice] 1#1: start worker process 34


```

---
## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)

## Ответ
---
```javascript

tim@tim-VirtualBox:~$ kubectl edit deployment -n default hello-node
deployment.apps/hello-node edited
tim@tim-VirtualBox:~$ kubectl get pods -A 
NAMESPACE              NAME                                        READY   STATUS      RESTARTS       AGE
default                hello-minikube-65dc654df9-8ptc6             1/1     Running     1 (7d2h ago)   7d23h
default                hello-node-7f48bfb94f-954cg                 1/1     Running     0              7d
default                hello-node-7f48bfb94f-bkh22                 1/1     Running     0              6s
default                hello-node-7f48bfb94f-h6hmx                 1/1     Running     0              6s
default                hello-node-7f48bfb94f-hnrv5                 1/1     Running     0              6s
default                hello-node-7f48bfb94f-t82m8                 1/1     Running     0              3d
default                nginx-deployment-7fb96c846b-mwrbs           1/1     Running     0              3d1h
default                nginx-deployment-7fb96c846b-rzkng           1/1     Running     0              3d1h
ingress-nginx          ingress-nginx-admission-create-qt6tk        0/1     Completed   0              7d
ingress-nginx          ingress-nginx-admission-patch-f8f9w         0/1     Completed   1              7d
ingress-nginx          ingress-nginx-controller-5959f988fd-bx8k5   1/1     Running     0              7d
kube-system            coredns-565d847f94-q8wzg                    1/1     Running     1 (7d2h ago)   7d23h
kube-system            etcd-minikube                               1/1     Running     1 (7d2h ago)   7d23h
kube-system            kube-apiserver-minikube                     1/1     Running     1 (7d2h ago)   7d23h
kube-system            kube-controller-manager-minikube            1/1     Running     1 (7d2h ago)   7d23h
kube-system            kube-proxy-dpcwj                            1/1     Running     1 (7d2h ago)   7d23h
kube-system            kube-scheduler-minikube                     1/1     Running     1 (7d2h ago)   7d23h
kube-system            storage-provisioner                         1/1     Running     6 (7d1h ago)   7d23h
kubernetes-dashboard   dashboard-metrics-scraper-b74747df5-k2lth   1/1     Running     1 (7d2h ago)   7d23h
kubernetes-dashboard   kubernetes-dashboard-54596f475f-jphlw       1/1     Running     2 (7d2h ago)   7d23h
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
