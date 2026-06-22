#!/bin/bash

if [ -z "$NUEVA_VENTANA" ]; then
    SCRIPT="$(realpath "$0")"
    xfce4-terminal --title="Monitor de Red AVANZADO" -e "env NUEVA_VENTANA=1 bash '$SCRIPT'"
    exit 0
fi

RESET="\e[0m"
VERDE="\e[32m"
AZUL="\e[34m"
AZULOSCURO="\e[34m\e[1m"
AMARILLO="\e[33m"
CIAN="\e[36m"
NEGRITA="\e[1m"
INVERSO="\e[7m"
ROJO="\e[31m"

OPCIONES=("Ver RED" "Ver CONEXION" "Ver IP Publica" "SALIR")
TOTAL=${#OPCIONES[@]}
SELECCION=0

ver_red() {
    clear
    echo -e "${AZUL}${CIAN}+============================================+${RESET}"
    echo -e "${CIAN}${AZUL}|      INFORMACION DE RED DETALLADA          |${CIAN}|${RESET}"
    echo -e "${AZUL}${CIAN}+============================================+${RESET}"
    echo ""

#Interfaz Principal
    local iface=$(ip route | grep default | awk '{print $5}')

#IP Local y mascara
    local ip_info=$(ip addr show $iface | grep "inet " | awk '{print $2}')
    local ip_local=${ip_info%/*}
    local mascara=${ip_info#*/}

#Geteway
    local geteway=$(ip route | grep default | awk '{print $3}')

#MAC Address
    local mac=$(ip link show $iface | awk '/link\/ether/ {print $2}')

#DNS
   local dns=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ')

#Estado de la Interfaz
    local estado=$(ip link show $iface | awk '/state/ {print $2}')

#Brodcast
    local broadcast=$(ip addr show $iface | grep "inet " | awk '{print $4}')

#IPv6
    local ipv6=$(ip addr show $iface | grep "inet6 " | awk '{print $2}' | head -1)

#Monstrar todo formateado
    echo -e "${CIAN} Interfaz:${RESET} ${VERDE}$iface${RESET}"
    echo -e "${CIAN} Estado:${RESET} $(if [ "$estado" == "UP" ]; then echo -e "${VERDE}ACTIVA${RESET}"; else echo -e "${ROJO}INACTIVA${RESET}"; fi)"
    echo ""
    echo -e "${CIAN} IPv4:${RESET} ${AMARILLO}$ip_local${RESET}"
    echo -e "${CIAN} Mascara:${RESET} ${AMARILLO}/$mascara${RESET}"
    echo -e "${CIAN} Broadcast:${RESET} ${AMARILLO}$broadcast${RESET}"
    [ -n "$ipv6" ] && echo -e "${CIAN} IPv6:${RESET} ${AZUL}$ipv6${RESET}"
    echo ""
    echo -e "${CIAN} Geteway:${RESET} ${VERDE}$geteway${RESET}"
    echo -e "${CIAN} DNS:${RESET} ${VERDE}$dns${RESET}"
    echo -e "${CIAN} MAC:${RESET} ${VERDE}$mac${RESET}"
    echo ""

#Informacion adicional
    echo -e "${CIAN}--------------------------${RESET}"
    echo -e "${CIAN} Rutas Configuradas:${RESET}"
    ip route | grep -v default | head -5 | while read linea; do
        echo -e " ${VERDE}>${RESET} $linea"
    done
}

ver_ip_publica() {
    echo -e "${AZUL}IP Publica IPv4: $(curl -s -4 ifconfig.me)${RESET}"
    echo -e "${AZUL}IP Publica IPv6: $(curl -s -6 ifconfig.me)${RESET}"
}

ver_conexion() {
    echo -e "${CIAN} Conectacto al servidor...${RESET}"
    sleep 1
    echo -e "${AMARILLO} Midiendo Ping...${RESET}"
    sleep 1
    echo -e "${VERDE} Midiendo Velocidad de Descarga...${RESET}"
    speedtest-cli > /tmp/speedtest_result &
    local test_pid=$!
#Animacion
    local chars="| / - \\"
    while kill -0 $test_pid 2>/dev/null; do
       for ((i=0; i<${#chars}; i++)); do
           printf "\r${CIAN} ${chars:$i:1} Procesando...${RESEt}"
           sleep 0.1
       done
    done
    wait $test_pid
    echo -e "\r${VERDE} Test Completado.${RESET}"
    echo ""
    
    ISP=$(grep "Testing from" /tmp/speedtest_result | sed 's/Testing from //')
    SERVIDOR=$(grep "Hosted by" /tmp/speedtest_result | sed 's/Hosted by //')
    PING_VAL=$(grep "Hosted by" /tmp/speedtest_result | grep -o '[0-9]*\.[0-9]* ms' | sed 's/ ms//')
    DOWNLOAD=$(grep "Download:" /tmp/speedtest_result | grep -o '[0-9]*\.[0-9]*')
    UPLOAD=$(grep "Upload:" /tmp/speedtest_result | grep -o '[0-9]*\.[0-9]*')

    echo ""
    echo -e "${NEGRITA}${CIAN}+----------------------------------------+${RESET}"
    echo -e "${NEGRITA}${CIAN}|          RESULTADO SPEEDTEST           |${RESET}"
    echo -e "${NEGRITA}${CIAN}+________________________________________+${RESET}"
    echo -e "${CIAN}|${RESET} ISP:      ${VERDE}${ISP}${RESET}"         
    echo -e "${CIAN}|${RESET} Servidor: ${AZUL}${SERVIDOR}${RESET}"    
    echo -e "${CIAN}|${RESET} Ping:     $(color_ping $PING_VAL)"       
    echo -e "${NEGRITA}${CIAN}+________________________________________+${RESET}"
    echo -e "${CIAN}|${RESET} Descarga: $(color_velocidad $DOWNLOAD)"
barra_progreso ${DOWNLOAD%.*} 1000
    echo -e "${CIAN}|${RESET} Subida:   $(color_velocidad $UPLOAD)"
barra_progreso ${UPLOAD%.*} 1000
    echo -e "${NEGRITA}${CIAN}+----------------------------------------+${RESET}"
    echo ""

    rm /tmp/speedtest_result
}

dibujar_menu() {
    clear
    echo -e "${NEGRITA}${CIAN}==========================================${RESET}"
    echo -e "${NEGRITA}${CIAN}|      MONITOR DE RED AVANZADO           |${RESET}"
    echo -e "${NEGRITA}${CIAN}==========================================${RESET}"
    echo ""

    for i in "${!OPCIONES[@]}"; do
        if [ $i -eq $SELECCION ]; then
           echo -e "  ${INVERSO} > ${OPCIONES[$i]} ${RESET}"
        else
           echo -e "    ${OPCIONES[$i]}"
        fi
    done

    echo ""
    echo -e "${CIAN}usar flecha arriba, abajo y ENTER para selecionar${RESET}"
}

barra_progreso() {
    local valor=$1
    local maximo=$2
    local longitud=20
    local llenos=$(( valor * longitud / maximo ))
    local vacios=$(( longitud - llenos ))
    local barra=""

    for ((i=0; i<llenos; i++)); do
        barra+="#"
    done
    for ((i=0; i<vacios; i++)); do
        barra+="-"
    done
   
    echo "[$barra]"
}

color_ping() {
   local ping=$1
   local ping_int=${ping%.*}
   if [ "$ping_int" -lt 30 ]; then
      echo -e "${VERDE}${ping} ms${RESET}"
   elif [ "$ping_int" -lt 100 ]; then
      echo -e "${AMARILLO}${ping} ms${RESET}"
   else
       echo -e "${ROJO}${ping} ms${RESET}"
   fi
}

color_velocidad() {
    local vel=$1
    local vel_int=${vel%.*}

    if [ "$vel_int" -gt 100 ]; then
       echo -e "${VERDE}${vel} Mbit/s${RESET}"
    elif [ "$vel_int" -gt 50 ]; then
       echo -e "${AMARILLO}&{vel} Mbit/s${RESET}"
    else
        echo -e "${ROJO}&{vel} Mbit/s${RESET}"
    fi
}

leer_tecla() {
    local key
    IFS= read -rs -n1 key
    if [[ "$key" == $'\e' ]]; then
       IFS= read -rs -n1 key2
       if [[ "$key2" == "[" ]] || [[ "$key2" == "O" ]]; then
           IFS= read -rs -n1 key3
           echo "$key$key2$key3"
       else
           echo "$key$key2"
       fi
    else
        echo "$key"
    fi
}
 
while true; do
    dibujar_menu

    TECLA=$(leer_tecla)

    case "$TECLA" in
        $'\e[A'|$'\eOA')
            ((SELECCION--))
            [ $SELECCION -lt 0 ] && SELECCION=$((TOTAL -1))
            ;;
        $'\e[B'|$'\eOA')
            ((SELECCION++))
            [ $SELECCION -ge $TOTAL ] && SELECCION=0
            ;;
        "")
           clear
           case $SELECCION in
               0) ver_red ;;
               1) ver_conexion ;;
               2) ver_ip_publica ;;
               3)
                  echo -e "${AZUL}Saliendo...${RESET}"
                  exit 0
                  ;;
           esac
           echo ""
           read -p "Pulsa ENTER para volver al menu..."
           ;;
    esac
done
