#!/usr/bin/env bash
# ==============================================================================
# Darlene Dotfiles - Setup & Installation Script
# ==============================================================================

set -e

# Colors & Formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

log_info()    { echo -e "${BLUE}${BOLD}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}${BOLD}[OK]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}${BOLD}[WARN]${RESET} $1"; }
log_error()   { echo -e "${RED}${BOLD}[ERROR]${RESET} $1"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    cat << EOF
Usage: ./install.sh [OPTIONS]

Installation script for Darlene dotfiles configuration.

Options:
  --help, -h          Show this help message.
  --check-deps        Only check system dependencies.
  --no-build          Skip building the Rust IPC daemon (darlene).
  --backup            Backup existing configurations to ~/.config_backup_<timestamp>.

Example:
  ./install.sh
  ./install.sh --check-deps
EOF
}

CHECK_ONLY=false
SKIP_BUILD=false
CREATE_BACKUP=false

for arg in "$@"; do
    case $arg in
        --help|-h)
            show_help
            exit 0
            ;;
        --check-deps)
            CHECK_ONLY=true
            ;;
        --no-build)
            SKIP_BUILD=true
            ;;
        --backup)
            CREATE_BACKUP=true
            ;;
        *)
            log_error "Unknown option: $arg"
            show_help
            exit 1
            ;;
    esac
done

echo -e "${BOLD}"
echo "  ____             _                   ____  _        "
echo " |  _ \  __ _ _ __| | ___ _ __   ___  |  _ \| |_ ___  "
echo " | | | |/ _\` | '__| |/ _ \ '_ \ / _ \ | | | | __/ __| "
echo " | |_| | (_| | |  | |  __/ | | |  __/ | |_| | |_\__ \ "
echo " |____/ \__,_|_|  |_|\___|_| |_|\___| |____/ \__|___/ "
echo -e "${RESET}"
echo -e "${BLUE}Hyprland Desktop Environment Setup${RESET}\n"

# 1. Dependency Check
log_info "Checking system dependencies..."

DEPENDENCIES_REQUIRED=(
    "hyprland:Window Manager"
    "kitty:Terminal Emulator"
    "eww:Widget System"
    "rofi:Application Launcher"
    "mako:Notification Daemon"
    "nvim:Neovim Editor"
    "cargo:Rust Package Manager"
    "jq:JSON Processor"
    "wpctl:WirePlumber Control"
    "brightnessctl:Brightness Control"
)

DEPENDENCIES_OPTIONAL=(
    "wal:Pywal Color Palette Generator"
    "awww-daemon:Wallpaper Daemon"
    "hyprpaper:Hyprland Wallpaper Utility"
    "hyprlock:Screen Locker"
)

MISSING_REQUIRED=0

for dep in "${DEPENDENCIES_REQUIRED[@]}"; do
    cmd="${dep%%:*}"
    desc="${dep#*:}"
    if command -v "$cmd" &>/dev/null; then
        echo -e "  [${GREEN}✓${RESET}] $cmd ($desc)"
    else
        echo -e "  [${RED}✗${RESET}] $cmd ($desc) - ${RED}Not found${RESET}"
        MISSING_REQUIRED=$((MISSING_REQUIRED + 1))
    fi
done

echo ""
log_info "Checking optional/recommended tools..."
for dep in "${DEPENDENCIES_OPTIONAL[@]}"; do
    cmd="${dep%%:*}"
    desc="${dep#*:}"
    if command -v "$cmd" &>/dev/null; then
        echo -e "  [${GREEN}✓${RESET}] $cmd ($desc)"
    else
        echo -e "  [${YELLOW}!${RESET}] $cmd ($desc) - Optional"
    fi
done

if [ "$MISSING_REQUIRED" -gt 0 ]; then
    log_warn "Found $MISSING_REQUIRED missing required dependencies."
    log_warn "Make sure to install the required packages for proper functionality."
fi

if [ "$CHECK_ONLY" = true ]; then
    log_success "Dependency check complete."
    exit 0
fi

# 2. Backup (Optional)
if [ "$CREATE_BACKUP" = true ]; then
    BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
    log_info "Creating backup at: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    for dir in hypr eww kitty mako nvim rofi; do
        if [ -d "$HOME/.config/$dir" ] && [ "$HOME/.config/$dir" != "$DOTFILES_DIR/$dir" ]; then
            cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
            log_success "Backed up $dir"
        fi
    done
fi

# 3. Executable Permissions
log_info "Setting executable permissions on scripts..."
chmod +x "$DOTFILES_DIR/install.sh"
if [ -d "$DOTFILES_DIR/eww/scripts" ]; then
    find "$DOTFILES_DIR/eww/scripts" -type f -name "*.sh" -exec chmod +x {} +
    log_success "Executable permissions granted to Eww scripts."
fi

# 4. Build Rust Daemon (darlene)
if [ "$SKIP_BUILD" = false ]; then
    if [ -d "$DOTFILES_DIR/darlene" ] && command -v cargo &>/dev/null; then
        log_info "Building Darlene daemon (Rust)..."
        (
            cd "$DOTFILES_DIR/darlene"
            cargo build --release
        )
        log_success "Darlene daemon compiled successfully: darlene/target/release/darlene"
    elif ! command -v cargo &>/dev/null; then
        log_warn "Cargo is not installed. Skipping Darlene daemon build."
    fi
else
    log_info "Skipping daemon build (--no-build active)."
fi

echo ""
log_success "Darlene Dotfiles setup completed successfully!"
echo -e "\n${BOLD}Recommended next steps:${RESET}"
echo -e "  1. Reload Hyprland with: ${BLUE}hyprctl reload${RESET}"
echo -e "  2. Start the Darlene daemon if not already running: ${BLUE}~/.config/darlene/target/release/darlene start${RESET}"
echo -e "  3. Check ${BLUE}README.md${RESET} for keyboard shortcuts and widget details.\n"
