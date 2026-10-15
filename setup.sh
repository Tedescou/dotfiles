#!/usr/bin/env bash
set -e

echo "=== INICIANDO REFACTORIZACIÓN DE DOTFILES ==="

# 1. Crear directorios base de trabajo
echo "[+] Creando directorios ~/perso y ~/corpo..."
mkdir -p ~/perso ~/corpo

# 2. Pedir datos para la configuración
echo "--- Configuración de Identidad Personal ---"
read -p "Nombre Personal: " PERSO_NAME
read -p "Email Personal: " PERSO_EMAIL
read -sp "Token / Password Personal (opcional): " PERSO_TOKEN

echo "--- Configuración de Identidad Corporativa ---"
read -p "Nombre Corporativo: " CORPO_NAME
read -p "Email Corporativo: " CORPO_EMAIL
read -sp "Token / Password Corporativo (opcional): " CORPO_TOKEN

# 3. Generar archivos de Git desde las plantillas
echo "[+] Generando configuraciones de Git..."
sed -e "s|{{NAME}}|$PERSO_NAME|g" -e "s|{{EMAIL}}|$PERSO_EMAIL|g" templates/gitconfig-perso.tmpl > ~/.gitconfig-perso
sed -e "s|{{NAME}}|$CORPO_NAME|g" -e "s|{{EMAIL}}|$CORPO_EMAIL|g" templates/gitconfig-corpo.tmpl > ~/.gitconfig-corpo

# 4. Generar archivos de Git desde las plantillas (o directamente)
echo "[+] Generando configuraciones de Git..."

cat << EOF > ~/.gitconfig-perso
[user]
    name = $PERSO_NAME
    email = $PERSO_EMAIL
[credential]
    helper = store
EOF

cat << EOF > ~/.gitconfig-corpo
[user]
    name = $CORPO_NAME
    email = $CORPO_EMAIL
[credential]
    helper = store
EOF
# Si querés autoguardar el token de forma persistente para que no lo pida nunca más:
if [ -n "$PERSO_TOKEN" ]; then
    # Opcional: Podés inyectar credenciales pre-stuffed en ~/.git-credentials si lo deseas
    echo "Configurando credenciales persistentes..."
fi

# 5. Enlaces simbólicos para Kitty y Screen
echo "[+] Creando enlaces simbólicos para Kitty y Screen..."
mkdir -p ~/.config/kitty
ln -sf ~/.dotfiles/cfg/kitty.conf ~/.config/kitty/kitty.conf
ln -sf ~/.dotfiles/cfg/screenrc ~/.screenrc

echo "=== ¡Instalación y configuración completadas con éxito! ==="