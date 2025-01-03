# Django + Swarm + Celery + PgBouncer + Grafana (Monitoring)

## Set Up

1. Make sure you have docker and docker compose installed in your machine. Check by following commands respectively:

```shell
docker --version
```
```shell
docker compose version
```

2. Clone project

```shell
git clone git@github.com:mirzomumin/swarm_deploy.git
```

3. Move to project directory

```shell
cd swarm_deploy
```

4. Create `.env` file and define environment variables as shown in `.env.example` file

## Launch

1. Initialize docker swarm mode

```shell
docker swarm init --advertise-addr `ip address`
```

2. Add a manager to this swarm

```shell
docker swarm join-token manager
```

3. Run command to launch services

```shell
docker stack deploy --with-registry-auth -c docker-compose.yaml --prune mohirpay-stack
```
