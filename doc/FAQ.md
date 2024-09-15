# FAQ

- [How do I access the control panel?](#how-do-i-access-the-control-panel)
- [I want to enable the documentation available at /doc, how do I do that?](#i-want-to-enable-the-documentation-available-at-doc-how-do-i-do-that)
- [I want to configure additional nodes for load balancing, how do I do that?](#i-want-to-configure-additional-nodes-for-load-balancing-how-do-i-do-that)
- [I want to use warp. What do I need to configure?](#i-want-to-use-warp-what-do-i-need-to-configure)
- [I want to use a separate Mysql database, how do I do that?](#i-want-to-use-a-separate-mysql-database-how-do-i-do-that)
- [I want backup all my marzban data, how do I do this?](#i-want-backup-all-my-marzban-data-how-do-i-do-this)

## How do I access the control panel?
After running the playbook, the Marzban panel is available at the path specified in the inventory `marzban_panel_uri: "panel.{{ marzban_domain }}"`

<img src="./images/dashboard.png" width="1000">

Login credentials are specified in the variables:
```yaml
marzban_panel_login: "admin"
marzban_panel_password: "panelpassword"
```


## I want to enable the documentation available at /doc, how do I do that?
Set the variable `marzban_docs` to `true` before deployment

<img src="./images/docs.png" width="1000">

## I want to configure additional nodes for load balancing, how do I do that?
First, you need to fill in the inventory file [hosts.yml](../hosts.yml.example)

Let's add two new nodes and a group of hosts `marzban_nodes` to it
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

Next, configure additional CNAME records in your DNS to have records for the two new nodes:
- `node1.{{ marzban_domain }}`
- `node2.{{ marzban_domain }}`

After this, run the playbook

```shell
ansible-playbook marzban-deploy.yml
```

<img src="./images/nodes.png" width="400">

<img src="./images/host_info.png" width="400">

<img src="./images/configs.png" width="400">

## I want to use warp. What do I need to configure?
Set the variable `marzban_warp` to `true` before deployment

Fill in the destination list in the variable `marzban_warp_domains`

```yaml
# Traffic filter settings through Cloudflare
marzban_warp_domains:
  - "geosite:openai"
  - "domain:ipinfo.io"
  - "domain:iplocation.net"
  - "domain:spotify.com"
  - "domain:linkedin.com"
```

## I want to use a separate Mysql database, how do I do that?

By default, `marzban_mysql_instance: true` is already enabled in the inventory.

```
root@main:/opt/marzban# docker ps
CONTAINER ID   IMAGE                     COMMAND                  CREATED          STATUS                    PORTS     NAMES
9cac00a5a838   haproxy:2.4.25            "docker-entrypoint.s…"   23 minutes ago   Up 23 minutes                       marzban-haproxy-1
8623ba69c221   gozargah/marzban:latest   "bash -c 'alembic up…"   23 minutes ago   Up 23 minutes                       marzban-marzban-1
63a539f0ee62   mariadb:lts               "docker-entrypoint.s…"   23 minutes ago   Up 23 minutes (healthy)             marzban-mariadb-1
```

## I want backup all my marzban data, how do I do this?

By default, `marzban_backup: true` is already enabled in the inventory.

The frequency of saving is configured in the `marzban_backup_cron` variable.

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

The cron job saves all your data every day on the path:
```/var/lib/marzban_backups/```

If you have a optional DB instance, the job will also dump this database:

```
/var/lib/marzban_backups/backup_${date}/db-backup/
└─── marzban.sql
```

Also, if you fill in the variables `marzban_backup_telegram_bot_token` and `marzban_backup_telegram_chat_id` the backup will be sent to your chat.

<img src="./images/backup_telegram.png" width="400">
