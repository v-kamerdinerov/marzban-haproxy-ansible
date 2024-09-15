# ЧАВО

- [Как мне зайти в панель управления?](#как-мне-зайти-в-панель-управления)
- [Я хочу активировать документацию доступную по /doc, как мне это сделать?](#я-хочу-активировать-документацию-доступную-по-doc-как-мне-это-сделать)
- [Я хочу сконфигурировать дополнительные ноды для распределения нагрузки, как мне это сделать?](#я-хочу-сконфигурировать-дополнительные-ноды-для-распределения-нагрузки-как-мне-это-сделать)
- [Я хочу использовать warp. Что мне нужно настроить?](#я-хочу-использовать-warp-что-мне-нужно-настроить)
- [Я хочу использовать отдельную базу Mysql, как мне это сделать?](#я-хочу-использовать-отдельную-базу-mysql-как-мне-это-сделать)
- [Я хочу бекапировать все данные marzban, как мне это сделать?](#я-хочу-бекапировать-все-данные-marzban-как-мне-это-сделать)

## Как мне зайти в панель управления?
После прокатки плейбука панель marzban доступна по пути указанному в инвентори `marzban_panel_uri: "panel.{{ marzban_domain }}"`

<img src="./images/dashboard.png" width="1000">

Данные для входа указаны в переменных: 
```yaml
marzban_panel_login: "admin"
marzban_panel_password: "panelpassword"
```


## Я хочу активировать документацию доступную по /doc, как мне это сделать?
Перед деплоем выставить переменную `marzban_docs` в положение `true`

<img src="./images/docs.png" width="1000">

## Я хочу сконфигурировать дополнительные ноды для распределения нагрузки, как мне это сделать?
В первую очередь необходимо заполнить inventory файл [hosts.yml](../hosts.yml.example)

Добавим в него две новые доп ноды и группу хостов `marzban_nodes`
```yaml
        marzban_nodes:
          hosts:
            node1:
              ansible_host: 88.43.44.22
              ansible_port: 22
              marzban_roles:
                - node
            node2:
              ansible_host: 33.167.12.8
              ansible_port: 22
              marzban_roles:
                - node
```

Далее настроить дополнительные CNAME в вашем DNS, дабы были записи для двух новых нод вида:
- `node1.{{ marzban_domain }}`
- `node2.{{ marzban_domain }}`

После этого запускайте плейбук

```shell
ansible-playbook marzban-deploy.yml
```

<img src="./images/nodes.png" width="400">

<img src="./images/host_info.png" width="400">

<img src="./images/configs.png" width="400">

## Я хочу использовать warp. Что мне нужно настроить?
Перед деплоем выставить переменную `marzban_warp` в положение `true`

Заполнить список destination в переменной `marzban_warp_domains`

```yaml
# Traffic filter settings through Cloudflare
marzban_warp_domains:
  - "geosite:openai"
  - "domain:ipinfo.io"
  - "domain:iplocation.net"
  - "domain:spotify.com"
  - "domain:linkedin.com"
```

## Я хочу использовать отдельную базу Mysql, как мне это сделать?

По дефолту в инвентори уже включена такая возможность `marzban_mysql_instance: true`

```
root@main:/opt/marzban# docker ps
CONTAINER ID   IMAGE                     COMMAND                  CREATED          STATUS                    PORTS     NAMES
9cac00a5a838   haproxy:2.4.25            "docker-entrypoint.s…"   23 minutes ago   Up 23 minutes                       marzban-haproxy-1
8623ba69c221   gozargah/marzban:latest   "bash -c 'alembic up…"   23 minutes ago   Up 23 minutes                       marzban-marzban-1
63a539f0ee62   mariadb:lts               "docker-entrypoint.s…"   23 minutes ago   Up 23 minutes (healthy)             marzban-mariadb-1
```

## Я хочу бекапировать все данные marzban, как мне это сделать?

По дефолту в инвентори уже включена такая возможность `marzban_backup: true`.

Периодичность сохранения конфигурируется в переменной `marzban_backup_cron`.

```
/var/lib/marzban_backups/backup_${DATE}/
├── lib
│   ├── access.log
│   ├── certs
│   │   ├── example-domain.com.cert
│   │   └── example-domain.com.key
│   ├── error.log
│   └── xray_config.json
│   └── db.sqlite3
└── opt
    ├── credentials
    │   ├── pass_marzban_mysql_root_password
    │   ├── pass_marzban_mysql_user_password
    │   └── x25519_key
    └── docker-compose.yml
```

Крон джоба каждый день сохраняет все ваши данные по пути в:
```/var/lib/marzban_backups/```

Если у вас есть отдельны инстанс СУБД, джоба так же сделает дамп данной БД:

```
/var/lib/marzban_backups/backup_${date}/db-backup/
└── marzban.sql
```

Так же, если вы заполните переменные `marzban_backup_telegram_bot_token`  и `marzban_backup_telegram_chat_id`  бекап будет отправлен вам в чат.

<img src="./images/backup_telegram.png" width="400">
