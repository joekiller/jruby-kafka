#!/usr/bin/env bash
set -x
ZK_TEST_HOST="${ZK_TEST_HOST:-127.0.0.1}"
ZK_TEST_PORT="${ZT_TEST_PORT:-2181}"
ZK_CHROOT="${ZK_CHROOT:-/}"

test_zk_host () {
    break=0
    break_max=12
    up=0
    while [ ${break} -lt ${break_max} ]; do
      if echo ruok | nc -w 10 ${ZK_TEST_HOST} ${ZK_TEST_PORT} | grep -q imok; then
        break=${break_max}; up=1
      fi
      if [ ${up} -eq 0 ]; then
        break=$[$break+1]
        sleep 2
      fi
    done
    if [ ${up} -eq 0 ]; then
        e_e "Zookeeper status check failed. (Ran: echo ruok | nc -w 10 ${ZK_TEST_HOST} ${ZK_TEST_PORT}). Check your Zookeeper setup." 1
    fi
}

test_kafka_ready () {
    break=0
    break_max=12
    up=0
    while [ ${break} -lt ${break_max} ]; do
      if kafka/bin/zookeeper-shell.sh ${ZK_TEST_HOST}:${ZK_TEST_PORT}${ZK_CHROOT}<<-EOF 2>&1 | grep -q "numChildren = 1"
        get /brokers/ids
        quit
EOF
      then
        break=${break_max}; up=1
      fi
      if [ ${up} -eq 0 ]; then
        break=$[$break+1]
        sleep 2
      fi
    done
    if [ ${up} -eq 0 ]; then
        e_e "Kafka broker didn't seem to come up." 1
    fi
}

e_e () {
    #echo and exit
    echo >&2 "$1"
    exit $2
}

if [ ! -f "kafka.tgz" ]; then
    curl -s -o kafka.tgz $(curl -s https://www.apache.org/dyn/closer.cgi?path=/kafka/0.9.0.0/kafka_2.11-0.9.0.0.tgz | grep -o '<strong>[^<]*</strong>'|sed 's/<[^>]*>//g'|head -1)
fi

if [ ! -d "kafka" ]; then
    mkdir kafka && tar xzf kafka.tgz -C kafka --strip-components 1
fi
sed -i 's!^zookeeper.connect=.*$!zookeeper.connect='${ZK_TEST_HOST}:${ZK_TEST_PORT}${ZK_CHROOT}'!' kafka/config/server.properties
kafka/bin/zookeeper-server-start.sh -daemon kafka/config/zookeeper.properties
test_zk_host
kafka/bin/kafka-server-start.sh -daemon kafka/config/server.properties
test_kafka_ready
