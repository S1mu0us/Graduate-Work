resource "yandex_vpc_security_group" "base_sg" {
  for_each = {
    bastion-sg = {
      description = "bastion"
    }
    web-sg = {
      description = "web1 & web2"
    }
    zabbix-sg = {
      description = "zabbix-machine"
    }
    alb-sg = {
      description = "ALB"
    }
    opensearch-sg = {
      description = "opensearch-machine"
    }
    logstash-sg = {
      description = "logstash-machine"
    }
  }

  name        = each.key
  description = each.value.description
  network_id  = yandex_vpc_network.main.id

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = ""
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "yandex_vpc_security_group_rule" "rules" {
  for_each = local.security_rules

  security_group_binding = yandex_vpc_security_group.base_sg[each.value.target_sg].id
  direction              = each.value.direction
  protocol               = each.value.protocol
  port                   = try(each.value.port, null)
  from_port              = try(each.value.from_port, null)
  to_port                = try(each.value.to_port, null)
  v4_cidr_blocks         = try(each.value.cidr_blocks, null)
  security_group_id      = try(each.value.source_sg_id, null) != null ? yandex_vpc_security_group.base_sg[each.value.source_sg_id].id : null
  description            = each.value.description

  depends_on = [yandex_vpc_security_group.base_sg]
}

locals {
  security_rules = {
    #bastion-sg
    "bastion_ingress_ssh" = {
      target_sg   = "bastion-sg"
      direction   = "ingress"
      protocol    = "TCP"
      port        = 22
      cidr_blocks = ["0.0.0.0/0"]
      description = ""
    },

    #web-sg
    "web_ingress_ssh_from_bastion" = {
      target_sg    = "web-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 22
      source_sg_id = "bastion-sg"
      description  = ""
    },

    "web_ingress_icmp_from_bastion" = {
      target_sg    = "web-sg"
      direction    = "ingress"
      protocol     = "ICMP"
      source_sg_id = "bastion-sg"
      description  = ""
    },

    "web_ingress_http_from_alb" = {
      target_sg    = "web-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 80
      source_sg_id = "alb-sg"
      description  = ""
    },

    "web_ingress_zabbix_agent" = {
      target_sg    = "web-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 10050
      source_sg_id = "zabbix-sg"
      description  = ""
    },

    "web_ingress_logstash_8220" = {
      target_sg    = "web-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 8220
      source_sg_id = "logstash-sg"
      description  = ""
    },

    "web_ingress_logstash_5044" = {
      target_sg    = "web-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 5044
      source_sg_id = "logstash-sg"
      description  = ""
    },

    "web_egress_opensearch" = {
      target_sg    = "web-sg"
      direction    = "egress"
      protocol     = "TCP"
      port         = 9200
      source_sg_id = "opensearch-sg"
      description  = ""
    },

    #zabbix-sg
    "zabbix_ingress_ssh" = {
      target_sg   = "zabbix-sg"
      direction   = "ingress"
      protocol    = "TCP"
      port        = 22
      cidr_blocks = ["0.0.0.0/0"]
      description = ""
    },

    "zabbix_ingress_zabbix_ports_from_web" = {
      target_sg    = "zabbix-sg"
      direction    = "ingress"
      protocol     = "TCP"
      from_port    = 10050
      to_port      = 10051
      source_sg_id = "web-sg"
      description  = ""
    },

    "zabbix_ingress_http" = {
      target_sg   = "zabbix-sg"
      direction   = "ingress"
      protocol    = "TCP"
      port        = 80
      cidr_blocks = ["0.0.0.0/0"]
      description = ""
    },

    #alb-sg
    "alb_ingress_http" = {
      target_sg   = "alb-sg"
      direction   = "ingress"
      protocol    = "TCP"
      port        = 80
      cidr_blocks = ["0.0.0.0/0"]
      description = ""
    },

    "alb_ingress_health_checks" = {
      target_sg   = "alb-sg"
      direction   = "ingress"
      protocol    = "ANY"
      port        = 80
      cidr_blocks = ["198.18.248.0/24", "198.18.254.0/24"]
      description = ""
    },

    "alb_egress_to_web" = {
      target_sg    = "alb-sg"
      direction    = "egress"
      protocol     = "ANY"
      source_sg_id = "web-sg"
      description  = ""
    },

    #opensearch-sg
    "opensearch_ingress_9200_from_web" = {
      target_sg    = "opensearch-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 9200
      source_sg_id = "web-sg"
      description  = ""
    },

    "opensearch_ingress_ssh_from_bastion" = {
      target_sg    = "opensearch-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 22
      source_sg_id = "bastion-sg"
      description  = ""
    },

    "opensearch_ingress_9200_9300_from_logstash" = {
      target_sg    = "opensearch-sg"
      direction    = "ingress"
      protocol     = "TCP"
      from_port    = 9200
      to_port      = 9300
      source_sg_id = "logstash-sg"
      description  = ""
    },

    "opensearch_ingress_icmp_from_logstash" = {
      target_sg    = "opensearch-sg"
      direction    = "ingress"
      protocol     = "ICMP"
      source_sg_id = "logstash-sg"
      description  = ""
    },

    "opensearch_ingress_5044_from_logstash" = {
      target_sg    = "opensearch-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 5044
      source_sg_id = "logstash-sg"
      description  = ""
    },

    "opensearch_egress_to_logstash" = {
      target_sg    = "opensearch-sg"
      direction    = "egress"
      protocol     = "TCP"
      source_sg_id = "logstash-sg"
      description  = ""
    },

    "opensearch_egress_to_bastion" = {
      target_sg    = "opensearch-sg"
      direction    = "egress"
      protocol     = "TCP"
      source_sg_id = "bastion-sg"
      description  = ""
    },

    #logstash-sg
    "logstash_ingress_ssh_from_bastion" = {
      target_sg    = "logstash-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 22
      source_sg_id = "bastion-sg"
      description  = ""
    },

    "logstash_ingress_icmp_from_opensearch" = {
      target_sg    = "logstash-sg"
      direction    = "ingress"
      protocol     = "ICMP"
      source_sg_id = "opensearch-sg"
      description  = ""
    },

    "logstash_ingress_5601_from_opensearch" = {
      target_sg    = "logstash-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 5601
      source_sg_id = "opensearch-sg"
      description  = ""
    },

    "logstash_ingress_9200_from_opensearch" = {
      target_sg    = "logstash-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 9200
      source_sg_id = "opensearch-sg"
      description  = ""
    },

    "logstash_ingress_5044_from_opensearch" = {
      target_sg    = "logstash-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 5044
      source_sg_id = "opensearch-sg"
      description  = ""
    },

    "logstash_ingress_8220_from_web" = {
      target_sg    = "logstash-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 8220
      source_sg_id = "web-sg"
      description  = ""
    },

    "logstash_ingress_5044_from_web" = {
      target_sg    = "logstash-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 5044
      source_sg_id = "web-sg"
      description  = ""
    },

    "logstash_ingress_5601_from_bastion" = {
      target_sg    = "logstash-sg"
      direction    = "ingress"
      protocol     = "TCP"
      port         = 5601
      source_sg_id = "bastion-sg"
      description  = ""
    },
  }
}
