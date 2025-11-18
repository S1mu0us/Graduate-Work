#  Дипломная работа по профессии «[Системный администратор](https://github.com/netology-code/sys-diplom/blob/diplom-zabbix/README.md)»
---
## ...*находится в разработке*...
---
## Создание и подготовка ВМ

Характеристики системы: 
* Платформа:                      `Intel Ice Lake`
* Гарантированная доля vCPU:      `20%`
* vCPU:                           `2`
* RAM:                            `2 ГБ`
* Объём дискового пространства:   `10 ГБ`
* Прерываемая:                    `Да`
* ОС:                             `Ubuntu 24.04`
* Внешний IP:                     `Да`

Установка пакетов
```
sudo apt update
sudo apt upgrade
sudo apt install unzip wget git ansible
wget https://hashicorp-releases.yandexcloud.net/terraform/1.13.5/terraform_1.13.5_linux_amd64.zip
unzip terraform_1.13.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

Создание ключа-доступа для terraform
```
yc init
yc iam key create --service-account-id aj6***********lmj --output tf-key.json
chmod 600 tf-key.json
```
Создаём приватную подсеть в зоне `ru-central1-a`
```
resource "yandex_vpc_subnet" "private_a" {
  name = "private-subnet-a"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.2.0/24"]
  route_table_id = yandex_vpc_route_table.private_routes.id
}
```
Возникли некоторые трудности с созданием этой подсети из-за маршрутизации по зоне `ru-central1-a`, поэтому создал подсеть напрямую через `yandex cloud` и импортировал её в `terraform`, это помогло решить проблему.

---

Добавляем NAT-шлюз, формируем таблицу маршрутов и привязываем её к приватной подсети в наш `main.tf`.
```hcl

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

### И дополнительно добавляем строчку route_table_id = yandex_vpc_route_table.private_routes.id в блок resource "yandex_vpc_subnet" "private_a"
```

Создаём вторую подсеть, где будем использовать зону `ru-central-b`
```
resource "yandex_vpc_subnet" "private_b" {
  name = "private-subnet-b"
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.3.0/24"]
  route_table_id = yandex_vpc_route_table.private_routes.id
}
```
### Подготовка бастион-сервера
Характеристики системы: 
* Платформа:                      `Intel Ice Lake`
* Гарантированная доля vCPU:      `20%`
* vCPU:                           `2`
* RAM:                            `2 ГБ`
* Объём дискового пространства:   `10 ГБ`
* Прерываемая:                    `Да`
* ОС:                             `Ubuntu 24.04`
* Внешний IP:                     `Да`
* Подсеть:                        `public-subnet`

### Подготовка веб-сервера 1 `web1` в зоне `ru-central1-a`
Характеристики системы: 
* Платформа:                      `Intel Ice Lake`
* Гарантированная доля vCPU:      `20%`
* vCPU:                           `2`
* RAM:                            `2 ГБ`
* Объём дискового пространства:   `10 ГБ`
* Прерываемая:                    `Да`
* ОС:                             `Ubuntu 24.04`
* Внешний IP:                     `Нет`
* Подсеть:                        `private-subnet-a`

### Подготовка веб-сервера 2 `web2` в зоне `ru-central1-b`
Характеристики системы: 
* Платформа:                      `Intel Ice Lake`
* Гарантированная доля vCPU:      `20%`
* vCPU:                           `2`
* RAM:                            `2 ГБ`
* Объём дискового пространства:   `10 ГБ`
* Прерываемая:                    `Да`
* ОС:                             `Ubuntu 24.04`
* Внешний IP:                     `Нет`
* Подсеть:                        `private-subnet-b`

.terraformrc
```hcl
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

main.tf
```hcl
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
  cloud_id = "b1****************t4"
  folder_id = "b1***************8g"
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

resource "yandex_vpc_subnet" "private" {
  name = "private-subnet"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.2.0/24"]
}
```

---

### простыня запросов
```bash
sudo apt update
sudo apt upgrade
sudo apt install unzip wget git ansible
wget https://hashicorp-releases.yandexcloud.net/terraform/1.13.5/terraform_1.13.5_linux_amd64.zip
unzip terraform_1.13.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
exec -l $SHELL
yc init
yc iam key create --service-account-id aj6***********lmj --output tf-key.json
chmod 600 tf-key.json
mkdir tf-yc
cd tf-yc
nano main.tf
nano ~/.terraformrc
yc vpc subnet list

terraform init
nano main.tf
terraform apply
```
