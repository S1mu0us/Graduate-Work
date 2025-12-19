#web1
resource "yandex_compute_instance" "web1" {
  name        = "web1"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd81gsj7pb9oi8ks3cvo"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnets["private-subnet-a"].id
    ip_address         = "10.10.2.29"
    nat                = false
    security_group_ids = [yandex_vpc_security_group.base_sg["web-sg"].id]
  }

  metadata = {
    ssh-keys = "vmadmin:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

#web2
resource "yandex_compute_instance" "web2" {
  name        = "web2"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd81gsj7pb9oi8ks3cvo"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnets["private-subnet-b"].id
    ip_address         = "10.10.3.33"
    nat                = false
    security_group_ids = [yandex_vpc_security_group.base_sg["web-sg"].id]
  }

  metadata = {
    ssh-keys = "vmadmin:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

#zabbix-machine
resource "yandex_compute_instance" "zabbix_machine" {
  name        = "zabbix-machine"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd81gsj7pb9oi8ks3cvo"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnets["public-subnet"].id
    ip_address         = "10.10.1.26"
    nat                = true
    security_group_ids = [yandex_vpc_security_group.base_sg["zabbix-sg"].id]
  }

  metadata = {
    ssh-keys = "vmadmin:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

#opensearch-machine
resource "yandex_compute_instance" "opensearch_machine" {
  name        = "opensearch-machine"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 8
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd81gsj7pb9oi8ks3cvo"
      size     = 30
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnets["private-subnet-b"].id
    ip_address         = "10.10.3.9"
    nat                = false
    security_group_ids = [yandex_vpc_security_group.base_sg["opensearch-sg"].id]
  }

  metadata = {
    ssh-keys = "vmadmin:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}

#logstash-machine
resource "yandex_compute_instance" "logstash_machine" {
  name        = "logstash-machine"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd81gsj7pb9oi8ks3cvo"
      size     = 20 # 20GB
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnets["private-subnet-b"].id
    ip_address         = "10.10.3.11"
    nat                = false
    security_group_ids = [yandex_vpc_security_group.base_sg["logstash-sg"].id]
  }

  metadata = {
    ssh-keys = "vmadmin:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }
}
