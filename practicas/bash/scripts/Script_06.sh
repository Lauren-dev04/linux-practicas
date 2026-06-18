#!/bin/bash

if [ -z "$NUEVA_VENTANA" ];then
    export NUEVA_VENTANA=1
    xfce4-terminal --title="Monitor de Red" -e "env NUEVA_VENTANA=1 bash /home/lau/linux-practicas/practicas/bash/scripts/Script_06.sh"
    exit
fi

ver_red() {
    RED=$(ip route | grep "default")
    echo "$RED"
}

ver_ip_publica() {
    echo "IP Publica IPv4: $(curl -s -4 ifconfig.me)"
    echo "IP Publica IPv6: $(curl -s -6 ifconfig.me)"
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
    echo "3)ver IP Publica"
    echo "0) SALIR"
    read -p "Opcion: " OPCION

    case $OPCION in
        1)ver_red ;;
        2)ver_conexion ;;
        3)ver_ip_publica ;;
        0) exit ;;
        *)echo "Opcion no valida" ;;
    esac
done

