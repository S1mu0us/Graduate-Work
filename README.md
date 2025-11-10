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

### Полный код
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
terraform init
nano main.tf
```
