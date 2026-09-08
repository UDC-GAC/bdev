#!/bin/bash

# Fix for Java 9+
ln -s "$SOLUTION_DIR/lib/-javax.activation-api-*.jar" "$SOLUTION_LIB_DIR"

. "$COMMON_HADOOP_DIR/bin/start.sh"
