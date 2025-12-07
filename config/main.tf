terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "tf-key.json"
  cloud_id = "b1gmi54303rg7a6bekt4"
  folder_id = "b1g25pktec9d3jpkro8g"
  zone = "ru-central1-b"
}

resource "yandex_vpc_network" "main" {
  name = "main-network"
}

resource "yandex_vpc_subnet" "public" {
  name = "public-subnet"
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.1.0/24"]
}

resource "yandex_vpc_subnet" "private_a" {
  name = "private-subnet-a"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.2.0/24"]
  route_table_id = yandex_vpc_route_table.private_routes.id
}

resource "yandex_vpc_subnet" "private_b" {
  name = "private-subnet-b"
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.3.0/24"]
  route_table_id = yandex_vpc_route_table.private_routes.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private_routes" {
  name = "private-route-table"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.nat_gateway.id
  }
}