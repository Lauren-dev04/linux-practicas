#!/bin/bash

ver_red() {
    RED=$(ip route | grep "default")
    echo "$RED"
}

spinner() {
    local pid=$1
    local chars="| / - \\"
    while kill -0 $pid 2>/dev/null; do
       for c in $chars; do
           printf "\r Calculando Conexion...$c"
           sleep 0.2
       done
    done
    printf "\r                          \r"
}

ver_conexion() {
    speedtest-cli > /tmp/speedtest_result &
    spinner $!
    cat /tmp/speedtest_result | grep -E "Download|Upload|Testing from|Hosted by"
    rm /tmp/speedtest_result
}

while true; do
    echo "1)ver RED"
    echo "2)ver CONEXION"
    echo "0) SALIR"
    read -p "Opcion: " OPCION

    case $OPCION in
        1)ver_red ;;
        2)ver_conexion ;;
        0) exit 0 ;;
        *)echo "Opcion no valida" ;;
    esac
done

