# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "b1ghn66scihrboe3sfhv"
  folder_id = "b1goftamkelavkhtqfcd"
  zone = "ru-central1-a"
}


terraform {
backend "s3" {
endpoint = "storage.yandexcloud.net"
bucket = "ntlgtimbucket"
region = "ru-central1"
key = "terr73.tfstate"
access_key = "YCAJEv3zzCvwnvFdA6NDuz7y-"
secret_key = "YCOPHmEl5gjNe26ZHogy53zxeLtAl-u2hkYEQqg_"
skip_region_validation = true
skip_credentials_validation = true
}
}

locals {
  web_instance_count_map = {
    stage = 2
    prod = 1
  }
}



# VM
resource "yandex_compute_instance" "vm-1" {
  name = "terraform-${count.index}-${terraform.workspace}"
  count = local.web_instance_count_map[terraform.workspace]
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


locals {
  backets_ids = toset([
    "e1",
    "e2",
  ])
}
resource "yandex_compute_instance" "vm-2" {
  for_each = local.backets_ids
    name = "terraform-${each.key}-${terraform.workspace}"

  
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
resource "yandex_vpc_network" "network-1" {
  name = "network1-${terraform.workspace}"
}
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1-${terraform.workspace}"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

