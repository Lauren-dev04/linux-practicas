#!/bin/bash

ver_ram() {
    RAM=$(free -h)
    echo "$RAM"
}

ver_disco() {
    DISCO=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
    if [ $DISCO -gt 80 ]; then
       echo "AVISO: disco al $DISCO%"
    else
       echo "Disco OK: $DISCO%"
    fi
}

ver_cpu() {
    CPU=$(top -bn1 | grep "Cpu")
    echo "$CPU"
}

while true; do
    echo "1)ver RAM"
    echo "2)ver disco"
    echo "3)ver Cpu"
    echo "0) Salir"
    read -p "Opcion: " OPCION

    case $OPCION in
        1) ver_ram ;;
        2) ver_disco ;;
        3) ver_cpu ;;
        0) exit 0 ;;
        *)echo "Opcion no valida" ;;
    esac
done
