Теперь создадим ВМ `elasticsearch-machine` и установим `Elasticsearch`

Характеристики системы: 
* Платформа:                      `Intel Ice Lake`
* Гарантированная доля vCPU:      `20%`
* vCPU:                           `2`
* RAM:                            `4 ГБ`
* Объём дискового пространства:   `10 ГБ`
* Прерываемая:                    `Да`
* ОС:                             `Ubuntu 24.04`
* Внешний IP:                     `Нет`
* Подсеть:                        `private-subnet-b`
* Группа безопасности:            `elasticsearch-sg`

Устанавливаем `java` и `Elasticsearch`
```bash
sudo apt install openjdk-25-jdk -y
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sudo apt-get install apt-transport-https
echo "deb [trusted=yes] https://mirror.yandex.ru/mirrors/elastic/9/ stable main" | sudo tee /etc/apt/sources.list.d/elasticsearch.list
sudo apt update
sudo apt install elasticsearch
```
>Возникли трудности с установкой официальног репозитория Elastic, поэтому использовал [зеркало](https://mirror.yandex.ru/mirrors/elastic) Yandex

Далее залезаем в конфиг `/etc/elasticsearch/elasticsearch.yml` и изменяем параметры:
* Раскомментировать `cluster.name: my-logs-cluster`, `node.name: node-1` и `http.port: 9200`
* Изменить `network.host: 0.0.0.0`
* Добавить `discovery.type: single-node` и закомментировать `cluster.initial_master_nodes:`

Сохраняем, перезапускаем и проверяем elasticsearch.
>Для моей версии 9.* потребовался пароль, чтобы открыть ссылку.

Далее создадим ВМ `kibana-machine` и установим `Kibana`

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
* Группа безопасности:            `kibana-sg`

Скачиваем репозиторий Kibana с [зеркала](https://mirror.yandex.ru/mirrors/elastic/9/pool/main/k/kibana/) Яндекс
```bash
wget https://mirror.yandex.ru/mirrors/elastic/9/pool/main/k/kibana/kibana-9.2.1-amd64.deb
sudo dpkg -i kibana-9.2.1-amd64.deb
```
Идём на `elasticsearch-machine` и создадим там токен для kibana: 
```
sudo /usr/share/elasticsearch/bin/elasticsearch-service-tokens create elastic/kibana kibana-token
```
После залетаем в конфиг kibana.yml, открываем `server.port: 5601` `server.host: "0.0.0.0"` `elasticsearch.hosts: ["https://10.10.3.9:9200"]` `elasticsearch.serviceAccountToken: "AA*********************************0hR"` и `elasticsearch.ssl.verificationMode: none`

>Авторизация по логину и паролю elasticsearch недоступна в версии kibana 9.*

Сохраняем и перезапускаем сервис.

Теперь в Kibana UI устанавливаем Fleet Server, он будет стоять у нас на `kibana-machine`, для этого нужно выбрать нужные параметры на страничке и вбить в консоль с ВМ, но мы идём немного иным путём из-за особенностей сетевой архитектуры и региональных ограничений:

```
wget https://mirror.yandex.ru/mirrors/elastic/9/pool/main/k/kibana/kibana-9.2.1-amd64.deb
sudo dpkg -i kibana-9.2.1-amd64.deb
cd elastic-agent-9.2.1-linux-x86_64
sudo ./elastic-agent install \
  --fleet-server-es=https://10.10.3.9:9200 \
  --fleet-server-service-token=AAEA***********************************FqUQ \
  --fleet-server-policy=fleet-server-policy \
  --fleet-server-port=8220 \
  --fleet-server-es-ca-trusted-fingerprint=6B**************************63 \
  --insecure \
  --install-servers
```

Честно, на этом этапе возникло столько проблем с Elastic, начиная от зомби-процессов, которые неубиваемы из-за политики безопасности и заканчивая багами самого UI и загрузкой через раз, (пробовал через докер, не помогло), поэтому мной было принято решение использовать в качестве альтернативы OpenSearch.
