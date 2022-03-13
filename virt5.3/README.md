### Задание 1

https://hub.docker.com/u/hank134

### Задание 2

Высоконагруженное монолитное java веб-приложение;
Nodejs веб-приложение;
Мобильное приложение c версиями для Android и iOS;
Шина данных на базе Apache Kafka;
Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
Мониторинг-стек на базе Prometheus и Grafana;
MongoDB, как основное хранилище данных для java-приложения;
Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.


### Задание 3
```bash
tim@tim-VirtualBox:~$ docker pull centos
Using default tag: latest
latest: Pulling from library/centos
a1d0c7532777: Pull complete
Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
Status: Downloaded newer image for centos:latest
docker.io/library/centos:latest
tim@tim-VirtualBox:~$ mkdir data
tim@tim-VirtualBox:~$ docker run -it -d --name Centos -v $(pwd)/data:/data centos:latest
tim@tim-VirtualBox:~$ docker pull debian
Using default tag: latest
latest: Pulling from library/debian
e4d61adff207: Pull complete
Digest: sha256:10b622c6cf6daa0a295be74c0e412ed20e10f91ae4c6f3ce6ff0c9c04f77cbf6
Status: Downloaded newer image for debian:latest
docker.io/library/debian:latest
tim@tim-VirtualBox:~$ docker run -it -d --name debian -v $(pwd)/data:/data debian:latest
324b4ffa134bfaf8c7f322ea68f8310ea4f7008e97a9f00ed06720a638fac157
tim@tim-VirtualBox:~$ docker exec -it Centos bash
[root@c7e3385f05f8 /]# cd data
[root@c7e3385f05f8 data]# >file_C
[root@c7e3385f05f8 data]# exit
tim@tim-VirtualBox:~$ cd data
tim@tim-VirtualBox:~/data$ >file_H
tim@tim-VirtualBox:~$ docker exec -it debian bash
root@c80938a8fa18:/# cd data
root@c80938a8fa18:/data# ls
file_C  file_H
root@c80938a8fa18:/data# exit
exit
```
