#!/bin/sh

#Set directories
set_directory_configuration

if [[ -n "${SOL_TEMPLATE_DIR:-}" ]]; then
	m_exit "SOL_TEMPLATE_DIR is not defined or is empty"
fi

if [[ ! -d "$SOL_TEMPLATE_DIR" ]]; then
	m_exit "SOL_TEMPLATE_DIR does not exist or is not a directory: $SOL_TEMPLATE_DIR"
fi
	
for F in "$SOL_TEMPLATE_DIR"/*
do
	[[ -f "$F" ]] || continue
	
	file=`basename $F`
	filecontent=$(<"$F")
	
	for k in `seq 1 $(get_num_conf_params)`
	do
		key=$(get_conf_key $k)
		value=$(echo "$(get_conf_value $k)" | sed 's/\//\\\//g')
		filecontent=$(echo -e "$filecontent" | sed "s/\$$key/$value/g")
	done
	echo "$filecontent" > $SOL_CONF_DIR/${file}
done

rm -f $MASTERFILE $SLAVESFILE
m_echo "Master: $MASTERNODE"
echo $MASTERNODE > $MASTERFILE
m_echo "Workers:"
i=1
for SLAVE in $SLAVENODES
do
	if [[ $i -lt $CLUSTER_SIZE ]]
	then
		m_echo "$SLAVE"
		echo $SLAVE >> $SLAVESFILE
	fi
	i=$(( $i + 1 ))
done
