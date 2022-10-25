# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
provider "yandex" {
  service_account_key_file = "/home/tim/key.json"
  cloud_id  = "b1ghn66scihrboe3sfhv"
  folder_id = "b1goftamkelavkhtqfcd"
  zone = "ru-central1-a"
}
# VM 1
resource "yandex_compute_instance" "vm-1" {
  name = "cp1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8lbi4hr72am1eb2kmf"
      type     = "network-ssd"
      size     = "50"
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

# VM 2
resource "yandex_compute_instance" "vm-2" {
  name = "node1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8lbi4hr72am1eb2kmf"
      type     = "network-hdd"
      size     = "100"
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

# VM 3
resource "yandex_compute_instance" "vm-3" {
  name = "node2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8lbi4hr72am1eb2kmf"
      type     = "network-hdd"
      size     = "100"
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

# VM 4
resource "yandex_compute_instance" "vm-4" {
  name = "node3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8lbi4hr72am1eb2kmf"
      type     = "network-hdd"
      size     = "100"
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

# VM 5
resource "yandex_compute_instance" "vm-5" {
  name = "node4"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8lbi4hr72am1eb2kmf"
      type     = "network-hdd"
      size     = "100"
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

# VM 6
resource "yandex_compute_instance" "vm-6" {
  name = "node5"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8lbi4hr72am1eb2kmf"
      type     = "network-hdd"
      size     = "100"
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
  name = "network1"
}
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}


output "CP1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "CP1_local" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "node1" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "node1_local" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}


output "node2" {
  value = yandex_compute_instance.vm-3.network_interface.0.ip_address
}

output "node2_local" {
  value = yandex_compute_instance.vm-3.network_interface.0.nat_ip_address
}

output "node3" {
  value = yandex_compute_instance.vm-4.network_interface.0.ip_address
}

output "node3_local" {
  value = yandex_compute_instance.vm-4.network_interface.0.nat_ip_address
}
output "node4" {
  value = yandex_compute_instance.vm-5.network_interface.0.ip_address
}

output "node4_local" {
  value = yandex_compute_instance.vm-5.network_interface.0.nat_ip_address
}
output "node5" {
  value = yandex_compute_instance.vm-6.network_interface.0.ip_address
}

output "node5_local" {
  value = yandex_compute_instance.vm-6.network_interface.0.nat_ip_address
}