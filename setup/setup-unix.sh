#!/bin/bash
# SETUP PARA SISTEMAS MAC Y LINUX!!!
#
# SCRIPT MEJORADO PARA PSYCH ENGINE 0.7.3

set -e  # Detener el script si hay errores

HAXE_VERSION="4.2.5"
HAXELIB_DIR="$(pwd)/../.haxelib"

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==============================================${NC}"
echo -e "${GREEN}        INSTALADOR DE PSYCH ENGINE 0.7.3${NC}"
echo -e "${BLUE}==============================================${NC}"
echo ""

# Función para verificar si Haxe está instalado
check_haxe() {
    if command -v haxe >/dev/null 2>&1; then
        CURRENT_VERSION=$(haxe --version | head -n 1)
        echo -e "${YELLOW}Versión actual de Haxe: $CURRENT_VERSION${NC}"
        
        if [ "$CURRENT_VERSION" = "$HAXE_VERSION" ]; then
            echo -e "${GREEN}Haxe $HAXE_VERSION ya está instalado.${NC}"
            return 0
        else
            echo -e "${YELLOW}Tienes Haxe $CURRENT_VERSION, pero se requiere $HAXE_VERSION.${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}Haxe no está instalado.${NC}"
        return 1
    fi
}

# Función para instalar Haxe en Ubuntu/Debian
install_haxe_ubuntu() {
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${GREEN}Instalando Haxe $HAXE_VERSION en Ubuntu/Debian${NC}"
    echo -e "${BLUE}==============================================${NC}"
    
    echo -e "${YELLOW}Agregando repositorio PPA de Haxe...${NC}"
    sudo add-apt-repository ppa:haxe/releases -y
    sudo apt-get update
    
    echo -e "${YELLOW}Instalando Haxe...${NC}"
    sudo apt-get install haxe -y
    
    echo -e "${GREEN}Haxe instalado. Verificando versión...${NC}"
    haxe --version
}

# Función para instalar Haxe en Fedora
install_haxe_fedora() {
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${GREEN}Instalando Haxe en Fedora${NC}"
    echo -e "${BLUE}==============================================${NC}"
    
    echo -e "${YELLOW}Instalando Haxe desde los repositorios...${NC}"
    sudo dnf install haxe -y
    
    echo -e "${GREEN}Haxe instalado. Verificando versión...${NC}"
    haxe --version
}

# Función para instalar Haxe en Arch Linux
install_haxe_arch() {
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${GREEN}Instalando Haxe en Arch Linux${NC}"
    echo -e "${BLUE}==============================================${NC}"
    
    echo -e "${YELLOW}Instalando Haxe desde los repositorios...${NC}"
    sudo pacman -S haxe --noconfirm
    
    echo -e "${GREEN}Haxe instalado. Verificando versión...${NC}"
    haxe --version
}

