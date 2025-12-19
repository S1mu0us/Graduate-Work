resource "yandex_compute_snapshot_schedule" "daily_backup" {
  name        = "snapshots"
  description = "Резервное копирование"

  #Расписание
  schedule_policy {
    expression = "0 3 * * *"
  }

  retention_period = "168h"

  disk_ids = [
    yandex_compute_instance.bastion.boot_disk[0].disk_id,
    yandex_compute_instance.web1.boot_disk[0].disk_id,
    yandex_compute_instance.web2.boot_disk[0].disk_id,
    yandex_compute_instance.zabbix_machine.boot_disk[0].disk_id,
    yandex_compute_instance.opensearch_machine.boot_disk[0].disk_id,
    yandex_compute_instance.logstash_machine.boot_disk[0].disk_id,
  ]

  snapshot_spec {
    description = "Автоматический снапшот по расписанию"
  }

  folder_id = var.folder_id

  labels = {
    environment = "production"
    backup      = "daily"
    managed-by  = "terraform"
  }
}
