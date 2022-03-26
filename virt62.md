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

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

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

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

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
