#!/usr/bin/env bash
kafka/bin/kafka-server-stop.sh
ps ax | grep -i 'zookeeper' | grep -v grep | awk '{print $1}' | xargs kill -9
