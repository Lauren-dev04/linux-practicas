#!/bin/bash

# === VARIABLES ===
SEPARADOR="======================================="
BOLD=$(tput bold)
RESET=$(tput sgr0)

# === CABECERA ===
echo "$SEPARADOR"
echo -e "     ${BOLD}MI PRIMER SCRIPT EN BASH${RESET}"
echo "$SEPARADOR"
echo " "

# === INFO DEL SISTEMA ===
echo -e "${BOLD}Fecha y hora actual:${RESET}  $(date)"
echo -e "${BOLD}Usuario actual:${RESET}       $(whoami)"
echo -e "${BOLD}Directorio actual:${RESET}    $(pwd)"
echo -e "${BOLD}Version del kernel:${RESET}   $(uname -r)"
echo " "

# === INFO EXTRA ===
echo -e "${BOLD}RAM disponible:${RESET}       $(free -h | awk '/^Mem:/ {print $7}')"
echo -e "${BOLD}Disco usado (/):${RESET}      $(df -h / | awk 'NR==2 {print $3 " de " $2}')"
echo " "

