#!/bin/sh

sudo setcap cap_sys_rawio=ep ${TURBOSTAT_BIN}
