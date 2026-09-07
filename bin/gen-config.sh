#!/bin/bash

# Generates a temporary sed script with all BDEv parameters
build_sed_rules_file() {
    local rules_file="$1"
    local num
    num=$(get_num_conf_params)

    : > "$rules_file"
    for ((k=1; k<=num; k++)); do
        local key value
        key=$(get_conf_key "$k")
        value=$(get_conf_value "$k")

        # Escape conflicting characters for the right side of sed
        value=${value//\\/\\\\}
        value=${value//&/\\&}
        value=${value//|/\\|}
        echo "s|\$$key|$value|g" >> "$rules_file"
    done
}

generate_framework_config() {
    local src_dir="$1"		# Original folder in the tarball
    local template_dir="$2"	# Template folder
    local target_dir="$3"	# Final destination in $REPORT_DIR
    local target_log_dir="$4"	# Log folder in destination
    local master_file="${5:-}"	# Masters file path (optional)
    local workers_file="${6:-}"	# Workers file path (optional)

    [[ -z "$src_dir" || -z "$template_dir" || -z "$target_dir" ]] && \
        m_exit "generate_framework_config: src_dir, template_dir and target_dir are required"

    [[ ! -d "$src_dir" ]] && m_exit "Source conf dir does not exist: $src_dir"
    [[ ! -d "$template_dir" ]] && m_exit "Template dir does not exist: $template_dir"
    
    m_echo "Generating configuration files in: $target_dir"

    # Copy base configuration from tarball
    if ! mkdir -p "$target_dir"; then
        m_exit "Could not create configuration folder: $target_dir"
    fi

    if ! cp -r "$src_dir"/* "$target_dir"/; then
        m_exit "Could not copy configuration files from $src_dir to $target_dir"
    fi

    if ! chmod -R +w "$target_dir"; then
        m_exit "Could not make configuration folder writable: $target_dir"
    fi
    
    m_echo "Rendering template files from: $template_dir"

    add_conf_param "sol_conf_dir" $target_dir
    add_conf_param "sol_log_dir" $target_log_dir
    add_conf_param "hadoop_conf_dir" $HADOOP_CONF_DIR
    add_conf_param "hadoop_home" $HADOOP_HOME
	
	# Render templates using a temporary sed file
	local sed_rules
    sed_rules=$(mktemp)
    build_sed_rules_file "$sed_rules"
    #declare -p CONFIG_KEYS
    #declare -p CONFIG_VALUES
    #echo $sed_rules

    for tmpl in "$template_dir"/*; do
        [[ -f "$tmpl" ]] || continue
        local filename="${tmpl##*/}"	# Avoiding basename
        sed -f "$sed_rules" "$tmpl" > "$target_dir/$filename"
    done
    rm -f "$sed_rules"

    # Create hostfiles
    if [[ -n "$master_file" ]]; then
        rm -f "$master_file"
        echo "$MASTERNODE" > "$master_file"
    fi

    if [[ -n "$workers_file" ]]; then
        rm -f "$workers_file"
        printf '%s\n' $WORKERNODES | head -n $((CLUSTER_SIZE - 1)) > "$workers_file"
    fi
}
