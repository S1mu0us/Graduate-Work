Устанавливаем репу [OpenSearch](https://opensearch.org/downloads/#data-ingest)
```bash
wget https://artifacts.opensearch.org/releases/bundle/opensearch/3.3.2/opensearch-3.3.2-linux-x64.deb
sudo dpkg -i opensearch-3.3.2-linux-x64.deb
sudo nano /etc/opensearch/opensearch.yml #откроем порты, ноды и другие необходимые параметры
sudo systemctl enable opensearch
sudo systemctl start opensearch
curl http://localhost:9200
```
Пробрасываем порт `5601`
```shell
ssh -L 127.0.0.1:5601:10.10.3.11:5601 vmadmin@<ip-graduate-work-vm>
```
Провёл манипуляции с отключением режима безопасности в opensearch, чтобы не мучаться с сертификатами.
