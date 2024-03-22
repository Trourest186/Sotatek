# The Infrasture for datalake platform
## Prerequisites
* Make sure that you have Docker and Docker Compose installed
    * Windows or macOS:
        [Install Docker Desktop](https://www.docker.com/get-started)
    * Linux:
        [Install Docker](https://www.docker.com/get-started) and then [Docker Compose](https://github.com/docker/compose)
##  Quickstart
  ```
  git clone https://github.com/vicg-development/datalake-platform-infra.git
  cd datalake-platform-infra
  docker compose -f docker-compose.yaml up
  ``` 
##  Components
The architecture includes 5 main components:
* Nginx reverse proxy
* MongoDB
* Elasticsearch
* Minio
* Redis
### Port mapping
|Service| Container port | External Port |
|:-------------| :-------------:| :------------:|
|      MongoDB     |      27011     |     27018     |
|      Elasticsearch     |      9200, 9300     |     9201, 9301     |
|      Minio     |      9000, 9090     |          |
|      Redis     |      6379     |          |
|      Nginx     |      80, 443     |     80, 433     |


##  Directory structure
* `nginx`: Including subdirectories such as "conf.d" for additional routing configurations, a directory for authentication key, a directory for logs, etc., with the purpose of mounting into the container when launching Docker-compose.
* `.docker/mongodb_data`: Mount the corresponding partition into the MongoDB database container to preserve data.
* `esdata`: Mount the corresponding partition into Elasticsearch
* `minio/minio-data`: The storage directory for Minio into container
* `redis`: The partition for redis

## Configure for environment variables
|Variable| Description | Default |
|:-------------| :-------------:| :------------:|
|      `MONGO_INITDB_ROOT_USERNAME`     |      the username for root account   |     admin     |
|      `MONGO_INITDB_ROOT_PASSWORD`     |      the password for root account     |     123456     |
|      `MONGO_INITDB_DATABASE`     |     Initial database setup      |     local     |
|      `discovery.type`     |      Deployment mode     |     single-node     |
|      `ES_JAVA_OPTS`     |      The size of heap     |    -Xms512m -Xmx512m     |
|      `MINIO_ROOT_USER`     |      the username for root account     |     demo_vicg     |
|      `MINIO_ROOT_PASSWORD`     |      the password for root account     |     V1CG@2023     |
|      `MINIO_SERVER_URL`     |      The URL for minio server     |     https://datalakev2-api.sotaicg.com     |
|      `MINIO_BROWSER_REDIRECT_URL`     |      The broweser redirect URL     |     https://datalakev2-console.sotaicg.com/    |

## Other components
* [Frontend](https://github.com/vicg-development/datalake-platform-fe): The UI for datalake platform
* [Backend](https://github.com/vicg-development/datalake-platform-be): The backend component serves as the backbone of the application

## Other deployment types
* Using Helm chart: Need to deploy for production environment

## Clean up the resources
```
docker compose -f docker-compose.yaml down
```
