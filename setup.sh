#!/bin/bash

# Laravel Multi-Site Development Environment - Site Management Script
# This script helps you manage multiple Laravel sites with different PHP versions

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Laravel Multi-Site Development Environment${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first:"
        echo "  https://docs.docker.com/engine/install/"
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed or too old."
        echo "  Please install Docker Compose 2.0+:"
        echo "  https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    print_success "Docker and Docker Compose are installed"
}

# Generate random password
generate_password() {
    # Start with a letter to avoid issues with special chars at beginning
    # Generate password starting with letter, then alphanumeric + underscore only
    # Safe for .env files and INI parsing
    local first_char=$(LC_ALL=C tr -dc 'A-Za-z' < /dev/urandom | head -c 1)
    local rest_chars=$(LC_ALL=C tr -dc 'A-Za-z0-9_' < /dev/urandom | head -c 31)
    echo "${first_char}${rest_chars}"
}

# Check if .env file exists
check_env_file() {
    if [ ! -f .env ]; then
        print_warning ".env file not found"
        print_info "Creating initial .env file..."
        create_initial_env
    else
        # Validate UID/GID in existing .env (don't source since UID is read-only)
        ENV_UID=$(grep "^UID=" .env | cut -d'=' -f2)
        ENV_GID=$(grep "^GID=" .env | cut -d'=' -f2)
        CURRENT_UID=$(id -u)
        CURRENT_GID=$(id -g)
        
        if [ "$ENV_UID" != "$CURRENT_UID" ] || [ "$ENV_GID" != "$CURRENT_GID" ]; then
            print_warning "UID/GID mismatch detected in .env file!"
            print_info "  Current user: UID=${CURRENT_UID}, GID=${CURRENT_GID}"
            print_info "  In .env file: UID=${ENV_UID}, GID=${ENV_GID}"
            echo ""
            read -p "Update .env with correct UID/GID? [Y/n]: " fix_ids
            fix_ids=${fix_ids:-Y}
            
            if [[ $fix_ids =~ ^[Yy]$ ]]; then
                sed -i.bak "s/^UID=.*/UID=${CURRENT_UID}/" .env
                sed -i.bak "s/^GID=.*/GID=${CURRENT_GID}/" .env
                rm -f .env.bak
                print_success "Updated .env with correct UID/GID"
                print_warning "Restart containers for changes to take effect: docker compose restart"
            fi
        fi
    fi
}

# Create initial .env file
create_initial_env() {
    USER_ID=$(id -u)
    GROUP_ID=$(id -g)
    MYSQL_ROOT_PASS=$(generate_password)
    
    # Explain UID/GID to the user
    USERNAME=$(whoami)
    echo ""
    print_info "Setting up file permissions for Docker containers..."
    echo ""
    echo "Docker containers run as root by default, which creates files owned by root."
    echo "To avoid permission issues, we configure containers to use YOUR user ID."
    echo ""
    print_info "Configuring Docker with your user permissions:"
    print_info "  User: ${USERNAME}"
    print_info "  UID: ${USER_ID} (User ID)"
    print_info "  GID: ${GROUP_ID} (Primary Group ID)"
    echo ""
    echo "This ensures all files created by Docker belong to you, not root."
    echo ""
    
    cat > .env << EOF
# Docker User Configuration
UID=${USER_ID}
GID=${GROUP_ID}

# MySQL Root Password (for administrative tasks)
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASS}

# MySQL Performance Configuration (Optimized for 4GB Server)
MYSQL_INNODB_BUFFER_POOL_SIZE=2G
MYSQL_INNODB_LOG_FILE_SIZE=512M
MYSQL_INNODB_FLUSH_LOG_AT_TRX_COMMIT=2
MYSQL_MAX_CONNECTIONS=200
MYSQL_TABLE_OPEN_CACHE=4000
MYSQL_SORT_BUFFER_SIZE=4M
MYSQL_READ_BUFFER_SIZE=2M
MYSQL_JOIN_BUFFER_SIZE=2M
MYSQL_TMP_TABLE_SIZE=128M
MYSQL_MAX_HEAP_TABLE_SIZE=128M

# Default Database (optional - sites can have their own)
MYSQL_DATABASE=laravel
MYSQL_USER=laravel_usr
MYSQL_PASSWORD=$(generate_password)
EOF
    
    print_success "Created .env file with secure passwords"
    print_warning "MySQL root password saved in .env file - keep it safe!"
}

