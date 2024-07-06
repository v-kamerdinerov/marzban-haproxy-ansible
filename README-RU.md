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

Этот репозиторий облегчит настройку VPS-серверов с нуля до полностью рабочего готового к эксплуатации решения для анонимизации - Marzban.

Marzban - это инструмент управления прокси-серверами, который предоставляет простой и удобный пользовательский интерфейс для управления сотнями прокси-аккаунтов на базе Xray. [Подробнее](https://github.com/Gozargah/Marzban).

## Особенности

* Полностью автоматическая подготовка и установка на пустые сервера
* Конфигурация для main нод и для отдельных дополнительных node
* Возможность смены SSH порта полностью в автоматическом режиме
* Конфигурация системных лимитов, sysctl
* Вариативная установка xanmod с твиком BBR3
* Вариативная установка WARP
* Автоматическое закрытие всех портов, кроме:
```shell
* SSH(включая кастомный) 
* web based (80/443)
* marzban node-api
```




## Пререквизиты

* Виртуальная машина на базе Ubuntu 20/22.
* Доменное имя
* Ansible 2.14.1 или выше

## Подготовка

Заполните инвентори файл [hosts.yml](./hosts.yml) используя данные своих ВМ:

    
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

В конфигурационном файле [ansible.cfg](./ansible.cfg) заполните данные о подключении:

```commandline
remote_user = ubuntu
private_key_file = /path/to/private.key
```

## Конфигурация

* `./group_vars/marzban/marzban.yml` - универсальные, общие переменные для всех используемых узлов. (домен, sni, общие настройки)

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

* `./group_vars/marzban_main/main.yml` - общие переменные для каждого из узлов - главные узлы с основной панелью и узлы-миньоны, используемые для расширения.

```yaml
# firewall
common_open_ports:
  - "80"
  - "443"
```

## Хватит уже, бегом к делу



```shell
ansible-playbook marzban-deploy.yml
```