# Función para instalar Haxe usando binarios
install_haxe_binaries() {
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${GREEN}Instalando Haxe $HAXE_VERSION usando binarios${NC}"
    echo -e "${BLUE}==============================================${NC}"
    
    # Crear directorio temporal
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    echo -e "${YELLOW}Descargando Haxe $HAXE_VERSION...${NC}"
    curl -sL "https://github.com/HaxeFoundation/haxe/releases/download/$HAXE_VERSION/haxe-$HAXE_VERSION-linux64.tar.gz" | tar -xz
    
    # Renombrar y mover a /opt
    HAXE_DIR="/opt/haxe-$HAXE_VERSION"
    
    echo -e "${YELLOW}Instalando Haxe en $HAXE_DIR...${NC}"
    sudo mkdir -p "$HAXE_DIR"
    sudo mv haxe_*/* "$HAXE_DIR"
    
    # Crear enlaces simbólicos
    echo -e "${YELLOW}Creando enlaces simbólicos...${NC}"
    sudo ln -sf "$HAXE_DIR/haxe" /usr/local/bin/haxe
    sudo ln -sf "$HAXE_DIR/haxelib" /usr/local/bin/haxelib
    
    # Configurar variables de entorno
    echo -e "${YELLOW}Configurando variables de entorno...${NC}"
    echo "export HAXE_STD_PATH=$HAXE_DIR/std" | sudo tee /etc/profile.d/haxe.sh
    
    # Limpiar
    cd -
    rm -rf "$TEMP_DIR"
    
    echo -e "${GREEN}Haxe $HAXE_VERSION instalado usando binarios.${NC}"
    echo -e "${YELLOW}Por favor, reinicia tu terminal o ejecuta 'source /etc/profile.d/haxe.sh' para aplicar los cambios.${NC}"
}

# Función para configurar haxelib
setup_haxelib() {
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${GREEN}Configurando haxelib en modo local${NC}"
    echo -e "${BLUE}==============================================${NC}"
    
    mkdir -p "$HAXELIB_DIR"
    haxelib setup "$HAXELIB_DIR"
    
    echo -e "${GREEN}haxelib configurado en: $HAXELIB_DIR${NC}"
}

# Función para instalar librerías
install_libraries() {
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${GREEN}Instalando librerías para Psych Engine 0.7.3${NC}"
    echo -e "${BLUE}==============================================${NC}"
    
    haxelib --never install flixel 5.5.0
    haxelib --never install flixel-addons 3.2.1
    haxelib --never install flixel-tools 1.5.1
    haxelib --never install flixel-ui 2.5.0
    haxelib --never git flxanimate https://github.com/ShadowMario/flxanimate.git dev
    haxelib --never git hxCodec https://github.com/polybiusproxy/hxCodec.git
    haxelib --never install hxcpp-debug-server 1.2.4
    haxelib --never git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc.git
    haxelib --never install lime 8.0.1
    haxelib --never git linc_luajit https://github.com/superpowers04/linc_luajit.git
    haxelib --never install openfl 9.3.2
    haxelib --never install tjson 1.4.0
    
    echo -e "${GREEN}Instalando SScript 21.0.0...${NC}"
    python "$(dirname "$0")/install.py" 21.0.0
    
    echo -e "${GREEN}Todas las librerías han sido instaladas.${NC}"
}

# Menú principal
main_menu() {
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${GREEN}MENÚ DE INSTALACIÓN DE HAXE $HAXE_VERSION${NC}"
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${YELLOW}Selecciona tu distribución:${NC}"
    echo "1) Ubuntu/Debian"
    echo "2) Fedora"
    echo "3) Arch Linux"
    echo "4) Instalar usando binarios (recomendado para versión específica)"
    echo "5) Omitir instalación de Haxe (si ya está instalado)"
    echo "6) Salir"
    
    read -p "Opción [1-6]: " option
    
    case $option in
        1) install_haxe_ubuntu ;;
        2) install_haxe_fedora ;;
        3) install_haxe_arch ;;
        4) install_haxe_binaries ;;
        5) echo -e "${YELLOW}Omitiendo instalación de Haxe.${NC}" ;;
        6) echo -e "${RED}Instalación cancelada.${NC}"; exit 0 ;;
        *) echo -e "${RED}Opción inválida.${NC}"; main_menu ;;
    esac
}

# Inicio del script
if check_haxe; then
    echo -e "${GREEN}Haxe $HAXE_VERSION ya está instalado.${NC}"
    read -p "¿Deseas continuar con la instalación de librerías? (S/N): " continue_install
    if [[ $continue_install != [Ss]* ]]; then
        echo -e "${RED}Instalación cancelada.${NC}"
        exit 0
    fi
else
    main_menu
fi

# Configurar haxelib y instalar librerías
setup_haxelib
install_libraries

echo -e "${BLUE}==============================================${NC}"
echo -e "${GREEN}Configuración completada para Psych Engine 0.7.3!${NC}"
echo -e "${GREEN}Librerías instaladas en: $HAXELIB_DIR${NC}"
echo -e "${BLUE}==============================================${NC}"
