# marzban-haproxy-ansible

![GitHub CI Status](https://github.com/v-kamerdinerov/marzban-haproxy-ansible/actions/workflows/linter.yml/badge.svg)
![GitHub](https://img.shields.io/github/license/v-kamerdinerov/marzban-haproxy-ansible)

----

<p align="center"><img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=600&pause=1000&center=true&vCenter=true&width=435&lines=Automated.+Easy.+Secure." alt="Typing SVG" /></p>

----

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
* Variable installation of xanmod kernel with BBR3 tweak `(default == true)`
* Variable installation of warp `(default == false)`
* Blocking of all ports except SSH (including custom), web based (80/443) and those used for marzban node-api.
* and more

## Requirements

* Linux VPS servers with Ubuntu 20/22/24 installed.
* Own a domain name

If you are using an additional node, it is important that the domain name matches the following pattern `{{ inventory_hostname }}.{{ marzban_domain }}`.

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

The basic configuration is done in `group_vars` ansible.

**WARNING** Be careful how you fill in the variables, each of them is documented and it is very important for proper operation after the playbook is rolled out.

* `./group_vars/marzban/marzban.yml` - universal, common variables for all nodes used. (domain, sni, common settings)

Example:
```yaml
# Main domain used for the panel/reality
marzban_domain: example-domain.com

...

# Network name for masking traffic
marzban_sni: "discord.com"

...

# Time zone
common_timezone: "Europe/Moscow"
```

* `./group_vars/marzban_main/main.yml` / `./group_vars/marzban_nodes/main.yml` - common variables for each of the nodes - main nodes with the main panel, and minion nodes used for expansion. No configuration is required.

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


## FAQ
[FAQ](./doc/FAQ.md)


### ToDo / Plans
- [] Adding the ability to use a separate MySQL/MariaDB DB instance
* Adding possibility to automatically generate Lets Encrypt certificate if it is not present in the inventory
* Adding new variate inbound like Trojan, Vmess etc
* Adding automatic backup scripts
* Fix known issues :)

### Known issues
[Issues](./issues.md)