# Get PHP version selection
select_php_version() {
    echo -e "\n${GREEN}PHP Version Selection${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Select the PHP version for this site:"
    echo ""
    echo "  1) PHP 8.1"
    echo "  2) PHP 8.2"
    echo "  3) PHP 8.3"
    echo "  4) PHP 8.4 [Default]"
    echo ""
    
    while true; do
        read -p "Select option [1-4] (default: 4): " php_choice
        php_choice=${php_choice:-4}
        
        case $php_choice in
            1)
                PHP_VERSION="81"
                PHP_VERSION_DISPLAY="PHP 8.1"
                print_success "Selected PHP 8.1"
                break
                ;;
            2)
                PHP_VERSION="82"
                PHP_VERSION_DISPLAY="PHP 8.2"
                print_success "Selected PHP 8.2"
                break
                ;;
            3)
                PHP_VERSION="83"
                PHP_VERSION_DISPLAY="PHP 8.3"
                print_success "Selected PHP 8.3"
                break
                ;;
            4)
                PHP_VERSION="84"
                PHP_VERSION_DISPLAY="PHP 8.4"
                print_success "Selected PHP 8.4"
                break
                ;;
            *)
                print_error "Invalid choice. Please select 1-4."
                ;;
        esac
    done
}

# Create database and user
create_database() {
    local db_name=$1
    local db_user=$2
    local db_pass=$3
    
    print_info "Creating database and user..."
    
    # Get root password from .env (grep to avoid sourcing UID/GID which are readonly)
    MYSQL_ROOT_PASSWORD=$(grep "^MYSQL_ROOT_PASSWORD=" .env | cut -d '=' -f2-)
    
    # Wait for MySQL to be ready
    print_info "Waiting for MySQL to be ready..."
    until docker exec mysql mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} --silent &> /dev/null; do
        sleep 1
    done
    
    # Create database and user
    docker exec mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "
