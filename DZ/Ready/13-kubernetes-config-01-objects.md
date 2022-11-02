# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.
## Ответ
---
[Манифесты](./13-1/stage/)  
```javascript
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-1$ kubectl get deployments.apps -o wide
NAME     READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                                             SELECTOR
fb-app   1/1     1            1           25h   front,back   nginx:1.20,praqma/network-multitool:alpine-extra   app=fb-app
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-1$ kubectl get statefulsets -o wide
NAME          READY   AGE   CONTAINERS     IMAGES
postgres-db   1/1     23h   postgres-sdb   postgres:13-alpine

tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-1$ kubectl get po,svc
NAME                          READY   STATUS    RESTARTS   AGE
pod/fb-app-6dd949fbdd-cxlkm   2/2     Running   0          5m3s
pod/postgres-db-0             1/1     Running   0          21h

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/postgres-db-lb   ClusterIP   10.99.72.191   <none>        5432/TCP   23h
```
Проверка Back видит БД
```javascript
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-1$ kubectl exec -it -c back fb-app-6dd949fbdd-cxlkm -- sh
/ # psql -h postgres-db-lb -U postgres -d news
Password for user postgres: 
```


## Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

## Ответ
---
[Манифесты](./13-1/prod)    
```javascript
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-1/prod$ kubectl get deployments.apps -o wide
NAME        READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                                  SELECTOR
back-app    1/1     1            1           73m   back         praqma/network-multitool:alpine-extra   app=back-app
front-app   1/1     1            1           74m   front        praqma/network-multitool:alpine-extra   app=front-app
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-1/prod$ kubectl get statefulsets.apps -o wide
NAME          READY   AGE   CONTAINERS     IMAGES
postgres-db   1/1     52m   postgres-sdb   postgres:13-alpine
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-1/prod$ kubectl get po,svc -o wide
NAME                             READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
pod/back-app-69c94f8dcb-bkqnv    1/1     Running   0          77m   172.17.0.17   minikube   <none>           <none>
pod/front-app-5b6659959b-kwp42   1/1     Running   0          41m   172.17.0.19   minikube   <none>           <none>
pod/postgres-db-0                1/1     Running   0          54m   172.17.0.18   minikube   <none>           <none>

NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/back-app-ip       ClusterIP   10.100.128.19   <none>        8080/TCP   46m   app=back-app
service/front-app-ip      ClusterIP   10.103.42.81    <none>        8080/TCP   41m   app=front-app
service/postgres-db-svc   ClusterIP   10.102.76.42    <none>        5432/TCP   75m   app=postgres-db
```
Проверка   
Front видит Back
```javascript
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-1/prod$ kubectl exec -it -c front front-app-5b6659959b-kwp42 -- curl 10.100.128.19:8080
Praqma Network MultiTool (with NGINX) - back-app-69c94f8dcb-bkqnv - 172.17.0.17
```
Back видит Front и видит бд   
```javascript
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-1/prod$ kubectl exec -it -c back back-app-69c94f8dcb-bkqnv -- psql -h 10.102.76.42 -U postgres -d news
Password for user postgres: 
tim@tim-VirtualBox:~/devops-netology/DZ/Ready/13-1/prod$ kubectl exec -it -c back back-app-69c94f8dcb-bkqnv -- curl 10.103.42.81:8080
Praqma Network MultiTool (with NGINX) - front-app-5b6659959b-kwp42 - 172.17.0.19
```

## Задание 3 (*): добавить endpoint на внешний ресурс api
Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
* добавлен endpoint до внешнего api (например, геокодер).

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

В качестве решения прикрепите к ДЗ конфиг файлы для деплоя. Прикрепите скриншоты вывода команды kubectl со списком запущенных объектов каждого типа (pods, deployments, statefulset, service) или скриншот из самого Kubernetes, что сервисы подняты и работают.

---
