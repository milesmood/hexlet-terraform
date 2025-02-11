resource "yandex_vpc_network" "net" {
  name = "tfhexlet"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "tfhexlet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.192.0/24"]
}

/* resource "yandex_mdb_postgresql_cluster" "dbcluster" {
  name        = "tfhexlet"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.net.id

  config {
    version = var.yc_postgresql_version
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 15
    }
    postgresql_config = {
      max_connections    = 100
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 12
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.subnet.id
  }

  depends_on  = [yandex_vpc_network.net, yandex_vpc_subnet.subnet]
} */

/* resource "yandex_mdb_postgresql_user" "dbuser" {
  cluster_id = yandex_mdb_postgresql_cluster.dbcluster.id
  name       = var.db_user
  password   = var.db_password
  depends_on = [yandex_mdb_postgresql_cluster.dbcluster]
}

resource "yandex_mdb_postgresql_database" "db" {
  cluster_id = yandex_mdb_postgresql_cluster.dbcluster.id
  name       = var.db_name
  owner      = yandex_mdb_postgresql_user.dbuser.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  depends_on = [yandex_mdb_postgresql_cluster.dbcluster]
} */

resource "yandex_compute_instance" "vm" {
  name        = "tfhexlet"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.img.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
    #!/bin/bash
    #echo 'export DB_HOST="${module.yandex-postgresql.cluster_fqdns_list[0].0}"' >> /etc/environment
    EOF
    ssh-keys = "ubuntu:${file("~/.ssh/ssh-key.pub")}"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/ssh-key")
    host        = self.network_interface[0].nat_ip_address
  }

  provisioner "remote-exec" {
  inline = [
<<EOT
sudo docker run -d -p 0.0.0.0:80:3000 \
  -e DB_TYPE=postgres \
  -e DB_NAME=${module.yandex-postgresql.databases[0]} \
  -e DB_HOST=${module.yandex-postgresql.cluster_fqdns_list[0].0} \
  -e DB_PORT=6432 \
  -e DB_USER=${module.yandex-postgresql.owners_data[0].user} \
  -e DB_PASS=${module.yandex-postgresql.owners_data[0].password} \
  ghcr.io/requarks/wiki:2.5
EOT
    ]
  }
  depends_on = [module.yandex-postgresql]
  //depends_on  = [yandex_mdb_postgresql_cluster.dbcluster]
}