## Description : 

The idea behind this repository is to test the ability to Kafka and Kafka connect to build complex realtime ETL .

We will test different ETL ingesting data from differents type source : 
* Simple Table : 
    * An Audit Log Table for example. 
        * Import data based on Primary key 
        * Import data based on timestamp Field
        * Import data based on Custom query . select field1, field2 from AuditLog 

* Ingest Data from Complex RDBMS structure : 
    * A table with Meta : SQL query with Join and Select Subquery .
     
We will use Jhipster Demo App and Gatling for simulating load . 
 
All materials will be in docker . 

## Start Zookeeper : 

```
docker run -d \
    --net=host \
    --name=zookeeper \
    -p 2181:2181 \
    -e ZOOKEEPER_CLIENT_PORT=32181 \
    -e ZOOKEEPER_TICK_TIME=2000 \
    confluentinc/cp-zookeeper:3.0.0
```

## Start Kafka : 
```
docker run -d \
    --net=host \
    --name=kafka \
    -e KAFKA_ZOOKEEPER_CONNECT=localhost:32181 \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:29092 \
    confluentinc/cp-kafka:3.0.0
```

## Start the Schema Registry:

```
docker run -d \
  --net=host \
  --name=schema-registry \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=localhost:32181 \
  -e SCHEMA_REGISTRY_HOST_NAME=localhost \
  -e SCHEMA_REGISTRY_LISTENERS=http://localhost:8081 \
  confluentinc/cp-schema-registry:3.0.0
```

## Start Kafka Manager : 

The inspiration come from this repository : 
https://github.com/sheepkiller/kafka-manager-docker
https://github.com/yahoo/kafka-manager

```
docker run -it --rm  --net=host --name=kafka-manager -p 9000:9000 -e ZK_HOSTS="$(docker-machine ip confluent):2181" -e APPLICATION_SECRET=letmein sheepkiller/kafka-manager
```

Open Kafka Manager : 

```
open http://$(docker-machine ip confluent):9000
```

## Create Topic : quickstart-avro-offsets

```
docker run \
  --net=host \
  --rm \
  confluentinc/cp-kafka:3.0.0 \
  kafka-topics --create --topic quickstart-avro-offsets --partitions 1 --replication-factor 1 --if-not-exists --zookeeper localhost:32181
```

## Create Topic : quickstart-avro-config 
```
docker run \
  --net=host \
  --rm \
  confluentinc/cp-kafka:3.0.0 \
  kafka-topics --create --topic quickstart-avro-config --partitions 1 --replication-factor 1 --if-not-exists --zookeeper localhost:32181
```

## Create Topic : quickstart-avro-status 
```
docker run \
  --net=host \
  --rm \
  confluentinc/cp-kafka:3.0.0 \
  kafka-topics --create --topic quickstart-avro-status --partitions 1 --replication-factor 1 --if-not-exists --zookeeper localhost:32181
```

## Create Topic : quickstart-avro-data
```
docker run \
  --net=host \
  --rm \
  confluentinc/cp-kafka:3.0.0 \
  kafka-topics --create --topic quickstart-avro-data --partitions 1 --replication-factor 1 --if-not-exists --zookeeper localhost:32181
```

## Verify that Topic are created : 
```
docker run \
   --net=host \
   --rm \
   confluentinc/cp-kafka:3.0.0 \
   kafka-topics --describe --zookeeper localhost:32181
```