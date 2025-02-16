# Terraform скрипт

## Задание

1. Подготовка окружения:

    - Убедитесь, что **Terraform** установлен на вашей локальной машине или в окружении, где вы будете работать.
    - Настройте доступ к облачному провайдеру, создав учетные данные и добавив их в **Terraform**.

2. Создание **Terraform** файла:

    - Создайте новый файл `main.tf`.
    - Определите провайдера, который вы будете использовать, и укажите учетные данные для доступа к нему.
    - Настройте ресурс для виртуальной машины.

3. Настройка инфраструктуры:

    - Укажите параметры для виртуальной машины: тип, регион, операционную систему и конфигурацию сети.
    - Добавьте секцию **output**, которая покажет IP-адрес созданной виртуальной машины после выполнения скрипта.

4. Инициализация и запуск:

    - Запустите команду `terraform init` для инициализации проекта.
    - Проверьте корректность кода командой `terraform plan`.
    - Запустите `terraform apply`, чтобы создать виртуальную машину.

5. Проверка результата:

    - Убедитесь, что виртуальная машина создана, и вы получили ее IP-адрес.
    - Подключитесь к машине по SSH для подтверждения ее доступности.

6. Документация:

    - Опишите процесс создания скрипта и конфигурации.
    - Укажите инструкции по воспроизведению.

## Реализация

Скрипт состоит из нескольких файлов:

- [terraform.tf](terraform.tf) - содержит список используемых провайдеров и их версии;
- [providers.tf](providers.tf) - содержит настройки провайдера **Yandex Cloud**;
- [variables.tf](variables.tf) - содержит описания используемых переменных;
- [outputs.tf](outputs.tf) - содержит код, возвращающий IP адреса создаваемых машин;
- [main.tf](main.tf) - содержит описания создаваемых машин.

Также написаны шаблоны:

- [cloud-config.tftpl](cloud-config.tftpl) - конфигурация **cloud init** для создаваемых машин;
- [inventory.tftpl](inventory.tftpl) - шаблон инвентартного файла `inventory.yml` для **ansible**;

Помимо этого написаны скрпипты для автоматизации запуска:

- [update-tfvars.sh](update-tfvars.sh) - генерирует SSH ключ `secrets/yandex-cloud` для подключения к машине создаёт файл секретов `terraform.tfvars` на основании переменных, указанных в скрипте:

  - **PROJECT** - название проекта (имена для виртуальных машин);
  - **ZONE** - используемая зона в **Yandex Cloud**;
  - **TOKEN** - токен для подключения к **Yandex Cloud**;
  - **CLOUD_ID** - идентификатор облака;
  - **FOLDER_ID** - идентификатор каталога;
  - **SSH_USERNAME** - имя пользователя администратора (`ansible`);
  - **SSH_KEY_FILE** - путь к **SSH** ключю для подключения к машине.

- [provision.sh](provision.sh) - запускает `ansible-playbook provision.yml`;
- [up.sh](up.sh) - выполняет все действия, необходимые для создания и настройки машины:

  - [update-tfvars.sh](update-tfvars.sh);
  - `terraform init`
  - `terraform plan`
  - `terraform apply -auto-approve`
  - [provision.sh](provision.sh)

Файл `provision.yml` в свою очередь запускает две роли:

- **wait_connection** - ожидает доступности машин;
- **nginx** - устанавливает nginx.

Общие переменные для **ansible** находятся в [group_vars/all.yml](group_vars/all.yml).

По умолчанию **yandex_compute_instance** используется значение **standard-v1** для атрибута **platform_id**, однако оно недопустимо для зоны **ru-central1-d**, поэтому необходимо явно задавать это значение в **standard-v2** или **standard-v3** для этой зоны.

## Запуск

