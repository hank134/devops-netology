# Домашнее задание к занятию "6.2. SQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.
```
tim@tim-VirtualBox:~$ docker pull postgres:12
tim@tim-VirtualBox:~$ docker volume create volDB
volDB
tim@tim-VirtualBox:~$ docker volume create volBackup
volBackup
tim@tim-VirtualBox:~$ docker run --rm -d --name pg-docker -e POSTGRES_PASSWORD=postgres -ti -p 5432:5432 -v volDB:/var/lib/postgresql/data -v volBackup:/var/lib/postgresql/backup pos
tgres:12
```

## Задача 2


- итоговый список БД после выполнения пунктов выше,
```
test_db=# \l
                                     List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges
-----------+----------+----------+------------+------------+--------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres         +
           |          |          |            |            | "test-admin-user"=CTc/postgres
(4 rows)
```


- описание таблиц (describe)
```
test_db=# \d clients
                                Table "public.clients"
    Column     |  Type   | Collation | Nullable |               Default
---------------+---------+-----------+----------+-------------------------------------
 id            | integer |           | not null | nextval('clients_id_seq'::regclass)
 lastname      | text    |           |          |
 country_rsdnc | text    |           |          |
 zakaz         | integer |           |          |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_zakaz_fkey" FOREIGN KEY (zakaz) REFERENCES orders(id)

test_db=# \d orders
               Table "public.orders"
 Column |  Type   | Collation | Nullable | Default
--------+---------+-----------+----------+---------
 id     | integer |           | not null |
 name   | text    |           |          |
 price  | integer |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_zakaz_fkey" FOREIGN KEY (zakaz) REFERENCES orders(id)
```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

```
test_db=# SELECT * from information_schema.table_privileges WHERE grantee = ('test-simple-user');
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO
(8 rows)

test_db=# SELECT * from information_schema.table_privileges WHERE grantee = ('test-admin-user');
 grantor  |     grantee     | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy
----------+-----------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test-admin-user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-admin-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | DELETE         | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | TRUNCATE       | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | REFERENCES     | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | TRIGGER        | NO           | NO
(7 rows)

```




## Задача 3
```
test_db=# INSERT INTO orders VALUES (1, 'Шоколад', 10), (2, 'Принтер', 3000), (3, 'Книга', 500), (4, 'Монитор', 7000), (5, 'Гитара', 4000);
INSERT 0 5
test_db=# INSERT INTO orders VALUES (1, 'Иванов Иван Иванович', 'USA'), (2, 'Петров Петр Петрович', 'Canada'), (3, 'Иоганн Себастьян Бах', 'Japan'), (4, 'Ронни Джеймс Дио', 'Russia'), (5, 'Ritchie Blackmore', 'Russia');
INSERT 0 5
test_db=# select * from orders;
 id |  name   | price
----+---------+-------
  1 | Шоколад |    10
  2 | Принтер |  3000
  3 | Книга   |   500
  4 | Монитор |  7000
  5 | Гитара  |  4000
(5 rows)

test_db=# select * from clients;
 id |       lastname       | country_rsdnc | zakaz
----+----------------------+---------------+-------
  1 | Иванов Иван Иванович | USA           |
  2 | Петров Петр Петрович | Canada        |
  3 | Иоганн Себастьян Бах | Japan         |
  4 | Ронни Джеймс Дио     | Russia        |
  5 | Ritchie Blackmore    | Russia        |
(5 rows)

test_db=# select count(*) from orders;
 count
-------
     5
(1 row)

test_db=# select count(*) from clients;
 count
-------
     5
(1 row)
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.
```
test_db=# update clients
test_db-# set zakaz = (select id from orders where name = 'Книга')
test_db-# where lastname = 'Иванов Иван Иванович';
UPDATE 1
test_db=# update clients
test_db-# set zakaz = (select id from orders where name = 'Монитор')
test_db-# where lastname = 'Петров Петр Петрович';
UPDATE 1
test_db=# update clients
test_db-# set zakaz = (select id from orders where name = 'Гитара')
test_db-# where lastname = 'Иоганн Себастьян Бах';
UPDATE 1
test_db=# select * from clients;
 id |       lastname       | country_rsdnc | zakaz
----+----------------------+---------------+-------
  4 | Ронни Джеймс Дио     | Russia        |
  5 | Ritchie Blackmore    | Russia        |
  1 | Иванов Иван Иванович | USA           |     3
  2 | Петров Петр Петрович | Canada        |     4
  3 | Иоганн Себастьян Бах | Japan         |     5
(5 rows)
test_db=# select clients.lastname
test_db-# from clients
test_db-# inner join orders
test_db-# on clients.zakaz = orders.id;
       lastname
----------------------
 Иванов Иван Иванович
 Петров Петр Петрович
 Иоганн Себастьян Бах
(3 rows)


```

## Задача 5


```
test_db=# EXPLAIN select clients.lastname
test_db-# from clients
test_db-# inner join orders
test_db-# on clients.zakaz = orders.id;
                              QUERY PLAN
----------------------------------------------------------------------
 Hash Join  (cost=37.00..57.24 rows=810 width=32)
   Hash Cond: (clients.zakaz = orders.id)
   ->  Seq Scan on clients  (cost=0.00..18.10 rows=810 width=36)
   ->  Hash  (cost=22.00..22.00 rows=1200 width=4)
         ->  Seq Scan on orders  (cost=0.00..22.00 rows=1200 width=4)
(5 rows)
```



## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
