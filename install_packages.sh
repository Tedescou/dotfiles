#!/bin/bash

# --- Color Definitions ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo -e "${BLUE}${BOLD}=================================================="
echo -e "      CROSS-PLATFORM PACKAGE INSTALLER 📦         "
echo -e "==================================================${NC}\n"

# Detect OS
OS_TYPE="$(uname)"
DISTRO=""

# Packages lists (Core utilities, editors, shells, compilers)
COMMON_PACKAGES=(git curl wget tmux screen htop vim neovim zsh tree jq)

# --- 1. Detect Environment ---
if [ "$OS_TYPE" = "Darwin" ]; then
    echo -e "Entorno detectado: ${GREEN}macOS (Darwin)${NC}"
elif [ "$OS_TYPE" = "Linux" ]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        echo -e "Entorno detectado: ${GREEN}Linux (${NAME})${NC}"
    else
        echo -e "${RED}Imposible detectar sabor de Linux. No se encontró /etc/os-release.${NC}"
        exit 1
    fi
else
    echo -e "${RED}Sistema operativo no soportado: $OS_TYPE${NC}"
    exit 1
fi

# --- 2. Installer Functions ---

install_mac() {
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}⚠ Homebrew no está instalado.${NC}"
        read -p "¿Deseas instalar Homebrew ahora? (s/n): " install_brew
        if [[ "$install_brew" =~ ^[Ss]$ ]]; then
            echo -e "Instalando Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add to PATH temporarily for the script run
            eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
        else
            echo -e "${RED}Se requiere Homebrew para instalar los paquetes. Saliendo...${NC}"
            exit 1
        fi
    fi

    echo -e "\n${BLUE}Actualizando Homebrew...${NC}"
    brew update

    echo -e "\n${BLUE}Instalando paquetes base:${NC} ${COMMON_PACKAGES[*]}"
    brew install "${COMMON_PACKAGES[@]}"

    # Verify Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        echo -e "${YELLOW}⚠ Xcode Command Line Tools no detectados. Iniciando instalador...${NC}"
        xcode-select --install
    else
        echo -e "${GREEN}✓ Xcode Command Line Tools ya instalados.${NC}"
    fi
}

install_debian_ubuntu() {
    echo -e "\n${BLUE}Actualizando índices de paquetes (apt-get update)...${NC}"
    sudo apt-get update -y

    # Build tools
    local extra_packages=(build-essential)
    local all_pkgs=("${COMMON_PACKAGES[@]}" "${extra_packages[@]}")

    echo -e "\n${BLUE}Instalando paquetes via apt:${NC} ${all_pkgs[*]}"
    sudo apt-get install -y "${all_pkgs[@]}"
}

install_arch() {
    echo -e "\n${BLUE}Sincronizando base de datos de paquetes (pacman -Sy)...${NC}"
    sudo pacman -Sy --noconfirm

    # Build tools
    local extra_packages=(base-devel)
    local all_pkgs=("${COMMON_PACKAGES[@]}" "${extra_packages[@]}")

    echo -e "\n${BLUE}Instalando paquetes via pacman:${NC} ${all_pkgs[*]}"
    # base-devel is a group, we handle it natively
    sudo pacman -S --needed --noconfirm "${all_pkgs[@]}"
}

install_fedora() {
    echo -e "\n${BLUE}Actualizando caché de paquetes (dnf makecache)...${NC}"
    sudo dnf makecache

    # Build tools
    local extra_packages=("@development-tools")
    local all_pkgs=("${COMMON_PACKAGES[@]}" "${extra_packages[@]}")

    echo -e "\n${BLUE}Instalando paquetes via dnf:${NC} ${all_pkgs[*]}"
    sudo dnf install -y "${all_pkgs[@]}"
}

# --- 3. Execute Installation ---
echo -e "\n${YELLOW}Los siguientes paquetes esenciales serán instalados:${NC}"
echo -e "  - ${BOLD}Core Utilities:${NC} ${COMMON_PACKAGES[*]}"
if [ "$OS_TYPE" = "Darwin" ]; then
    echo -e "  - ${BOLD}Compiladores:${NC} Xcode Command Line Tools"
else
    echo -e "  - ${BOLD}Compiladores:${NC} build-essential / base-devel / development-tools"
fi

read -p "¿Deseas proceder con la instalación? (s/n): " proceed
if [[ ! "$proceed" =~ ^[Ss]$ ]]; then
    echo -e "${RED}Instalación cancelada por el usuario.${NC}"
    exit 0
fi

if [ "$OS_TYPE" = "Darwin" ]; then
    install_mac
elif [ "$OS_TYPE" = "Linux" ]; then
    case "$DISTRO" in
        ubuntu|debian|mint|pop|kali|elementary)
            install_debian_ubuntu
            ;;
        arch|manjaro|endeavouros)
            install_arch
            ;;
        fedora|centos|rhel|rocky|almalinux)
            install_fedora
            ;;
        *)
            # Fallback based on package manager command existence
            if command -v apt-get &> /dev/null; then
                echo -e "${YELLOW}Distribución '$DISTRO' no listada explícitamente, pero detectamos 'apt-get'. Usando instalador Debian...${NC}"
                install_debian_ubuntu
            elif command -v pacman &> /dev/null; then
                echo -e "${YELLOW}Distribución '$DISTRO' no listada explícitamente, pero detectamos 'pacman'. Usando instalador Arch...${NC}"
                install_arch
            elif command -v dnf &> /dev/null; then
                echo -e "${YELLOW}Distribución '$DISTRO' no listada explícitamente, pero detectamos 'dnf'. Usando instalador Fedora...${NC}"
                install_fedora
            else
                echo -e "${RED}Lo siento, tu distribución '$DISTRO' no cuenta con un gestor de paquetes soportado (apt, pacman, dnf).${NC}"
                echo -e "Por favor instala los siguientes paquetes manualmente: ${COMMON_PACKAGES[*]}"
                exit 1
            fi
            ;;
    esac
fi

echo -e "\n${GREEN}${BOLD}=================================================="
echo -e "        INSTALACIÓN COMPLETADA CON ÉXITO! 🎉      "
echo -e "==================================================${NC}\n"
