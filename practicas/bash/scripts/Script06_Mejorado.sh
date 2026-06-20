#!/bin/bash

if [ -z "$NUEVA_VENTANA" ]; then
    SCRIPT="$(realpath "$0")"
    xfce4-terminal --title="Monitor de Red AVANZADO" --command="env NUEVA_VENTANA=1 bash '$SCRIPT'"
    exit 0
fi

RESET="\e[0m"
VERDE="\e[32m"
AZUL="\e[34m"
AZULOSCURO="\e[34m\e[1m"
AMARILLO="\e[33m"
CIAN="\e[36m"
NEGRITA="\e[1m"

OPCIONES=("Ver RED" "Ver CONEXION" "Ver IP Publica" "SALIR")
TOTAL=${#OPCIONES[@]}
SELECCION=0

ver_red() {
    RED=$(ip route | grep "default")
    echo -e "${VERDE}${RED}${RESET}"
}

ver_ip_publica() {
    echo -e "${AZUL}IP Publica IPv4: $(curl -s -4 ifconfig.me)${RESET}"
    echo -e "${AZUL}IP Publica IPv6: $(curl -s -6 ifconfig.me)${RESET}"
}

ver_conexion() {
    speedtest-cli > /tmp/speedtest_result &
    local test_pid=$!
    spinner $test_pid
    wait $test_pid
    echo -e "${AMARILLO}$(grep -E "Download|Upload|Testing from|Hosted by" /tmp/speedtest_result)${RESET}"
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

spinner() {
    local pid=$1
    local chars="* x o O 0"
    while kill -0 $pid 2>/dev/null; do
       for c in $chars; do
           printf "\r${CIAN}Calculando Velocidad...%c${RESET}" "$c"
           sleep 0.2
       done
    done
    printf "\r%-50s\r" ""
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
