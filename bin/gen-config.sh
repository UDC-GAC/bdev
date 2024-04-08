#!/bin/sh

#Set directories
set_directory_configuration

for F in $SOL_TEMPLATE_DIR/*
do
	file=`basename $F`
	filecontent="$(cat $F)"
	for k in `seq 1 $(get_num_conf_params)`
	do
		key=$(get_conf_key $k)
		value=$(echo "$(get_conf_value $k)" | sed 's/\//\\\//g')
		filecontent=$(echo -e "$filecontent" | sed "s/\$$key/$value/g")
	done
	echo "$filecontent" > $SOL_CONF_DIR/${file}
done
echo -e "$CONFIG_KEYS"
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
