# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше.

```console
terraform {
backend "s3" {
endpoint = "storage.yandexcloud.net"
bucket = "ntlgtimbucket"
region = "ru-central1"
key = "terr73.tfstate"
access_key = "XXXXX"
secret_key = "XXXXX"
skip_region_validation = true
skip_credentials_validation = true
}
}

```

![image](https://user-images.githubusercontent.com/93483129/164064151-41022166-35c8-4003-af69-6bc5c242943c.png)

## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
1. Создайте два воркспейса `stage` и `prod`.
1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.
1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
1. При желании поэкспериментируйте с другими параметрами и рессурсами.

![image](https://user-images.githubusercontent.com/93483129/164065296-36620940-d93d-4bca-bc09-b2e5bbd8444b.png)


В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.
```console
tim@tim-VirtualBox:~/devops-netology/terraform/virt73$ terraform workspace list
  default
* prod
  stage

```

* Вывод команды `terraform plan` для воркспейса `prod`.  
```console
tim@tim-VirtualBox:~/devops-netology/terraform/virt73$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vm-1[0] will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnVG0pcCjrdIqcRbrIf0t+wcPh1FsyR3g2Ih7vTWyiP5YD2bJ/ukFMHElaaZmiGgQQ1KgdOLc4k+z3cpCxTbPP/2JKyVY5SUW2myfQshBmDGsOLkwajhSK0YNrnkxQzjQnBgNYQbRBFcvbEGez8mFMgmnGFv8whTQ6Ld0uDshtT/sVFFde1clPaYGnab4d53A49AKe21OlKIGZQhgZTRdSvHOyfyXuip0DPOULaclYlczDQkyHRCzUhogn4EG2NOh+5/2lQXaSlNRJPBcfYBSwgo2sv+bw3W3nkotoYRoW3yfpQu9N7mIkhzN8nzqE5ir/h7Qln+fAhiVu7i58NcKt3/NJTaQ/osYp0GZVYnvX0TaZlDLHKt8zk4ujv5W1N20+JukfVXFA7lQu4q4/KLDkRmKqeI0nbuU+TWixOp5OxT6MeQyrFkDzItZRN9bygaZT58n+m6/HxatOTu4jWU1TbXdlxVX0WV260WU0KgIdGs/dMezy3ldgMtRe/yf5aMM= tim@tim-VirtualBox
            EOT
        }
      + name                      = "terraform-0-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80viupr3qjr5g6g9du"
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-2["e1"] will be created
  + resource "yandex_compute_instance" "vm-2" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnVG0pcCjrdIqcRbrIf0t+wcPh1FsyR3g2Ih7vTWyiP5YD2bJ/ukFMHElaaZmiGgQQ1KgdOLc4k+z3cpCxTbPP/2JKyVY5SUW2myfQshBmDGsOLkwajhSK0YNrnkxQzjQnBgNYQbRBFcvbEGez8mFMgmnGFv8whTQ6Ld0uDshtT/sVFFde1clPaYGnab4d53A49AKe21OlKIGZQhgZTRdSvHOyfyXuip0DPOULaclYlczDQkyHRCzUhogn4EG2NOh+5/2lQXaSlNRJPBcfYBSwgo2sv+bw3W3nkotoYRoW3yfpQu9N7mIkhzN8nzqE5ir/h7Qln+fAhiVu7i58NcKt3/NJTaQ/osYp0GZVYnvX0TaZlDLHKt8zk4ujv5W1N20+JukfVXFA7lQu4q4/KLDkRmKqeI0nbuU+TWixOp5OxT6MeQyrFkDzItZRN9bygaZT58n+m6/HxatOTu4jWU1TbXdlxVX0WV260WU0KgIdGs/dMezy3ldgMtRe/yf5aMM= tim@tim-VirtualBox
            EOT
        }
      + name                      = "terraform-e1-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80viupr3qjr5g6g9du"
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.vm-2["e2"] will be created
  + resource "yandex_compute_instance" "vm-2" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnVG0pcCjrdIqcRbrIf0t+wcPh1FsyR3g2Ih7vTWyiP5YD2bJ/ukFMHElaaZmiGgQQ1KgdOLc4k+z3cpCxTbPP/2JKyVY5SUW2myfQshBmDGsOLkwajhSK0YNrnkxQzjQnBgNYQbRBFcvbEGez8mFMgmnGFv8whTQ6Ld0uDshtT/sVFFde1clPaYGnab4d53A49AKe21OlKIGZQhgZTRdSvHOyfyXuip0DPOULaclYlczDQkyHRCzUhogn4EG2NOh+5/2lQXaSlNRJPBcfYBSwgo2sv+bw3W3nkotoYRoW3yfpQu9N7mIkhzN8nzqE5ir/h7Qln+fAhiVu7i58NcKt3/NJTaQ/osYp0GZVYnvX0TaZlDLHKt8zk4ujv5W1N20+JukfVXFA7lQu4q4/KLDkRmKqeI0nbuU+TWixOp5OxT6MeQyrFkDzItZRN9bygaZT58n+m6/HxatOTu4jWU1TbXdlxVX0WV260WU0KgIdGs/dMezy3ldgMtRe/yf5aMM= tim@tim-VirtualBox
            EOT
        }
      + name                      = "terraform-e2-prod"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80viupr3qjr5g6g9du"
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_vpc_network.network-1 will be created
  + resource "yandex_vpc_network" "network-1" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network1-prod"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-1 will be created
  + resource "yandex_vpc_subnet" "subnet-1" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet1-prod"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 5 to add, 0 to change, 0 to destroy.

───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if
you run "terraform apply" now.
```
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
