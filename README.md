
Toda la papa que uso pero pensado de manera que pueda levantarlo facil (Kitty, Screen, herdr) y resuelve la gestión dinámica de identidades y credenciales de Git (Personal vs. Corporativo) según la ruta del proyecto.

- Identidad Dinámica de Git (includeIf): Aplica automáticamente tu nombre, email y configuraciones de Git según el directorio en el que clones un proyecto.

- Persistencia de Credenciales: Permite ingresar tokens o contraseñas al momento de la instalación para almacenarlos mediante el credential.helper de Git sin exponer datos sensibles en tu repositorio.

- Vinculación por Symlinks: Mantiene sincronizadas las configuraciones de kitty.conf y screenrc con tus rutas del sistema.

- Bootstrap Automatizado: Script interactivo de instalación (setup.sh) que deja un sistema limpio listo en pocos segundos.

Estructura del Repositorio

```
.dotfiles/
├── setup.sh                 # Script principal interactivo de instalación
├── install_packages.sh      # Instalación opcional de paquetes del sistema
├── ssh_config_snippet       # Snippet de ayuda para configuraciones SSH
├── cfg/
│   ├── kitty.conf           # Configuración pública de Kitty Terminal
│   └── screenrc             # Configuración pública de GNU Screen
├── templates/
│   ├── gitconfig-perso.tmpl # Plantilla para identidad personal
│   └── gitconfig-corpo.tmpl # Plantilla para identidad corporativa
└── README.md
```


El script setup.sh crea dos directorios de trabajo raíz en tu $HOME:

~/perso/: Para proyectos personales y repositorios propios.

~/corpo/: Para proyectos laborales o corporativos.

Al instalarse, escribe un archivo global ~/.gitconfig con reglas condicionales:

[includeIf "gitdir:~/perso/"]
    path = ~/.gitconfig-perso

[includeIf "gitdir:~/corpo/"]
    path = ~/.gitconfig-corpo


Cuando navegas hacia un repositorio dentro de ~/perso/, Git activa los valores definidos en ~/.gitconfig-perso. Si te mueves a ~/corpo/, tomará de manera transparente los valores de ~/.gitconfig-corpo.

### Instalación y Despliegue

Clonar el repo y correr ./setup.sh

Podés comprobar que la asignación automática funciona creando o navegando a un repositorio existente dentro de cada directorio. Ejemplo: 

```bash
cd ~/corpo/proyecto-empresa
git config user.email
# Debería devolver tu mail corporativo
```
