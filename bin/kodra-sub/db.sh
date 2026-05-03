#!/usr/bin/env bash
set -e
#
# Kodra WSL DB — Dev database containers
#
# Usage:
#   kodra db <postgres|mysql|redis|mongodb> [start|stop|status]
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
DB_DATA_DIR="${KODRA_CONFIG_DIR}/db-data"

source "${KODRA_DIR}/lib/utils.sh"
source "${KODRA_DIR}/lib/ui.sh"

show_db_help() {
    echo ""
    echo -e "  ${C_BOLD}Usage:${C_RESET} kodra db <database> [start|stop|status]"
    echo ""
    echo -e "  ${C_BOLD}Databases:${C_RESET}"
    echo -e "    postgres   PostgreSQL on port 5432 (user: kodra, pass: kodra)"
    echo -e "    mysql      MySQL on port 3306 (user: kodra, pass: kodra)"
    echo -e "    redis      Redis on port 6379"
    echo -e "    mongodb    MongoDB on port 27017"
    echo ""
    echo -e "  ${C_BOLD}Actions:${C_RESET}"
    echo -e "    start      Start the database container"
    echo -e "    stop       Stop the database container"
    echo -e "    status     Show container status"
    echo ""
}

check_docker() {
    if ! command_exists docker; then
        show_error "Docker is required. Install it with: kodra install docker-ce"
        return 1
    fi
    if ! docker info &>/dev/null; then
        show_error "Docker daemon is not running. Start it with: sudo systemctl start docker"
        return 1
    fi
    return 0
}

container_name() {
    echo "kodra-${1}"
}

db_start() {
    local db="$1"
    local name
    name="$(container_name "${db}")"
    mkdir -p "${DB_DATA_DIR}/${db}"

    # Check if already running
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${name}$"; then
        show_info "${db} is already running."
        return 0
    fi

    # Remove stopped container if exists
    docker rm -f "${name}" &>/dev/null || true

    echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Starting ${db}..."

    case "${db}" in
        postgres)
            docker run -d \
                --name "${name}" \
                -p 5432:5432 \
                -e POSTGRES_USER=kodra \
                -e POSTGRES_PASSWORD=kodra \
                -e POSTGRES_DB=kodra \
                -v "${DB_DATA_DIR}/postgres:/var/lib/postgresql/data" \
                postgres:latest &>/dev/null
            show_success "PostgreSQL running on port 5432 (user: kodra, pass: kodra)"
            ;;
        mysql)
            docker run -d \
                --name "${name}" \
                -p 3306:3306 \
                -e MYSQL_ROOT_PASSWORD=kodra \
                -e MYSQL_USER=kodra \
                -e MYSQL_PASSWORD=kodra \
                -e MYSQL_DATABASE=kodra \
                -v "${DB_DATA_DIR}/mysql:/var/lib/mysql" \
                mysql:latest &>/dev/null
            show_success "MySQL running on port 3306 (user: kodra, pass: kodra)"
            ;;
        redis)
            docker run -d \
                --name "${name}" \
                -p 6379:6379 \
                -v "${DB_DATA_DIR}/redis:/data" \
                redis:latest &>/dev/null
            show_success "Redis running on port 6379"
            ;;
        mongodb)
            docker run -d \
                --name "${name}" \
                -p 27017:27017 \
                -v "${DB_DATA_DIR}/mongodb:/data/db" \
                mongo:latest &>/dev/null
            show_success "MongoDB running on port 27017"
            ;;
    esac
}

db_stop() {
    local db="$1"
    local name
    name="$(container_name "${db}")"

    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${name}$"; then
        echo -e "  ${C_CYAN}${BOX_ARROW}${C_RESET} Stopping ${db}..."
        docker stop "${name}" &>/dev/null
        docker rm "${name}" &>/dev/null || true
        show_success "${db} stopped."
    else
        show_info "${db} is not running."
    fi
}

db_status() {
    local db="$1"
    local name
    name="$(container_name "${db}")"

    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${name}$"; then
        local port
        port="$(docker port "${name}" 2>/dev/null | head -1 || echo "unknown")"
        echo -e "  ${C_GREEN}${BOX_CHECK}${C_RESET} ${db} is ${C_GREEN}running${C_RESET} ${C_DIM}(${port})${C_RESET}"
    elif docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${name}$"; then
        echo -e "  ${C_YELLOW}${BOX_WARN}${C_RESET} ${db} is ${C_YELLOW}stopped${C_RESET}"
    else
        echo -e "  ${C_GRAY}${BOX_DOT}${C_RESET} ${db} is ${C_DIM}not created${C_RESET}"
    fi
}

db_status_all() {
    echo ""
    echo -e "  ${C_BOLD}Database containers:${C_RESET}"
    echo ""
    for db in postgres mysql redis mongodb; do
        db_status "${db}"
    done
    echo ""
}

# Validate database name
validate_db() {
    local db="$1"
    case "${db}" in
        postgres|mysql|redis|mongodb) return 0 ;;
        *)
            show_error "Unknown database: ${db}"
            echo -e "  ${C_DIM}Supported: postgres, mysql, redis, mongodb${C_RESET}"
            return 1
            ;;
    esac
}

case "${1:-}" in
    -h|--help|help)
        show_db_help
        ;;
    "")
        check_docker || exit 1
        db_status_all
        ;;
    postgres|mysql|redis|mongodb)
        check_docker || exit 1
        validate_db "$1"
        case "${2:-status}" in
            start|up)
                db_start "$1"
                ;;
            stop|down)
                db_stop "$1"
                ;;
            status)
                db_status "$1"
                ;;
            *)
                show_error "Unknown action: $2"
                show_db_help
                exit 1
                ;;
        esac
        ;;
    *)
        show_error "Unknown database: $1"
        show_db_help
        exit 1
        ;;
esac
