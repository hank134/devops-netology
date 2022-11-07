# Домашнее задание к занятию "13.2 разделы и монтирование"
Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
* установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
* добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.

## Задание 1: подключить для тестового конфига общую папку
В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

## Ответ
---
[Манифесты](./13-2/stage/)  

### Back пишет в общую папку
```javascript

tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-2/stage$ kubectl exec -c back fb-app-d46cc8d85-5sr6s  -- sh -c "echo 'Back: Hello' >>  /to_front/exch.txt && ls -lha /to_front/&& echo '---------' && cat /to_front/exch.txt "
total 12K    
drwxrwxrwx    2 root     root        4.0K Nov  5 11:41 .
drwxr-xr-x    1 root     root        4.0K Nov  5 10:21 ..
-rw-r--r--    1 root     root          12 Nov  5 11:41 exch.txt
---------
Back: Hello
```
### Front видит нвоый файл и дописывает в него
```javascript
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-2/stage$ kubectl exec -c front fb-app-d46cc8d85-5sr6s  -- sh -c "echo 'Front: Hi' >>  /from_back/exch.txt  && ls -lha /from_back/&& echo '---------' && cat /from_back/exch.txt "
total 12K    
drwxrwxrwx    2 root     root        4.0K Nov  5 11:41 .
drwxr-xr-x    1 root     root        4.0K Nov  5 11:42 ..
-rw-r--r--    1 root     root          22 Nov  5 11:42 exch.txt
---------
Back: Hello
Front: Hi
```


## Задание 2: подключить общую папку для прода
Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.

## Ответ
---
[Манифесты](./13-2/prod/)
### Новый PVC
```javascript
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-2/prod$ kubectl describe pvc test-dynamic-volume-claim
Name:          test-dynamic-volume-claim
Namespace:     prod
StorageClass:  nfs
Status:        Bound
Volume:        pvc-65efebe7-b7aa-43ca-a2ae-b826f515e0f5
Labels:        <none>
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
               volume.beta.kubernetes.io/storage-provisioner: cluster.local/nfs-server-nfs-server-provisioner
               volume.kubernetes.io/storage-provisioner: cluster.local/nfs-server-nfs-server-provisioner
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      100Mi
Access Modes:  RWX
VolumeMode:    Filesystem

Used By:       back-app-7d689d6bf9-slpcx
               front-app-fb6c49c74-5pdng
Events:
  Type    Reason                 Age   From                                                                                                                      Message
  ----    ------                 ----  ----                                                                                                                      -------
  Normal  ExternalProvisioning   22m   persistentvolume-controller                                                                                               waiting for a volume to be created, either by external provisioner "cluster.local/nfs-server-nfs-server-provisioner" or manually created by system administrator
  Normal  Provisioning           22m   cluster.local/nfs-server-nfs-server-provisioner_nfs-server-nfs-server-provisioner-0_8198a4ce-a15d-4577-b508-59c02905430b  External provisioner is provisioning volume for claim "prod/test-dynamic-volume-claim"
  Normal  ProvisioningSucceeded  22m   cluster.local/nfs-server-nfs-server-provisioner_nfs-server-nfs-server-provisioner-0_8198a4ce-a15d-4577-b508-59c02905430b  Successfully provisioned volume pvc-65efebe7-b7aa-43ca-a2ae-b826f515e0f5

tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-2/prod$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS      AGE
back-app-7d689d6bf9-slpcx             1/1     Running   1             110m
front-app-fb6c49c74-5pdng             1/1     Running   1             105m
nfs-server-nfs-server-provisioner-0   1/1     Running   2 (58m ago)   129m
postgres-db-0                         1/1     Running   1 (58m ago)   5d1h
```
### Back пишет в общую папку
```javascript
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-2/prod$ kubectl exec -c back back-app-7d689d6bf9-slpcx  -- sh -c "echo 'Back: Hello' >>  /to_front/exch.txt && ls -lha /to_front/&& echo '---------' && cat /to_front/exch.txt "
total 12K    
drwxrwsrwx    2 root     root        4.0K Nov  7 17:36 .
drwxr-xr-x    1 root     root        4.0K Nov  7 17:32 ..
-rw-r--r--    1 root     root          12 Nov  7 17:36 exch.txt
---------
Back: Hello

tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-2/prod$ kubectl describe pods back-app-7d689d6bf9-slpcx 
Name:             back-app-7d689d6bf9-slpcx
Namespace:        prod
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Mon, 07 Nov 2022 20:32:31 +0300
Labels:           app=back-app
                  pod-template-hash=7d689d6bf9
Annotations:      <none>
Status:           Running
IP:               172.17.0.17
IPs:
  IP:           172.17.0.17
Controlled By:  ReplicaSet/back-app-7d689d6bf9
Containers:
  back:
    Container ID:   docker://dc7e3be4cdba0a4538e5eeb4349def9945b6bc442461d974fb56c87ca27ebdc5
    Image:          praqma/network-multitool:alpine-extra
    Image ID:       docker-pullable://praqma/network-multitool@sha256:5662f8284f0dc5f5e5c966e054d094cbb6d0774e422ad9031690826bc43753e5
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 07 Nov 2022 21:25:49 +0300
    Ready:          True
    Restart Count:  1
    Environment:
      HTTP_PORT:  8080
    Mounts:
      /to_front from nfs-storage (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-4qnfv (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  nfs-storage:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  test-dynamic-volume-claim
    ReadOnly:   false
  kube-api-access-4qnfv:
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


```
### Front видит новый файл и дописывает в него
```javascript
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-2/prod$ kubectl exec -c front front-app-fb6c49c74-5pdng  -- sh -c "echo 'Front: Hi' >>  /from_back/exch.txt  && ls -lha /from_back/&& echo '---------' && cat /from_back/exch.txt "
total 12K    
drwxrwsrwx    2 root     root        4.0K Nov  7 17:36 .
drwxr-xr-x    1 root     root        4.0K Nov  7 17:37 ..
-rw-r--r--    1 root     root          22 Nov  7 17:37 exch.txt
---------
Back: Hello
Front: Hi


tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-2/prod$ kubectl describe pods front-app-fb6c49c74-5pdng
Name:             front-app-fb6c49c74-5pdng
Namespace:        prod
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Mon, 07 Nov 2022 20:37:28 +0300
Labels:           app=front-app
                  pod-template-hash=fb6c49c74
Annotations:      <none>
Status:           Running
IP:               172.17.0.19
IPs:
  IP:           172.17.0.19
Controlled By:  ReplicaSet/front-app-fb6c49c74
Containers:
  front:
    Container ID:   docker://c5201c08eb15d9db1bf815c224ec8d0aef941dcc9f32cbd4b0e391d092f47e23
    Image:          praqma/network-multitool:alpine-extra
    Image ID:       docker-pullable://praqma/network-multitool@sha256:5662f8284f0dc5f5e5c966e054d094cbb6d0774e422ad9031690826bc43753e5
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 07 Nov 2022 21:25:46 +0300
    Ready:          True
    Restart Count:  1
    Environment:
      HTTP_PORT:  8080
    Mounts:
      /from_back from nfs-storage (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-t82rp (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  nfs-storage:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  test-dynamic-volume-claim
    ReadOnly:   false
  kube-api-access-t82rp:
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
```


---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