CREATE DATABASE IF NOT EXISTS \`${db_name}\`;
CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_pass}';
GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'%';
FLUSH PRIVILEGES;
" 2>&1
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        print_success "Database '${db_name}' and user '${db_user}' created successfully"
    else
        print_error "Failed to create database (exit code: ${exit_code})"
        return 1
    fi
}

# Create vhost configuration
create_vhost() {
    local site_name=$1
    local domain=$2
    local php_version=$3
    
    local vhost_file="config/vhosts/${site_name}.conf"
    
    if [ -f "$vhost_file" ]; then
        print_warning "Virtual host configuration already exists: ${vhost_file}"
        read -p "Overwrite? [y/N]: " overwrite
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            print_info "Skipping vhost creation"
            return 0
        fi
    fi
    
    # Read template and replace variables
    if [ ! -f "config/vhosts/site.conf.template" ]; then
        print_error "Template file not found: config/vhosts/site.conf.template"
        return 1
    fi
    
    sed -e "s/{SITE_NAME}/${site_name}/g" \
        -e "s/{DOMAIN}/${domain}/g" \
        -e "s/{PHP_VERSION}/${php_version}/g" \
        config/vhosts/site.conf.template > "$vhost_file"
    
    print_success "Created virtual host configuration: ${vhost_file}"
    print_info "Site will be accessible at: http://${domain}"
}

# Add new site
add_site() {
    print_header
    echo -e "${CYAN}Adding New Site${NC}\n"
    
    # Get site name
    while true; do
        read -p "Enter site name (lowercase, no spaces, e.g., 'myapp'): " SITE_NAME
        
        if [ -z "$SITE_NAME" ]; then
            print_error "Site name cannot be empty"
            continue
        fi
        
        # Validate site name
        if [[ ! "$SITE_NAME" =~ ^[a-z0-9_-]+$ ]]; then
            print_error "Site name can only contain lowercase letters, numbers, hyphens, and underscores"
            continue
        fi
        
        # Check if site directory already exists
        if [ -d "sites/$SITE_NAME" ]; then
            print_warning "Directory 'sites/$SITE_NAME' already exists"
            read -p "Continue anyway? [y/N]: " continue_anyway
            if [[ ! $continue_anyway =~ ^[Yy]$ ]]; then
                print_info "Cancelled"
                return 0
            fi
        fi
        
        break
    done
    
    # Get domain
    read -p "Enter domain (e.g., 'myapp.test' or press Enter for '${SITE_NAME}.test'): " DOMAIN
    DOMAIN=${DOMAIN:-${SITE_NAME}.test}
    
    # Select PHP version
    select_php_version
    
    # Ask about database creation
    echo -e "\n${GREEN}Database Configuration${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    read -p "Create a new database for this site? [Y/n]: " create_db
    create_db=${create_db:-Y}
    
    if [[ $create_db =~ ^[Yy]$ ]]; then
        read -p "Database name (default: ${SITE_NAME}): " DB_NAME
        DB_NAME=${DB_NAME:-${SITE_NAME}}
        
        read -p "Database user (default: ${SITE_NAME}_usr): " DB_USER
        DB_USER=${DB_USER:-${SITE_NAME}_usr}
        
        read -p "Generate secure password? [Y/n]: " gen_pass
        gen_pass=${gen_pass:-Y}
        
        if [[ $gen_pass =~ ^[Yy]$ ]]; then
            DB_PASS=$(generate_password)
        else
            read -sp "Database password: " DB_PASS
            echo ""
        fi
    fi
    
    # Ask about Laravel installation
    echo -e "\n${GREEN}Laravel Installation${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "What would you like to do?"
    echo ""
    echo "  1) Create new Laravel project"
    echo "  2) I'll clone an existing project manually"
    echo ""
    
    read -p "Select option [1-2]: " install_choice
    
    CREATE_LARAVEL=false
    STARTER_KIT="none"
    
    if [ "$install_choice" = "1" ]; then
        CREATE_LARAVEL=true
        
        # Only offer starter kits for PHP 8.4 (latest)
        if [ "${PHP_VERSION}" = "84" ]; then
            # Ask about starter kit
            echo -e "\n${GREEN}Laravel Starter Kit${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Choose a starter kit for your Laravel application:"
            echo ""
            echo "  1) No starter kit - Blank Laravel application"
            echo "  2) React - Modern SPA with React 19, TypeScript, Inertia, shadcn/ui"
            echo "  3) Vue - Modern SPA with Vue 3, TypeScript, Inertia, shadcn-vue"
            echo "  4) Livewire - Full-stack with Livewire 4, Blade, Flux UI"
            echo ""
            echo "Learn more: https://laravel.com/docs/12.x/starter-kits"
            echo ""
            
            read -p "Select option [1-4]: " starter_choice
            
            case $starter_choice in
                1)
                    STARTER_KIT="none"
                    print_success "Will install Laravel without starter kit"
                    ;;
                2)
                    STARTER_KIT="react"
                    print_success "Will install Laravel with React starter kit"
                    ;;
                3)
                    STARTER_KIT="vue"
                    print_success "Will install Laravel with Vue starter kit"
                    ;;
                4)
                    STARTER_KIT="livewire"
                    print_success "Will install Laravel with Livewire starter kit"
                    ;;
                *)
                    STARTER_KIT="none"
                    print_warning "Invalid option. Installing Laravel without starter kit"
                    ;;
            esac
        else
            print_info "Starter kits are only available with PHP 8.4 (latest)"
            print_info "Will install Laravel without starter kit"
        fi
    fi
    
    # Summary
    echo -e "\n${CYAN}Summary${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Site Name:    ${SITE_NAME}"
    echo "  Domain:       ${DOMAIN}"
    echo "  PHP Version:  ${PHP_VERSION_DISPLAY}"
    if [[ $create_db =~ ^[Yy]$ ]]; then
        echo "  Database:     ${DB_NAME}"
        echo "  DB User:      ${DB_USER}"
        echo "  DB Password:  ${DB_PASS}"
    fi
    if [ "$CREATE_LARAVEL" = true ]; then
        if [ "$STARTER_KIT" != "none" ]; then
            STARTER_KIT_DISPLAY="$(echo ${STARTER_KIT} | sed 's/.*/\u&/')"
            echo "  Laravel:      New project with ${STARTER_KIT_DISPLAY} starter kit"
        else
            echo "  Laravel:      New project (no starter kit)"
        fi
    else
        echo "  Laravel:      Manual setup"
    fi
    echo ""
    
    read -p "Proceed with these settings? [Y/n]: " confirm
    confirm=${confirm:-Y}
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        return 0
    fi
    
    # Create site directory if needed
    if [ ! -d "sites/$SITE_NAME" ]; then
        mkdir -p "sites/$SITE_NAME"
        print_success "Created directory: sites/$SITE_NAME"
    fi
    
    # Create vhost configuration
    create_vhost "$SITE_NAME" "$DOMAIN" "$PHP_VERSION"
    
    # Create database if requested
    if [[ $create_db =~ ^[Yy]$ ]]; then
        if docker ps | grep -q mysql; then
            create_database "$DB_NAME" "$DB_USER" "$DB_PASS"
            
            # Save credentials to credentials directory
            cat > "credentials/${SITE_NAME}.env" << EOF
# Database Credentials for ${SITE_NAME}
# Use these in your Laravel .env file

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASS}
EOF
            if [ $? -eq 0 ]; then
                chmod 644 "credentials/${SITE_NAME}.env" 2>/dev/null || true
                print_success "Database credentials saved to: credentials/${SITE_NAME}.env"
            else
                print_error "Failed to save credentials file. Please check directory permissions."
            fi
        else
            print_warning "MySQL container not running. Start it first with: docker compose up -d"
            print_info "You can create the database later by running this script again"
        fi
    fi
    
    # Create Laravel project if requested
    if [ "$CREATE_LARAVEL" = true ]; then
        print_info "Creating new Laravel 12 project..."
        
        # Remove existing directory if it exists
        if [ -d "sites/${SITE_NAME}" ]; then
            print_warning "Directory sites/${SITE_NAME} already exists, removing..."
            sudo rm -rf "sites/${SITE_NAME}"
        fi
        
        if [ "$STARTER_KIT" != "none" ]; then
            # Create Laravel project with starter kit (installer handles npm install & build)
            STARTER_KIT_DISPLAY="$(echo ${STARTER_KIT} | sed 's/.*/\u&/')"
            print_info "Installing Laravel with ${STARTER_KIT_DISPLAY} starter kit..."
            docker compose run --rm php${PHP_VERSION} sh -c "composer global require laravel/installer && cd /var/www/sites && /root/.composer/vendor/bin/laravel new ${SITE_NAME} --${STARTER_KIT} --git"
            
            print_success "${STARTER_KIT_DISPLAY} starter kit installed successfully"
        else
            # Create blank Laravel project
            docker compose run --rm php${PHP_VERSION} sh -c "composer global require laravel/installer && cd /var/www/sites && /root/.composer/vendor/bin/laravel new ${SITE_NAME} --git"
        fi
        
        # Fix file permissions - set ownership to current user on host
        print_info "Setting correct file permissions..."
        sudo chown -R $(id -u):$(id -g) "sites/${SITE_NAME}"
        
        # Ensure storage and cache directories are writable
        if [ -d "sites/${SITE_NAME}/storage" ]; then
            chmod -R 775 "sites/${SITE_NAME}/storage"
            chmod -R 775 "sites/${SITE_NAME}/bootstrap/cache"
        fi
        
        if [ -f "credentials/${SITE_NAME}.env" ]; then
            print_info "Updating Laravel .env file with database credentials..."
            # Update .env file
            if [ -f "sites/${SITE_NAME}/.env" ]; then
                sed -i.bak \
                    -e "s/DB_HOST=.*/DB_HOST=mysql/" \
                    -e "s/DB_DATABASE=.*/DB_DATABASE=${DB_NAME}/" \
                    -e "s/DB_USERNAME=.*/DB_USERNAME=${DB_USER}/" \
                    -e "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASS}/" \
                    "sites/${SITE_NAME}/.env"
                rm -f "sites/${SITE_NAME}/.env.bak"
            fi
        fi
        
        print_success "Laravel project created successfully!"
    else
        # Create a placeholder landing page for manual setup
        mkdir -p "sites/${SITE_NAME}/public"
        
        # Copy template and replace placeholders
        if [ -f "templates/placeholder.php" ]; then
            cp "templates/placeholder.php" "sites/${SITE_NAME}/public/index.php"
            sed -i.bak \
                -e "s/{SITE_NAME}/${SITE_NAME}/g" \
                -e "s/{DOMAIN}/${DOMAIN}/g" \
                "sites/${SITE_NAME}/public/index.php"
            rm -f "sites/${SITE_NAME}/public/index.php.bak"
            
            # Ensure proper permissions for manually cloned projects
            chmod -R 755 "sites/${SITE_NAME}"
            
            print_success "Created placeholder landing page with PHP diagnostics"
        else
            print_error "Template file not found: templates/placeholder.php"
        fi
    fi
    
    # Reload nginx
    if docker ps | grep -q webserver; then
        echo ""
        read -p "Reload nginx to activate the new vhost? [Y/n]: " reload_nginx
        reload_nginx=${reload_nginx:-Y}
        
        if [[ $reload_nginx =~ ^[Yy]$ ]]; then
            print_info "Reloading nginx..."
            docker exec webserver nginx -s reload
            print_success "Nginx reloaded"
        else
            print_info "Skipped nginx reload. Run 'docker exec webserver nginx -s reload' when ready."
        fi
    else
        print_warning "Webserver container not running. Start it with: docker compose up -d"
    fi
    
    # Ask to add domain to /etc/hosts
    echo ""
    read -p "Add ${DOMAIN} to /etc/hosts file? (requires sudo) [Y/n]: " add_hosts
    add_hosts=${add_hosts:-Y}
    
    if [[ $add_hosts =~ ^[Yy]$ ]]; then
        # Check if domain already exists in /etc/hosts
        if grep -q "^127.0.0.1.*${DOMAIN}" /etc/hosts 2>/dev/null; then
            print_info "Domain ${DOMAIN} already exists in /etc/hosts"
        else
            print_info "Adding ${DOMAIN} to /etc/hosts (requires sudo password)..."
            if sudo sh -c "echo '127.0.0.1  ${DOMAIN}' >> /etc/hosts"; then
                print_success "Added ${DOMAIN} to /etc/hosts"
            else
                print_error "Failed to add domain to /etc/hosts. You can add it manually:"
                echo "     ${CYAN}127.0.0.1  ${DOMAIN}${NC}"
            fi
        fi
    else
        print_info "Skipped /etc/hosts update. Add this manually:"
        echo "     ${CYAN}127.0.0.1  ${DOMAIN}${NC}"
    fi
    
    # Final instructions
    echo -e "\n${GREEN}✓ Site Added Successfully!${NC}\n"
    
    if [ "$CREATE_LARAVEL" = false ]; then
        echo "Next steps:"
        echo ""
        echo "  1. Clone or copy your Laravel project to: sites/${SITE_NAME}/"
        echo "     Example: cd sites && git clone <your-repo> ${SITE_NAME}"
        echo ""
    fi
    
    if ! docker ps | grep -q webserver; then
        echo "  2. Start the containers:"
        echo -e "     ${CYAN}docker compose up -d${NC}"
        echo ""
    fi
    
    echo -e "Access your site at: ${CYAN}http://${DOMAIN}${NC}"
    echo ""
    
    if [ -f "credentials/${SITE_NAME}.env" ]; then
        echo -e "Database credentials saved in: ${CYAN}credentials/${SITE_NAME}.env${NC}"
        echo ""
    fi
}

# List all sites
list_sites() {
    print_header
    echo -e "${CYAN}Configured Sites${NC}\n"
    
    if [ ! -d "sites" ] || [ -z "$(ls -A sites 2>/dev/null)" ]; then
        print_info "No sites found in ./sites directory"
        return 0
    fi
    
    echo -e "${BLUE}Site Directory          Domain                  PHP     VHost Config Location${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    for site_dir in sites/*/; do
        if [ -d "$site_dir" ]; then
            site_name=$(basename "$site_dir")
            
            # Skip if this is just a public directory without Laravel structure
            if [ "$site_name" = "public" ] && [ ! -f "$site_dir/artisan" ]; then
                continue
            fi
            
            vhost_file="config/vhosts/${site_name}.conf"
            
            # Extract domain and PHP version from vhost if exists
            if [ -f "$vhost_file" ]; then
                domain=$(grep "server_name" "$vhost_file" | head -1 | awk '{print $2}' | tr -d ';')
                php_raw=$(grep "fastcgi_pass" "$vhost_file" | grep -o 'php[0-9]*' | head -1)
                # Format PHP version as 8.x
                if [ ! -z "$php_raw" ]; then
                    php_num=$(echo "$php_raw" | grep -o '[0-9]*')
                    php_ver="${php_num:0:1}.${php_num:1}"
                else
                    php_ver="-"
                fi
                vhost_path="${GREEN}config/vhosts/${site_name}.conf${NC}"
            else
                domain="-"
                php_ver="-"
                vhost_path="${RED}Not configured${NC}"
            fi
            
            printf "%-23s %-23s %-7s %b\n" "$site_name" "$domain" "$php_ver" "$vhost_path"
        fi
    done
    
    echo ""
}

# Fix permissions for a site
fix_permissions() {
    print_header
    echo -e "${CYAN}Fix Site Permissions${NC}\n"
    
    list_sites
    
    read -p "Enter site name to fix permissions: " SITE_NAME
    
    if [ ! -d "sites/${SITE_NAME}" ]; then
        print_error "Site directory not found: sites/${SITE_NAME}"
        return
    fi
    
    print_info "Fixing permissions for ${SITE_NAME}..."
    
    # Get UID and GID from .env or use defaults
    if [ -f .env ]; then
        source .env
    fi
    USER_ID=${UID:-$(id -u)}
    GROUP_ID=${GID:-$(id -g)}
    
    # Fix ownership
    print_info "Setting ownership to ${USER_ID}:${GROUP_ID}..."
    sudo chown -R ${USER_ID}:${GROUP_ID} "sites/${SITE_NAME}"
    
    # Set directory permissions
    print_info "Setting directory permissions..."
    find "sites/${SITE_NAME}" -type d -exec chmod 755 {} \;
    
    # Set file permissions
    print_info "Setting file permissions..."
    find "sites/${SITE_NAME}" -type f -exec chmod 644 {} \;
    
    # Make storage and cache writable
    if [ -d "sites/${SITE_NAME}/storage" ]; then
        print_info "Making storage directories writable..."
        chmod -R 775 "sites/${SITE_NAME}/storage"
    fi
    
    if [ -d "sites/${SITE_NAME}/bootstrap/cache" ]; then
        chmod -R 775 "sites/${SITE_NAME}/bootstrap/cache"
    fi
    
    print_success "Permissions fixed for ${SITE_NAME}!"
    print_info "The site should now be accessible without permission errors."
}

# Remove site
remove_site() {
    print_header
    echo -e "${CYAN}Remove Site${NC}\n"
    
    list_sites
    
    read -p "Enter site name to remove: " SITE_NAME
    
    if [ -z "$SITE_NAME" ]; then
        print_error "Site name cannot be empty"
        return 1
    fi
    
    if [ ! -d "sites/$SITE_NAME" ]; then
        print_error "Site directory not found: sites/$SITE_NAME"
        return 1
    fi
    
    print_warning "This will remove:"
    echo "  - Virtual host configuration: config/vhosts/${SITE_NAME}.conf"
    echo ""
    
    read -p "Also remove the site directory? (sites/${SITE_NAME}/) [y/N]: " remove_dir
    
    read -p "Also remove database? [y/N]: " remove_db
    
    read -p "Also remove credentials file? (credentials/${SITE_NAME}.env) [y/N]: " remove_creds
    
    echo ""
    read -p "Are you sure you want to continue? [y/N]: " confirm
    
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        return 0
    fi
    
    # Remove vhost
    if [ -f "config/vhosts/${SITE_NAME}.conf" ]; then
        rm "config/vhosts/${SITE_NAME}.conf"
        print_success "Removed virtual host configuration"
    fi
    
    # Remove site directory if requested
    if [[ $remove_dir =~ ^[Yy]$ ]]; then
        if [ -d "sites/${SITE_NAME}" ]; then
            print_info "Removing site directory (may require sudo for root-owned files)..."
            sudo rm -rf "sites/${SITE_NAME}"
            print_success "Removed site directory: sites/${SITE_NAME}/"
        fi
    else
        print_info "Site files kept in: sites/${SITE_NAME}/"
    fi
    
    # Remove database if requested
    if [[ $remove_db =~ ^[Yy]$ ]]; then
        read -p "Enter database name to remove: " DB_NAME
        if [ ! -z "$DB_NAME" ]; then
            MYSQL_ROOT_PASSWORD=$(grep "^MYSQL_ROOT_PASSWORD=" .env | cut -d '=' -f2-)
            
            # Check if database exists first
            DB_EXISTS=$(docker exec mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES LIKE '${DB_NAME}';" 2>/dev/null | grep -c "${DB_NAME}")
            
            if [ "$DB_EXISTS" -gt 0 ]; then
                docker exec mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "DROP DATABASE \`${DB_NAME}\`;" 2>/dev/null
                if [ $? -eq 0 ]; then
                    print_success "Removed database: ${DB_NAME}"
                else
                    print_error "Failed to remove database: ${DB_NAME}"
                fi
            else
                print_warning "Database '${DB_NAME}' does not exist"
            fi
        fi
    fi
    
    # Remove credentials file if requested
    if [[ $remove_creds =~ ^[Yy]$ ]]; then
        if [ -f "credentials/${SITE_NAME}.env" ]; then
            rm "credentials/${SITE_NAME}.env"
            print_success "Removed credentials file: credentials/${SITE_NAME}.env"
        else
            print_warning "Credentials file does not exist: credentials/${SITE_NAME}.env"
        fi
    else
        if [ -f "credentials/${SITE_NAME}.env" ]; then
            print_info "Credentials kept in: credentials/${SITE_NAME}.env"
        fi
    fi
    
    # Reload nginx
    if docker ps --filter "name=webserver" --filter "status=running" | grep -q webserver; then
        print_info "Reloading nginx..."
        docker exec webserver nginx -s reload 2>/dev/null && print_success "Nginx reloaded" || print_warning "Nginx reload skipped (container may be restarting)"
    else
        print_info "Webserver not running, nginx reload not needed"
    fi
    
    print_success "Site configuration removed"
    
    if [[ ! $remove_dir =~ ^[Yy]$ ]]; then
        print_info "To remove the site files, manually delete: sites/${SITE_NAME}/"
    fi
}

# Create shell aliases
create_aliases() {
    print_header
    echo -e "${CYAN}Create Shell Aliases${NC}\n"
    
    print_info "This will add convenient shortcuts to your shell profile"
    echo ""
    echo "Available aliases:"
    echo -e "  ${CYAN}php81${NC}, ${CYAN}php82${NC}, ${CYAN}php83${NC}, ${CYAN}php84${NC}  - Enter PHP containers"
    echo -e "  ${CYAN}dclogs${NC}                    - View all container logs"
    echo -e "  ${CYAN}dcrestart${NC}                 - Restart all containers"
    echo ""
    
    read -p "Create these aliases? [Y/n]: " create_alias
    create_alias=${create_alias:-Y}
    
    if [[ ! $create_alias =~ ^[Yy]$ ]]; then
        print_info "Skipped alias creation"
        return 0
    fi
    
    # Detect user's shell (check actual shell, not the script's shell)
    USER_SHELL=$(basename "$SHELL")
    
    case "$USER_SHELL" in
        zsh)
            SHELL_RC="$HOME/.zshrc"
            ;;
        bash)
            SHELL_RC="$HOME/.bashrc"
            ;;
        *)
            # Default to .bashrc and also check for .zshrc
            if [ -f "$HOME/.zshrc" ]; then
                SHELL_RC="$HOME/.zshrc"
            else
                SHELL_RC="$HOME/.bashrc"
            fi
            ;;
    esac
    
    # Check if aliases already exist
    if grep -q "# Laravel Multi-Site Aliases" "$SHELL_RC" 2>/dev/null; then
        print_warning "Aliases already exist in $SHELL_RC"
        read -p "Replace them? [y/N]: " replace_alias
        if [[ ! $replace_alias =~ ^[Yy]$ ]]; then
            print_info "Skipped alias creation"
            return 0
        fi
        # Remove old aliases
        sed -i.bak '/# Laravel Multi-Site Aliases/,/# End Laravel Multi-Site Aliases/d' "$SHELL_RC"
        rm -f "${SHELL_RC}.bak"
    fi
    
    # Add aliases
    cat >> "$SHELL_RC" << 'EOF'

# Laravel Multi-Site Aliases
alias php81='docker compose -f "'"$(pwd)"'/docker-compose.yml" exec php81 sh'
alias php82='docker compose -f "'"$(pwd)"'/docker-compose.yml" exec php82 sh'
alias php83='docker compose -f "'"$(pwd)"'/docker-compose.yml" exec php83 sh'
alias php84='docker compose -f "'"$(pwd)"'/docker-compose.yml" exec php84 sh'
alias dclogs='docker compose -f "'"$(pwd)"'/docker-compose.yml" logs -f'
alias dcrestart='docker compose -f "'"$(pwd)"'/docker-compose.yml" restart'
# End Laravel Multi-Site Aliases
EOF
    
    print_success "Aliases added to $SHELL_RC"
    echo ""
    print_info "Reload your shell or run: ${CYAN}source $SHELL_RC${NC}"
    echo ""
    echo "Usage examples:"
    echo "  ${CYAN}php84${NC}                    # Enter PHP 8.4 container"
    echo "  ${CYAN}dclogs${NC}                   # View logs"
    echo "  ${CYAN}dcrestart${NC}                # Restart containers"
}

# Initialize environment
init_environment() {
    print_header
    echo -e "${CYAN}Initialize/Restart Development Environment${NC}\n"
    
    check_docker
    
    # Check if this is first time setup or a reset
    FIRST_TIME_SETUP=false
    if [ ! -f .env ]; then
        FIRST_TIME_SETUP=true
        print_info "First time setup detected"
        echo ""
    else
        # THIS IS A FULL RESET - SHOW MASSIVE WARNING
        echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                                                               ║${NC}"
        echo -e "${RED}║                    ⚠️  DANGER ZONE  ⚠️                        ║${NC}"
        echo -e "${RED}║                                                               ║${NC}"
        echo -e "${RED}║          THIS WILL COMPLETELY RESET YOUR ENVIRONMENT          ║${NC}"
        echo -e "${RED}║                                                               ║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}This operation will:${NC}"
        echo ""
        echo -e "  ${RED}✗${NC} Delete ALL site directories in ./sites/"
        echo -e "  ${RED}✗${NC} Remove ALL Nginx virtual host configurations"
        echo -e "  ${RED}✗${NC} Delete ALL MySQL databases and users"
        echo -e "  ${RED}✗${NC} Remove ALL Docker volumes and data"
        echo -e "  ${RED}✗${NC} Stop and remove all containers"
        echo ""
        echo -e "${YELLOW}After reset:${NC}"
        echo -e "  ${GREEN}✓${NC} Fresh MySQL instance with new root password"
        echo -e "  ${GREEN}✓${NC} Clean environment ready for new sites"
        echo ""
        print_warning "Note: Sudo password will be required to delete root-owned files"
        echo ""
        print_error "THIS CANNOT BE UNDONE!"
        echo ""
        read -p "Do you want to continue? [y/N]: " confirm_continue
        
        if [[ ! $confirm_continue =~ ^[Yy]$ ]]; then
            print_info "Operation cancelled"
            return 0
        fi
        
        echo ""
        print_warning "Second confirmation required for safety"
        read -p "Type 'RESET EVERYTHING' (exactly) to confirm: " confirm_reset
        
        if [ "$confirm_reset" != "RESET EVERYTHING" ]; then
            print_info "Operation cancelled - confirmation text did not match"
            return 0
        fi
        
        echo ""
        print_info "Beginning complete environment reset..."
        echo ""
        
        # Stop all containers
        print_info "Stopping Docker containers..."
        docker compose down
        print_success "Containers stopped"
        
        # Remove all site directories (use sudo because files may be owned by root)
        if [ -d "sites" ] && [ "$(ls -A sites)" ]; then
            print_info "Removing all site directories (requires sudo for root-owned files)..."
            sudo rm -rf sites/*
            print_success "Site directories removed"
        fi
        
        # Remove all vhost configs (except template)
        print_info "Removing Nginx configurations..."
        rm -f config/vhosts/*.conf
        print_success "Nginx configurations removed"
        
        # Remove MySQL volume
        if docker volume ls | grep -q "laraveldevelopment_mysql_data"; then
            print_info "Removing MySQL volume and all databases..."
            docker volume rm laraveldevelopment_mysql_data
            print_success "MySQL volume removed"
        fi
        
        # Remove Redis volume
        if docker volume ls | grep -q "laraveldevelopment_redis_data"; then
            print_info "Removing Redis volume..."
            docker volume rm laraveldevelopment_redis_data
            print_success "Redis volume removed"
        fi
        
        print_success "Environment completely reset!"
        echo ""
    fi
    
    # Now do fresh initialization
    check_env_file
    
    print_info "Building and starting containers..."
    docker compose up -d --build
    
    print_success "Environment initialized!"
    echo ""
    
    if [ "$FIRST_TIME_SETUP" = true ]; then
        # Offer to create aliases
        read -p "Would you like to create shell aliases for easier container access? [Y/n]: " setup_aliases
        setup_aliases=${setup_aliases:-Y}
        
        if [[ $setup_aliases =~ ^[Yy]$ ]]; then
            create_aliases
        fi
        
        echo ""
        echo "You can now add sites using: ./setup.sh"
    else
        print_success "Environment is ready for new sites"
    fi
}

# Main menu
show_menu() {
    print_header
    echo "What would you like to do?"
    echo ""
    echo "  1) Add new site"
    echo "  2) List sites"
    echo "  3) Remove site"
    echo "  4) Fix site permissions"
    echo "  5) Initialize/Restart environment"
    echo "  6) Create shell aliases"
    echo "  7) Exit"
    echo ""
    
    read -p "Select option [1-7]: " choice
    
    case $choice in
        1)
            add_site
            ;;
        2)
            list_sites
            echo ""
            read -p "Press Enter to continue..."
            show_menu
            ;;
        3)
            remove_site
            echo ""
            read -p "Press Enter to continue..."
            show_menu
            ;;
        4)
            fix_permissions
            echo ""
            read -p "Press Enter to continue..."
            show_menu
            ;;
        5)
            init_environment
            echo ""
            read -p "Press Enter to continue..."
            show_menu
            ;;
        6)
            create_aliases
            echo ""
            read -p "Press Enter to continue..."
            show_menu
            ;;
        7)
            print_info "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option"
            show_menu
            ;;
    esac
}

# Entry point
check_docker

if [ ! -f .env ]; then
    print_warning "First time setup detected"
    init_environment
    echo ""
    read -p "Press Enter to continue to main menu..."
fi

show_menu