1. Необходимо установить и настроить утилиту **yc** по инструкции [Начало работы с интерфейсом командной строки](https://yandex.cloud/ru/docs/cli/quickstart).
2. Необходимо установить **Terraform** по инструкции [Начало работы с Terraform](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart).
3. Необходимо установить **Ansible**.
4. Необходимо перейти в папку проекта и запустить скрипт [up.sh](up.sh).

Протестировано в **OpenSUSE Tumbleweed**:

- **Ansible 2.18.2**
- **Python 3.11.11**
- **Jinja2 3.1.5**

## Проверка

Запустим скрипт [up.sh](up.sh):

```text
❯ ./up.sh
Initializing the backend...
Initializing provider plugins...
- Finding yandex-cloud/yandex versions matching "0.138.0"...
- Finding hashicorp/local versions matching "2.5.2"...
- Installing yandex-cloud/yandex v0.138.0...
- Installed yandex-cloud/yandex v0.138.0 (unauthenticated)
- Installing hashicorp/local v2.5.2...
- Installed hashicorp/local v2.5.2 (unauthenticated)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

╷
│ Warning: Incomplete lock file information for providers
│
│ Due to your customized provider installation methods, Terraform was forced to calculate lock file checksums locally for the following
│ providers:
│   - hashicorp/local
│   - yandex-cloud/yandex
│
│ The current .terraform.lock.hcl file only includes checksums for linux_amd64, so Terraform running on another platform will fail to
│ install these providers.
│
│ To calculate additional checksums for another platform, run:
│   terraform providers lock -platform=linux_amd64
│ (where linux_amd64 is the platform to generate)
╵
Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
data.yandex_compute_image.ubuntu2404: Reading...
data.yandex_compute_image.ubuntu2404: Read complete after 0s [id=fd85hkli5dp6as39ali4]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.inventory will be created
  + resource "local_file" "inventory" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./inventory.yml"
      + id                   = (known after apply)
    }

  # yandex_compute_instance.default[0] will be created
  + resource "yandex_compute_instance" "default" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hardware_generation       = (known after apply)
      + hostname                  = "nginx-01"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "install-unified-agent" = "0"
          + "serial-port-enable"    = "0"
          + "user-data"             = <<-EOT
                #cloud-config
                datasource:
                 Ec2:
                  strict_id: false
                ssh_pwauth: no
                users:
                - name: ansible
                  sudo: ALL=(ALL) NOPASSWD:ALL
                  shell: /bin/bash
                  ssh_authorized_keys:
                  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmP84KKx4IPFlprEN8O06HcHNyCrnufDfV+6fc7ujrp terraform
            EOT
        }
      + name                      = "nginx-01"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v3"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd85hkli5dp6as39ali4"
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + metadata_options (known after apply)

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 1
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.default[1] will be created
  + resource "yandex_compute_instance" "default" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hardware_generation       = (known after apply)
      + hostname                  = "nginx-02"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "install-unified-agent" = "0"
          + "serial-port-enable"    = "0"
          + "user-data"             = <<-EOT
                #cloud-config
                datasource:
                 Ec2:
                  strict_id: false
                ssh_pwauth: no
                users:
                - name: ansible
                  sudo: ALL=(ALL) NOPASSWD:ALL
                  shell: /bin/bash
                  ssh_authorized_keys:
                  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmP84KKx4IPFlprEN8O06HcHNyCrnufDfV+6fc7ujrp terraform
            EOT
        }
      + name                      = "nginx-02"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v3"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd85hkli5dp6as39ali4"
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + metadata_options (known after apply)

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 1
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_vpc_network.default will be created
  + resource "yandex_vpc_network" "default" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "nginx"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.default will be created
  + resource "yandex_vpc_subnet" "default" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "nginx-ru-central1-d"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.130.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_ips = {
      + nginx-01 = (known after apply)
      + nginx-02 = (known after apply)
    }

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform
apply" now.
data.yandex_compute_image.ubuntu2404: Reading...
data.yandex_compute_image.ubuntu2404: Read complete after 0s [id=fd85hkli5dp6as39ali4]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.inventory will be created
  + resource "local_file" "inventory" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./inventory.yml"
      + id                   = (known after apply)
    }

  # yandex_compute_instance.default[0] will be created
  + resource "yandex_compute_instance" "default" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hardware_generation       = (known after apply)
      + hostname                  = "nginx-01"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "install-unified-agent" = "0"
          + "serial-port-enable"    = "0"
          + "user-data"             = <<-EOT
                #cloud-config
                datasource:
                 Ec2:
                  strict_id: false
                ssh_pwauth: no
                users:
                - name: ansible
                  sudo: ALL=(ALL) NOPASSWD:ALL
                  shell: /bin/bash
                  ssh_authorized_keys:
                  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmP84KKx4IPFlprEN8O06HcHNyCrnufDfV+6fc7ujrp terraform
            EOT
        }
      + name                      = "nginx-01"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v3"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd85hkli5dp6as39ali4"
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + metadata_options (known after apply)

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 1
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.default[1] will be created
  + resource "yandex_compute_instance" "default" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hardware_generation       = (known after apply)
      + hostname                  = "nginx-02"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "install-unified-agent" = "0"
          + "serial-port-enable"    = "0"
          + "user-data"             = <<-EOT
                #cloud-config
                datasource:
                 Ec2:
                  strict_id: false
                ssh_pwauth: no
                users:
                - name: ansible
                  sudo: ALL=(ALL) NOPASSWD:ALL
                  shell: /bin/bash
                  ssh_authorized_keys:
                  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmP84KKx4IPFlprEN8O06HcHNyCrnufDfV+6fc7ujrp terraform
            EOT
        }
      + name                      = "nginx-02"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v3"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd85hkli5dp6as39ali4"
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + metadata_options (known after apply)

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy (known after apply)

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 1
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_vpc_network.default will be created
  + resource "yandex_vpc_network" "default" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "nginx"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.default will be created
  + resource "yandex_vpc_subnet" "default" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "nginx-ru-central1-d"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.130.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_ips = {
      + nginx-01 = (known after apply)
      + nginx-02 = (known after apply)
    }
yandex_vpc_network.default: Creating...
yandex_vpc_network.default: Creation complete after 2s [id=enpa93pjio3perhaaquo]
yandex_vpc_subnet.default: Creating...
yandex_vpc_subnet.default: Creation complete after 1s [id=fl867jccbsu0njq0ahlj]
yandex_compute_instance.default[1]: Creating...
yandex_compute_instance.default[0]: Creating...
yandex_compute_instance.default[0]: Still creating... [10s elapsed]
yandex_compute_instance.default[1]: Still creating... [10s elapsed]
yandex_compute_instance.default[1]: Still creating... [20s elapsed]
yandex_compute_instance.default[0]: Still creating... [20s elapsed]
yandex_compute_instance.default[1]: Still creating... [30s elapsed]
yandex_compute_instance.default[0]: Still creating... [30s elapsed]
yandex_compute_instance.default[1]: Creation complete after 40s [id=fv46jt7k096kq80salkc]
yandex_compute_instance.default[0]: Still creating... [40s elapsed]
yandex_compute_instance.default[0]: Creation complete after 44s [id=fv4c7aekos80b9l7qasi]
local_file.inventory: Creating...
local_file.inventory: Creation complete after 0s [id=3ca2f0e4d4c55ed786cfa281b0010c548a3e28e1]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

instance_ips = {
  "nginx-01" = "158.160.130.241"
  "nginx-02" = "158.160.146.32"
}

PLAY [Wait for connection] ******************************************************************************************************************

TASK [wait_connection : Wait 600 seconds for target connection to become reachable/usable] **************************************************
ok: [nginx-01]
ok: [nginx-02]

TASK [nginx : Install nginx] ****************************************************************************************************************
The following additional packages will be installed:
  nginx-common
Suggested packages:
  fcgiwrap nginx-doc ssl-cert
The following NEW packages will be installed:
  nginx nginx-common
0 upgraded, 2 newly installed, 0 to remove and 15 not upgraded.
changed: [nginx-01]
The following additional packages will be installed:
  nginx-common
Suggested packages:
  fcgiwrap nginx-doc ssl-cert
The following NEW packages will be installed:
  nginx nginx-common
0 upgraded, 2 newly installed, 0 to remove and 15 not upgraded.
changed: [nginx-02]

PLAY RECAP **********************************************************************************************************************************
nginx-01                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
nginx-02                   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Как видно машины создались, **ansible** к ним подключился и **nginx** установился. Проверим адреса машин:

```text
❯ terraform output
instance_ips = {
  "nginx-01" = "158.160.130.241"
  "nginx-02" = "158.160.146.32"
}
```

Можно дополнительно проверить, что указанные адреса открываются:

```text
❯ curl 158.160.130.241
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

❯ curl 158.160.146.32
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

Всё успешно работает, можно удалить машины через `terraform destory`.
