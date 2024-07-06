# marzban-haproxy-ansible

![GitHub CI Status](https://github.com/v-kamerdinerov/marzban-haproxy-ansible/actions/workflows/linter.yml/badge.svg)
![GitHub](https://img.shields.io/github/license/v-kamerdinerov/marzban-haproxy-ansible)

<p align="center">
 <a href="./README.md">
 English
 </a>
 /
 <a href="./README-RU.md">
 Русский
 </a>
</p>

This repository will contain the configuration of VPS servers from scratch, to a fully working production ready solution for anonymization - Marzban.

Marzban is a proxy management tool that provides a simple and easy-to-use user interface for managing hundreds of proxy accounts powered by Xray-core. [More](https://github.com/Gozargah/Marzban).

## Features

* Fully automatic preparation and installation on fresh vps servers
* Configuration for main nodes and for individual additional nodes
* Ability to change SSH port fully automatically
* Configuration of system limits, sysctl
* Variable installation of xanmod kernel with BBR3 tweak
* Variable installation of warp
* Blocking of all ports except SSH (including custom), web based (80/443) and those used for marzban node-api.
* and more

## Requirements

* Linux VPS servers with Ubuntu 20/22 installed.
* Own a domain name
* Ansible 2.14.1 or higher

## Preparation

Make an inventory file [hosts.yml](./hosts.yml) using the data from your VPS:

    
```yaml
---
all:
  children:
    marzban:
      children:
        marzban_main:
          hosts:
            main:
              ansible_host: 66.77.44.33
              ansible_port: 22
              marzban_roles:
                - panel
        marzban_nodes:
          hosts:
            node1:
              ansible_host: 88.43.44.22
              ansible_port: 22
              marzban_roles:
                - node
```

In [ansible.cfg](./ansible.cfg) fill out next following lines:

```commandline
remote_user = ubuntu
private_key_file = /path/to/private.key
```

## Configuration

* `./group_vars/marzban/marzban.yml` - universal, common variables for all nodes used. (domain, sni, common settings)

```yaml
# Основной домен используемых для панели
marzban_domain: example.com

# Сетевое имя под которые будем сообщать при обращен
marzban_sni: "vk.com"

# Ваш адрес электронной почты
email: foo@bar

# Часовой пояс
common_timezone: "Europe/Moscow"
```

* `./group_vars/marzban_main/main.yml` - common variables for each of the nodes - main nodes with the main panel, and minion nodes used for expansion.

```yaml
# firewall
common_open_ports:
  - "80"
  - "443"
```

## I'm tired wait, go go go



```shell
ansible-playbook marzban-deploy.yml
```