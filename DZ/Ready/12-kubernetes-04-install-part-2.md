# Домашнее задание к занятию "12.4 Развертывание кластера на собственных серверах, лекция 2"
Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив. Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

## Задание 1: Подготовить инвентарь kubespray
Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
* подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
* в качестве CRI — containerd;
* запуск etcd производить на мастере.

## Ответ
---
[host.yaml](./12-4/host.yaml)   
[k8s-cluster.yml](./12-4/k8s-cluster.yml)

Локальное подключение к кластеру
```javascript
ubuntu@fhmbih463fnub04q77tt:~/kubespray$ kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
cp1     Ready    control-plane   11m   v1.25.3
node1   Ready    <none>          10m   v1.25.3
node2   Ready    <none>          10m   v1.25.3
node3   Ready    <none>          10m   v1.25.3
node4   Ready    <none>          10m   v1.25.3
node5   Ready    <none>          10m   v1.25.3
```
Удаленное подключение к кластеру
```javascript
tim@tim-VirtualBox:~$ kubectl config use-context kubernetes-admin@kubespray.local
Switched to context "kubernetes-admin@kubespray.local".
tim@tim-VirtualBox:~$ kubectl get nodes
NAME    STATUS   ROLES           AGE   VERSION
cp1     Ready    control-plane   20m   v1.25.3
node1   Ready    <none>          18m   v1.25.3
node2   Ready    <none>          18m   v1.25.3
node3   Ready    <none>          18m   v1.25.3
node4   Ready    <none>          18m   v1.25.3
node5   Ready    <none>          18m   v1.25.3
```
---



## Задание 2 (*): подготовить и проверить инвентарь для кластера в AWS
Часть новых проектов хотят запускать на мощностях AWS. Требования похожи:
* разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
* работать должны на минимально допустимых EC2 — t3.small.

## Ответ
---
YC + Terraform   
[main.tf](./12-3/terraform/main.tf)



---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
