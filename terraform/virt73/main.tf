# Provider
#terraform {
#  required_providers {
#    yandex = {
#      source = "yandex-cloud/yandex"
#    }
#  }
#}
provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "b1ghn66scihrboe3sfhv"
  folder_id = "b1goftamkelavkhtqfcd"
  zone = "ru-central1-a"
}
resource "yandex_storage_bucket" "test" {
  access_key = "ajet2b8gtv8se4p8i65b"
  secret_key = "YCPYvz4I7uvxzUVi-jYjrH_TbCq-K_YC84yYYuV1"
  bucket = "ntlgtimbucket"
}
