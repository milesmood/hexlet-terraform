module "yandex-postgresql" {
  source      = "github.com/terraform-yc-modules/terraform-yc-postgresql?ref=1.0.2"
  network_id  = yandex_vpc_network.net.id
  name        = "tfhexlet"
  description = "Single-node PostgreSQL cluster for test purposes"

  hosts_definition = [
    {
      zone             = "ru-central1-a"
      assign_public_ip = false
      subnet_id        = yandex_vpc_subnet.subnet.id
    }
  ]

  postgresql_config = {
    max_connections = 100
  }

  databases = [
    {
      name       = "hexlet"
      owner      = var.db_user
      lc_collate = "ru_RU.UTF-8"
      lc_type    = "ru_RU.UTF-8"
      extensions = ["uuid-ossp", "xml2"]
    },
    {
      name       = "hexlet-test"
      owner      = var.db_user
      lc_collate = "ru_RU.UTF-8"
      lc_type    = "ru_RU.UTF-8"
      extensions = ["uuid-ossp", "xml2"]
    }
  ]

  owners = [
    {
      name       = var.db_user
      conn_limit = 15
    }
  ]

  users = [
    {
      name        = "guest"
      conn_limit  = 30
      permissions = ["hexlet"]
      settings = {
        pool_mode                   = "transaction"
        prepared_statements_pooling = true
      }
    }
  ]
}