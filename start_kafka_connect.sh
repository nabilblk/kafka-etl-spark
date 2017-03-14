#!/usr/bin/env bash
echo "Start ZooKeeper"

docker run -d \
    --net=host \
    --name=zookeeper \
    -e ZOOKEEPER_CLIENT_PORT=32181 \
    -e ZOOKEEPER_TICK_TIME=2000 \
    confluentinc/cp-zookeeper:3.0.0


echo "Start Kafka"

docker run -d \
    --net=host \
    --name=kafka \
    -e KAFKA_ZOOKEEPER_CONNECT=localhost:32181 \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:29092 \
    confluentinc/cp-kafka:3.0.0

echo "Start the Schema Registry"

docker run -d \
  --net=host \
  --name=schema-registry \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=localhost:32181 \
  -e SCHEMA_REGISTRY_HOST_NAME=localhost \
  -e SCHEMA_REGISTRY_LISTENERS=http://localhost:8081 \
  confluentinc/cp-schema-registry:3.0.0

echo "Create Topic uickstart-avro-offsets"
echo "Create Topic uickstart-avro-config"
echo "Create Topic uickstart-avro-status"
echo "Create Topic uickstart-avro-data"

echo "Create Tmp Folder"

mkdir -p ./tmp/quickstart/jars

echo "Download Mysql JDBC Driver"

curl -k -SL "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.39.tar.gz" | tar -xzf - -C ./tmp/quickstart/jars --strip-components=1 mysql-connector-java-5.1.39/mysql-connector-java-5.1.39-bin.jar

echo "Start Kafka connect "

docker run -d \
  --name=kafka-connect-avro \
  --net=host \
  -e CONNECT_BOOTSTRAP_SERVERS=localhost:29092 \
  -e CONNECT_REST_PORT=28083 \
  -e CONNECT_GROUP_ID="quickstart-avro" \
  -e CONNECT_CONFIG_STORAGE_TOPIC="quickstart-avro-config" \
  -e CONNECT_OFFSET_STORAGE_TOPIC="quickstart-avro-offsets" \
  -e CONNECT_STATUS_STORAGE_TOPIC="quickstart-avro-status" \
  -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" \
  -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" \
  -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL="http://localhost:8081" \
  -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL="http://localhost:8081" \
  -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
  -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
  -e CONNECT_REST_ADVERTISED_HOST_NAME="localhost" \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG \
  -p 28083:28083 \
  -v /Users/nabil/IdeaProjects/kafka-etl-spark/tmp/quickstart/file:/tmp/quickstart \
  -v /Users/nabil/IdeaProjects/kafka-etl-spark/tmp/quickstart/jars:/etc/kafka-connect/jars \
  confluentinc/cp-kafka-connect:latest


echo "Start Mysql"

docker run -d \
  --name=quickstart-mysql \
  --net=host \
  -e MYSQL_ROOT_PASSWORD=confluent \
  -e MYSQL_USER=confluent \
  -e MYSQL_PASSWORD=confluent \
  -e MYSQL_DATABASE=connect_test \
  mysql