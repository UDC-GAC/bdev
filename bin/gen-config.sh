#!/bin/bash

#Set directories
set_directory_configuration

if [[ -z "${SOL_TEMPLATE_DIR:-}" ]]; then
	m_exit "SOL_TEMPLATE_DIR is not defined or is empty"
fi

if [[ ! -d "$SOL_TEMPLATE_DIR" ]]; then
	m_exit "SOL_TEMPLATE_DIR does not exist or is not a directory: $SOL_TEMPLATE_DIR"
fi

sed_script=""
k=1
num=$(get_num_conf_params)
while [ "$k" -le "$num" ]
do
    key=$(get_conf_key "$k")
    value=$(get_conf_value "$k")
    value=${value//\\/\\\\}
    value=${value//&/\\&}
    value=${value//|/\\|}
    sed_script="${sed_script};s|\$$key|$value|g"
    k=$((k + 1))
done

#declare -p CONFIG_KEYS
#declare -p CONFIG_VALUES
#echo $sed_script

for F in "$SOL_TEMPLATE_DIR"/*
do
	[[ -f "$F" ]] || continue

	file=${F##*/} # Avoiding basename
	sed "$sed_script" "$F" > "$SOL_CONF_DIR/${file}"
done

rm -f $MASTERFILE $WORKERSFILE
m_echo "Master: $MASTERNODE"
echo $MASTERNODE > $MASTERFILE
touch $WORKERSFILE
m_echo "Workers:"

i=1
for NODE in $WORKERNODES; do
	if [[ $i -lt $CLUSTER_SIZE ]]; then
		m_echo "$NODE"
		echo $NODE >> $WORKERSFILE
	fi
	i=$(( $i + 1 ))
done
