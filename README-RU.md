# marzban-haproxy-ansible

![GitHub CI Status](https://github.com/v-kamerdinerov/marzban-haproxy-ansible/actions/workflows/linter.yml/badge.svg)
![GitHub](https://img.shields.io/github/license/v-kamerdinerov/marzban-haproxy-ansible)
[![GitHub tag](https://img.shields.io/github/tag/v-kamerdinerov/marzban-haproxy-ansible.svg)](https://github.com/v-kamerdinerov/marzban-haproxy-ansible/tags)

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

Этот репозиторий облегчит настройку VPS-серверов с нуля до полностью рабочего готового к эксплуатации решения для анонимизации - Marzban.

Marzban - это инструмент управления прокси-серверами, который предоставляет простой и удобный пользовательский интерфейс для управления сотнями прокси-аккаунтов на базе Xray. [Подробнее](https://github.com/Gozargah/Marzban).

## Особенности

* Полностью автоматическая подготовка и установка на пустые сервера
* Конфигурация для main нод и для отдельных дополнительных node
* Возможность смены SSH порта полностью в автоматическом режиме
* Конфигурация системных лимитов, sysctl
* Вариативная установка вместе с отдельным инстансом СУБД MariaDB `(default == true)`
* Вариативная установка xanmod с твиком BBR3 `(default == true)`
* Вариативная установка WARP `(default == false)`
* Автоматическое закрытие всех портов, кроме:
```shell
* SSH(включая кастомный) 
* web based (80/443)
* marzban node-api
```




## Пререквизиты

* Виртуальная машина на базе Ubuntu 20/22/24.
* Доменное имя

Eсли вы используете дополнительный ноды, важно чтобы доменное имя соответствовало следующему паттерну `{{ inventory_hostname }}.{{ marzban_domain }}`

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

Основная настройка производиться в `group_vars` ansible.

**ВНИМАНИЕ** Внимательно относитесь к заполнению переменных, каждая из них задокументирована и это очень важно для правильной работы после выкатки плейбука.

* `./group_vars/marzban/marzban.yml` - универсальные, общие переменные для всех используемых узлов. (домен, sni, общие настройки)

Пример:
```yaml
# Main domain for the Marzban panel/reality
marzban_domain: example-domain.com

...

# SNI for traffic masking
marzban_sni: "discord.com"

...

# Time zone configuration
common_timezone: "Europe/Moscow"
```

* `./group_vars/marzban_main/main.yml` / `./group_vars/marzban_nodes/main.yml` - общие переменные для каждого из узлов - главные узлы с основной панелью и узлы-миньоны, используемые для расширения. Конфигурировать не требуется.

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


## Ответы на вопросы
[ЧаВо](./doc/FAQ-RU.md).


### Сделать на будущее 
* ~~Добавить возможность использования отдельного инстанса СУБД MySQL/MariaDB~~
* Добавить возможность автоматической генерации сертификата Lets Encrypt при его отсутствии в инвентори
* Добавить новые вариативные инбауды, Trojan, Vmess и так далее
* ~~Добавить автоматические скрипты бекапа~~
* Добавить автоматический поиск наилучшего SNI в зависимости от региона
* Поправить известные проблемы :)

### Известные проблемы
[Issues](./issues.md)