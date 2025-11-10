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

---

### Полный код
```
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
