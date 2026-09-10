#!/bin/bash

# Fix for Java 9+
for jar in "$BDEV_LIB_DIR"/javax.activation-api-*.jar; do
    if [[ -f "$jar" ]]; then
        cp -f "$jar" "$HADOOP_LIB_DIR"/
    fi
done

. "$COMMON_HADOOP_DIR/bin/start.sh"
