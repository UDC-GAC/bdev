#!/bin/bash

#Loading framework environment
m_echo "Loading environment: ${SOLUTION_DIR}/etc/env.sh"
. ${SOLUTION_DIR}/etc/env.sh

#Generate framework configuration
. "${SOLUTION_DIR}/bin/gen-config.sh"

m_echo "Master: $MASTERNODE"
m_echo "Workers:"
while read -r NODE; do
    m_echo $'\t'"$NODE"
done < "$WORKERSFILE"
