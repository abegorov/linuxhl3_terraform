
data "yandex_compute_image" "ubuntu2404" {
  family = "ubuntu-2404-lts-oslogin"
}
resource "yandex_vpc_network" "default" {
  name = var.project
}
resource "yandex_vpc_subnet" "default" {
  name           = "${var.project}-${var.zone}"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.130.0.0/24"]
}
resource "yandex_compute_instance" "default" {
  count       = 2
  name        = format("%s-%02d", "${var.project}", count.index + 1)
  hostname    = format("%s-%02d", "${var.project}", count.index + 1)
  platform_id = "standard-v3"
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu2404.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }
  metadata = {
    install-unified-agent = 0
    serial-port-enable    = 0
    user-data = templatefile("${path.module}/cloud-config.tftpl", {
      username   = var.ssh_username,
      public_key = file(format("%s.pub", var.ssh_key_file))
    })
  }
}
resource "local_file" "inventory" {
  filename = "${path.root}/inventory.yml"
  content = templatefile("${path.module}/inventory.tftpl", {
    ssh_username = var.ssh_username,
    ssh_key_file = var.ssh_key_file,
    groups = [
      {
        name  = "${var.project}"
        hosts = yandex_compute_instance.default
      },
    ],
  })
}
