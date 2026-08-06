#!/bin/sh

sleep 1

# Comprobar que YARN_EXECUTABLE tiene valor y existe (ya sea en el PATH o como ruta absoluta)
if [ -z "$YARN_EXECUTABLE" ] || ! command -v "$YARN_EXECUTABLE" &> /dev/null; then
    m_warn "yarn command is not avaialble or YARN_EXECUTABLE variable is empty. No cleaning is done"
else
    # Ejecutar el comando guardando la salida y ocultando errores de conexión (2>/dev/null)
    # Si YARN está caído, fallará silenciosamente sin ensuciar los logs
    YARN_APPS=$("$YARN_EXECUTABLE" application -list -appStates RUNNING,ACCEPTED 2>/dev/null | grep "application_" | awk '{print $1}')
    
    # Comprobamos si el comando anterior falló (ej: YARN no está arrancado)
    if [ $? -ne 0 ]; then
        echo "YARN is not available. No cleaning is done."
    else
        # Comprobar si la variable tiene contenido (si hay apps para matar)
        if [ -n "$YARN_APPS" ]; then
            for app in $YARN_APPS; do
                echo "Killing YARN app $app"
                "$YARN_EXECUTABLE" application -kill "$app"
            done
        else
            m_echo "No YARN applications are running"
        fi
    fi
fi
