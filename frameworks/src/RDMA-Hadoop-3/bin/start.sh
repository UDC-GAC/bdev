#!/bin/bash

# Fix for Java 9+
for jar in "$SOLUTION_DIR"/lib/javax.activation-api-*.jar; do
    if [[ -f "$jar" ]]; then
        ln -sf "$jar" "$SOLUTION_LIB_DIR"/
    fi
done

. "$COMMON_HADOOP_DIR/bin/start.sh"
