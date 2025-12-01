Устанавливаем репу [OpenSearch](https://opensearch.org/downloads/#data-ingest)
```bash
wget https://artifacts.opensearch.org/releases/bundle/opensearch/3.3.2/opensearch-3.3.2-linux-x64.deb
sudo dpkg -i opensearch-3.3.2-linux-x64.deb
sudo nano /etc/opensearch/opensearch.yml #откроем порты, ноды и другие необходимые параметры
sudo systemctl enable opensearch
sudo systemctl start opensearch
curl http://localhost:9200
```
