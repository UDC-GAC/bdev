#!/bin/sh

mkdir -p ${NETHOGS_BINARIES_PATH}

cp ${NETHOGS_BIN} ${NETHOGS_BINARIES_PATH}

sudo setcap "cap_net_admin,cap_net_raw=ep" ${NETHOGS_BINARIES_PATH}/nethogs
