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
  cloud_id  = ""
  folder_id = ""
  zone = "ru-central1-a"
}
#resource "yandex_storage_bucket" "test" {
#  access_key = "YCAJE1_c5ux10crvaLB1rQOzW"
#  secret_key = "YCPYvz4I7uvxzUVi-jYjrH_TbCq-K_YC84yYYuV1"
#  bucket = "ntlgtimbucket"
#}
