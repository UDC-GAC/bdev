# Set Hadoop-specific environment variables here.

# The only required environment variable is JAVA_HOME.  All others are
# optional.  When running a distributed configuration it is best to
# set JAVA_HOME in this file, so that it is correctly defined on
# remote nodes.

# The java implementation to use.  Required.
# export JAVA_HOME=/usr/lib/j2sdk1.5-sun

$load_java_command

export HADOOP_CONF_DIR=$sol_conf_dir
export HADOOP_LOG_DIR=$sol_log_dir
export HADOOP_PID_DIR=$tmp_dir/hadoop/pid

# Extra Java CLASSPATH elements.  Optional.
# export HADOOP_CLASSPATH=

# The maximum amount of heap to use, in MB. Default is 1000.
export HADOOP_HEAPSIZE=$slave_heapsize

# Extra Java runtime options.  Empty by default.
# export HADOOP_OPTS=-server

export HADOOP_OPTS="$HADOOP_OPTS -Djava.io.tmpdir=$tmp_dir"

# Command specific options appended to HADOOP_OPTS when specified
#export HADOOP_NAMENODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_NAMENODE_OPTS"
#export HADOOP_SECONDARYNAMENODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_SECONDARYNAMENODE_OPTS"
#export HADOOP_DATANODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_DATANODE_OPTS"
#export HADOOP_BALANCER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_BALANCER_OPTS"
#export HADOOP_JOBTRACKER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_JOBTRACKER_OPTS"
# export HADOOP_TASKTRACKER_OPTS=

export HADOOP_NAMENODE_HEAPSIZE=$master_heapsize
export HADOOP_DATANODE_HEAPSIZE=$slave_heapsize
export HADOOP_JOBTRACKER_HEAPSIZE=$master_heapsize
export HADOOP_TASKTRACKER_HEAPSIZE=$slave_heapsize

if [ "$HADOOP_NAMENODE_HEAPSIZE" != "" ]; then
  export HADOOP_NAMENODE_OPTS="-Xmx""${HADOOP_NAMENODE_HEAPSIZE}""m"
fi

if [ "$HADOOP_DATANODE_HEAPSIZE" != "" ]; then
  export HADOOP_DATANODE_OPTS="-Xmx""${HADOOP_DATANODE_HEAPSIZE}""m"
fi

if [ "$HADOOP_JOBTRACKER_HEAPSIZE" != "" ]; then
  export HADOOP_JOBTRACKER_OPTS="-Xmx""${HADOOP_JOBTRACKER_HEAPSIZE}""m"
fi

if [ "$HADOOP_TASKTRACKER_HEAPSIZE" != "" ]; then
  export HADOOP_TASKTRACKER_OPTS="-Xmx""${HADOOP_TASKTRACKER_HEAPSIZE}""m"
fi

# The following applies to multiple commands (fs, dfs, fsck, distcp etc)
# export HADOOP_CLIENT_OPTS

# Extra ssh options.  Empty by default.
# export HADOOP_SSH_OPTS="-o ConnectTimeout=1 -o SendEnv=HADOOP_CONF_DIR"

# Where log files are stored.  $HADOOP_HOME/logs by default.
# export HADOOP_LOG_DIR=${HADOOP_HOME}/logs

# File naming remote slave hosts.  $HADOOP_HOME/conf/slaves by default.
# export HADOOP_SLAVES=${HADOOP_HOME}/conf/slaves

# host:path where hadoop code should be rsync'd from.  Unset by default.
# export HADOOP_MASTER=master:/home/$USER/src/hadoop

# Seconds to sleep between slave commands.  Unset by default.  This
# can be useful in large clusters, where, e.g., slave rsyncs can
# otherwise arrive faster than the master can service them.
# export HADOOP_SLAVE_SLEEP=0.1

# The directory where pid files are stored. /tmp by default.
# NOTE: this should be set to a directory that can only be written to by 
#       the users that are going to run the hadoop daemons.  Otherwise there is
#       the potential for a symlink attack.
# export HADOOP_PID_DIR=/var/hadoop/pids

# A string representing this instance of hadoop. $USER by default.
# export HADOOP_IDENT_STRING=$USER

# The scheduling priority for daemon processes.  See 'man nice'.
# export HADOOP_NICENESS=10

export HADOOP_IP_ADDRESS=`$method_bin_dir/get_ip_from_hostname.sh $hostfile`
export HADOOP_OPTS="${HADOOP_OPTS} -Djava.net.preferIPv4Stack=true -DHADOOPHOSTNAME=${HADOOP_IP_ADDRESS}"

#UDA
export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$uda_lib_dir/uda-hadoop-1.x.jar
