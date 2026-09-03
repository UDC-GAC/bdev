#!/bin/bash

if [[ -z $COMMAND ]]; then
	ACTIVE_SHELL=$(get_interactive_shell)
	m_echo "Entering interactive command mode (shell: $ACTIVE_SHELL)"
	start_benchmark

	if [[ ${TIMEOUT:-0} -gt 0 ]]; then
          	m_echo "Interactive session timeout: ${TIMEOUT} seconds"
            	timeout --foreground "${TIMEOUT}s" "$ACTIVE_SHELL" -i 2>&1 | tee -a "$TMPLOGFILE"
    	else
        	"$ACTIVE_SHELL" -i 2>&1 | tee -a "$TMPLOGFILE"
    	fi
    
	end_benchmark
	m_echo "Exiting interactive command mode"
else
	m_echo "Entering batch command mode"
	
	if [[ -d $COMMAND ]]; then
		found_executable=false
		
		for CMD in "$COMMAND"/*; do
			if [[ -f "$CMD" && -x "$CMD" ]]; then
                		found_executable=true
				run_benchmark $CMD
			fi
		done
		
		if [[ "$found_executable" == "false" ]]; then
            		m_warn "No executable files found in directory: $COMMAND"
		fi
	else
		run_benchmark $COMMAND
	fi
fi
