#  Дипломная работа по профессии «[Системный администратор](https://github.com/netology-code/sys-diplom/blob/diplom-zabbix/README.md)»
---
## ...*находится в разработке*...
---
## Создание и подготовка ВМ `graduate-work-vm`, она же будет играть бастиона. 

Характеристики системы: 
* Платформа:                      `Intel Ice Lake`
* Гарантированная доля vCPU:      `20%`
* vCPU:                           `2`
* RAM:                            `2 ГБ`
* Объём дискового пространства:   `10 ГБ`
* Прерываемая:                    `Да`
* ОС:                             `Ubuntu 24.04`
* Внешний IP:                     `Да`
* Группа безопасности:            `bastion-sg`

Установка пакетов
```bash
sudo apt update
sudo apt upgrade
sudo apt install unzip wget git ansible
wget https://hashicorp-releases.yandexcloud.net/terraform/1.13.5/terraform_1.13.5_linux_amd64.zip
unzip terraform_1.13.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

Создание ключа-доступа для terraform
```bash
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
>Возникли некоторые трудности с созданием этой подсети из-за маршрутизации по зоне `ru-central1-a`, поэтому создал подсеть напрямую через `yandex cloud` и импортировал её в `terraform`, это помогло решить проблему.

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
* Группа безопасности:            `web-sg`

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
* Группа безопасности:            `web-sg`

---

Формируем Группы безопасности в нашей сети `main-network`:

Бастион: 
* Имя: `bastion-sg`
* Входящий трафик:
  - `TCP` `22` `CIDR` `0.0.0.0/0`
* Исходящий трафик:
  - `Any` `0-65535` `CIDR` `0.0.0.0/0`

Балансировщик:
* Имя: `alb-sg`
* Входящий трафик:
  - `TCP` `80` `CIDR` `0.0.0.0/0`
  - `Проверки состояния балансировщика`
* Исходящий трафик:
  - `Any` `0-65535` `CIDR` `0.0.0.0/0`  ------временно

Zabbix:
* Имя: `zabbix-sg`
* Входящий трафик:
  - `TCP` `22` `CIDR` `0.0.0.0/0`
  - `TCP` `10050-10051` `Группа безопасности` `web-sg`
* Исходящий трафик:
  - `Any` `0-65535` `CIDR` `0.0.0.0/0`

Elasticsearch:
* Имя: `elasticsearch-sg`
* Входящий трафик:
  - `TCP` `9200` `Группа безопасности` `web-sg`
  - `TCP` `9200` `Группа безопасности` `kibana-sg`
* Исходящий трафик:
  - `Any` `0-65535` `CIDR` `0.0.0.0/0`  ------временно
 
Kibana:
* Имя: `kibana-sg`
* Входящий трафик:
  - `TCP` `5601` `CIDR` `0.0.0.0/0`  ------временно
* Исходящий трафик:
  - `Any` `0-65535` `CIDR` `0.0.0.0/0`

Веб-сервер:
* Имя: `web-sg`
* Входящий трафик:
  - `TCP` `22` `Группа безопасности` `bastion-sg`
  - `ICMP` `0-65535` `Группа безопасности` `bastion-sg`
  - `TCP` `80` `Группа безопасности` `alb-sg`
  - `TCP` `10050` `Группа безопасности` `zabbix-sg`
* Исходящий трафик:
  - `Any` `0-65535` `CIDR` `0.0.0.0/0`
  - `TCP` `9200` `Группа безопасности` `elasticsearch-sg`

---
Создадим ssh-ключ для и добавим его в метаданные `web1` и `web2` для подклюбчения с бастиона
```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
```

Устанавливаем на `web1` и `web2` nginx
```bash
ssh 10.10.2.29
sudo apt update
sudo apt install -y nginx
sudo systemctl enable nginx
```
Аналогично и для `web2`.

Настраиваем балансировщик:

Создаём целевую группу `target-group-web`, группу бэкенда `backend-group-web`, создаём HTTP-роутер `http-router-web` и балансировщик `application-load-balancer-web` (важно в чтобы в группе безопасности был разрешен доступ к некоторым сервисам yandex для проверки состояня балансировщика).

### Подготовка zabbix-сервера
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
* Группа безопасности:            `zabbix-sg`

Авторизуемя и ставим [репозиторий](https://www.zabbix.com/download?zabbix=6.0&os_distribution=ubuntu&os_version=22.04&components=server_frontend_agent&db=mysql&ws=apache).
>Буду использовать MySQL для экономии времени, в ином случае пользовался бы PostgreSQL.
```
wget wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_6.0+ubuntu22.04_all.deb
dpkg -i zabbix-release_latest_6.0+ubuntu22.04_all.deb
```
Дальше настроим прпавила безопасности `MariaDB` 
```
sudo mysql_secure_installation
```
И отвечаем на вопросы:
>Setting the root password or using the unix_socket ensures that nobody
>can log into the MariaDB root user without the proper authorisation.
>
>You already have your root account protected, so you can safely answer 'n'.
>
>Switch to unix_socket authentication [Y/n] n
> 
> ... skipping.
>
>You already have your root account protected, so you can safely answer 'n'.
>
>Change the root password? [Y/n] Y
> 
>New password:
> 
>Re-enter new password:
> 
>Password updated successfully!
>Reloading privilege tables..
> ... Success!
>
>
>?By default, a MariaDB installation has an anonymous user, allowing anyone
>to log into MariaDB without having to have a user account created for
>them.  This is intended only for testing, and to make the installation
>go a bit smoother.  You should remove them before moving into a
>production environment.
>
>Remove anonymous users? [Y/n] Y
> 
> ... Success!
>
>Normally, root should only be allowed to connect from 'localhost'.  This
>ensures that someone cannot guess at the root password from the network.
>
>Disallow root login remotely? [Y/n] Y
> 
> ... Success!
>
>By default, MariaDB comes with a database named 'test' that anyone can
>access.  This is also intended only for testing, and should be removed
>before moving into a production environment.
>
>Remove test database and access to it? [Y/n] Y
> 
>Remove test database and access to it? [Y/n] Y
> 
> - Dropping test database...
> ... Success!
> - Removing privileges on test database...
> ... Success!
>
>Reloading the privilege tables will ensure that all changes made so far
>will take effect immediately.
>
>Reload privilege tables now? [Y/n] Y
> 
> ... Success!
>
>Cleaning up...
>All done!  If you've completed all of the above steps, your MariaDB
>installation should now be secure.

Thanks for using MariaDB!

Далее формируем БД и пользователя:
```sql
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY '<пароль>';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
FLUSH PRIVILEGES
```
И импортируем
```bash
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql -u zabbix -p zabbix
```
В файле конфигурации `zabbix_server.conf` задаём пароль и перезпускаем сервис.

---
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
terraform init
nano main.tf
terraform apply
yc vpc subnet list
terraform import yandex_vpc_subnet.private_a e9***********vu
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
cat ~/.ssh/id_rsa.pub

ssh 10.10.2.29
sudo apt update
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl status nginx
exit

ssh 10.10.3.33
sudo apt update
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl status nginx
exit

curl http://<публичный ip нашего alb>

sudo su
wget wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_6.0+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_latest_6.0+ubuntu22.04_all.deb
sudo apt update
sudo mysql -u root -p
```
```sql
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY '<пароль>';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
FLUSH PRIVILEGES;
EXIT
```
```bash
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql -u zabbix -p zabbix
sudo nano /etc/zabbix/zabbix_server.conf
sudo systemctl restart zabbix-server.service
```
