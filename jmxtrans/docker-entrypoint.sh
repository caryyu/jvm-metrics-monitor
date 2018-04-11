#!/bin/bash

JMXTRANS_HEAP_SIZE=${JMXTRANS_HEAP_SIZE:-"512"}
JMXTRANS_LOG_LEVEL=${JMXTRANS_LOG_LEVEL:-"info"}
JMXTRANS_PERIOD=${JMXTRANS_PERIOD:-"10"}

JMXTRANS_JAR="/usr/share/jmxtrans/lib/jmxtrans-all.jar"
JMXTRANS_CONFIG="/jmxtrans-config.json"

cat <<EOF > $JMXTRANS_CONFIG
{
  "servers": [
    {
      "host": "${JMX_HOST}",
      "port": "${JMX_PORT}",
      "queries": [
        {
          "obj": "java.lang:type=Memory",
          "attr": [ "HeapMemoryUsage", "NonHeapMemoryUsage" ],
          "resultAlias": "jvmMemory",
          "outputWriters": [
            {
              "@class": "com.googlecode.jmxtrans.model.output.StdOutWriter"
            },
            {
              "@class" : "com.googlecode.jmxtrans.model.output.InfluxDbWriterFactory",
              "url" : "${INFLUX_DBURL}",
              "username" : "${INFLUX_DBUNAME}",
              "password" : "${INFLUX_DBPWD}",
              "database" : "${INFLUX_DBNAME}",
              "tags"     : {"application" : "jmx"}
            }
          ]
        }
      ]
    }
  ]
}
EOF

JAVA_OPTS="-Xms${JMXTRANS_HEAP_SIZE}m -Xmx${JMXTRANS_HEAP_SIZE}m -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true"
JMXTRANS_OPTS="-Djmxtrans.log.level=${JMXTRANS_LOG_LEVEL}"
MONITOR_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=${JMX_PORT}"
EXEC="-jar $JMXTRANS_JAR -e -f $JMXTRANS_CONFIG -s $JMXTRANS_PERIOD -c false"

java -server $JAVA_OPTS $JMXTRANS_OPTS $MONITOR_OPTS $EXEC