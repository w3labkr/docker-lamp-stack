# docker-lamp-stack

A basic LAMP stack environment built using Docker Compose. It consists of the following:

- PHP
- Apache
- MySQL
- Mariadb
- Redis

## Installation

Build and Run the Containers

```shell
git clone https://github.com/w3labkr/docker-lamp-stack.git docker
cd docker
cp .env.example .env
docker compose up -d
```

Register crontab and rebuild services

```shell
$ cp docker-entrypoint.sh bin/<PHP_VERSION>/docker-entrypoint.sh
$ docker compose up -d --build
```

## Usage

Create and start containers

- `-d`: Detached mode: Run containers in the background

```shell
docker compose up -d
```

Build or rebuild services

```shell
docker compose up --build
```

Stop and remove containers, networks

```shell
docker compose down
```

Restart service containers

```shell
docker compose restart apache2
```

Execute a command in a running container

```shell
docker compose exec apache2 bash
exit
```

Execute a command in a running container

```shell
docker compose exec mariadb bash
mysql -uroot -psecret
show databases;
select Host, User from mysql.user;
exit
```

Force-remove a running container (--force)

```shell
docker container rm -f $(docker container ls -aq)
```

Remove one or more images

- `-f`: Filter output based on conditions provided
- `-q`: Only show image IDs

```shell
docker image rm -f $(docker image ls -q)
```

Do not use cache when building the image

```shell
docker compose build --no-cache
```

Remove unused data

```shell
docker system prune -a
```

## Reference

- [sprintcube/docker-compose-lamp](https://github.com/sprintcube/docker-compose-lamp)
- [robertsaupe/docker-compose-lamp](https://github.com/robertsaupe/docker-compose-lamp)
- [laradock](https://github.com/laradock/laradock)

## License

[MIT LICENSE](LICENSE)
