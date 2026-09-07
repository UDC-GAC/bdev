#!/bin/bash

if [[ -z $COMMAND ]]; then
	ACTIVE_SHELL=$(get_interactive_shell)
	m_echo "Entering interactive command mode (shell: $ACTIVE_SHELL)"
	
	# Save the current terminal configuration (POSIX)
	SAVED_TTY=$(stty -g 2>/dev/null)
    
	start_benchmark

	if [[ ${TIMEOUT:-0} -gt 0 ]]; then
          	m_echo "Interactive session timeout: ${TIMEOUT} seconds"
            	timeout --foreground -s HUP -k 3s "${TIMEOUT}s" "$ACTIVE_SHELL" -i 2>&1 | tee -a "$TMPLOGFILE"
            	exit_code=${PIPESTATUS[0]}
    	else
        	"$ACTIVE_SHELL" -i 2>&1 | tee -a "$TMPLOGFILE"
        	exit_code=${PIPESTATUS[0]}
    	fi
    
	# Restore terminal settings and turn off residual sequences
	if [[ -n "$SAVED_TTY" ]]; then
		stty "$SAVED_TTY" 2>/dev/null
	else
		stty sane 2>/dev/null
	fi
    
 	# Deactivate bracketed paste mode if Readline left it on
 	printf '\e[?2004l' 2>/dev/null
    
	end_benchmark "$exit_code"
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
