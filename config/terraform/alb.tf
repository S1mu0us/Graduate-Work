#Целевая группа
resource "yandex_alb_target_group" "target_group_web" {
  name = "target-group-web"

  target {
    subnet_id  = yandex_vpc_subnet.subnets["private-subnet-a"].id
    ip_address = yandex_compute_instance.web1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.subnets["private-subnet-b"].id
    ip_address = yandex_compute_instance.web2.network_interface.0.ip_address
  }
}

#HTTP-router
resource "yandex_alb_http_router" "http_router_web" {
  name = "http-router-web"
}

#router-host
resource "yandex_alb_virtual_host" "virtual_host_web" {
  name           = "virtual-host-web"
  http_router_id = yandex_alb_http_router.http_router_web.id

  route {
    name = "route-web"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend_web.id
      }
    }
  }
}

#Группа бэкендов
resource "yandex_alb_backend_group" "backend_web" {
  name = "backend-web"

  http_backend {
    name             = "http-backend-web"
    port             = 80
    target_group_ids = [yandex_alb_target_group.target_group_web.id]

    healthcheck {
      timeout             = "1s"
      interval            = "2s"
      healthy_threshold   = 2
      unhealthy_threshold = 2

      http_healthcheck {
        path = "/"
      }
    }

    load_balancing_config {
      panic_threshold = 50
    }
  }
}

#Application Load Balancer
resource "yandex_alb_load_balancer" "application_load_balancer_web" {
  name               = "application-load-balancer-web"
  network_id         = yandex_vpc_network.main.id
  security_group_ids = [yandex_vpc_security_group.base_sg["alb-sg"].id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnets["public-subnet"].id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {

        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.http_router_web.id
      }
    }
  }
}
