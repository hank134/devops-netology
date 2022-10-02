# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
provider "yandex" {
 # service_account_key_file = "key.json"
token = "t1.9euelZqUxp6Zl5jKmZ2WxsmYnJqMy-3rnpWamZSZyInJlJyez83IkpaazZHl8_dcX1Rs-e8iNTZA_t3z9xwOUmz57yI1NkD-.pLDvo5up2h9e2i0XRHCxvh9FrVtVj96nOU5ahqjU7TWMgExhdYQG6TIC-hKl48TgMhMWY-Ld1_Ldw99kgVvuAg"  
cloud_id  = "b1ghn66scihrboe3sfhv"
  folder_id = "b1goftamkelavkhtqfcd"
  zone = "ru-central1-a"
}
# VM
resource "yandex_compute_instance" "vm-1" {
  name = "terraform1-${terraform.workspace}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80viupr3qjr5g6g9du"
      type     = "network-hdd"
      size     = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
#Net
resource "yandex_vpc_network" "network-2" {
  name = "network1-${terraform.workspace}"
}
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1-${terraform.workspace}"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-2.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}



