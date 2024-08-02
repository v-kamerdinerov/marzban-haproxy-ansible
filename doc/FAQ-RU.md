# ЧАВО

- [Как мне зайти в панель управления?](#как-мне-зайти-в-панель-управления)
- [Я хочу активировать документацию доступную по /doc, как мне это сделать?](#я-хочу-активировать-документацию-доступную-по-doc-как-мне-это-сделать)
- [Я хочу сконфигурировать дополнительные ноды для распределения нагрузки, как мне это сделать?](#я-хочу-сконфигурировать-дополнительные-ноды-для-распределения-нагрузки-как-мне-это-сделать)
- [Я хочу использовать warp. Что мне нужно настроить?](#я-хочу-использовать-warp-что-мне-нужно-настроить)

## Как мне зайти в панель управления?
После прокатки плейбука панель marzban доступна по пути указанному в инвентори `marzban_domain: example-domain.com`

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