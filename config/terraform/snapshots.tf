resource "yandex_compute_snapshot_schedule" "daily_backup" {
  name        = "snapshots"
  description = "Резервное копирование"

  #Расписание
  schedule_policy {
    expression = "0 3 * * *"
  }

  retention_period = "168h"

  disk_ids = [
    "disk-ubuntu-24-04-lts-1763484537429",
    "disk-ubuntu-24-04-lts-1763484725825",
    "disk-ubuntu-24-04-lts-1763903413523",
    "disk-ubuntu-24-04-lts-1762529299424",
    "disk-ubuntu-24-04-lts-1764067604498",
    "disk-ubuntu-24-04-lts-1764012294949",
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
