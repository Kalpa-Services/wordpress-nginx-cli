#!/bin/bash

# Default Configurations
NGINX_AVAILABLE='/etc/nginx/sites-available'
NGINX_ENABLED='/etc/nginx/sites-enabled'
WEB_DIR='/var/www'
WEB_USER='www-data:www-data'

# Function to display help
show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-d DOMAIN] [-u DBUSER] [-p DBPASS] [-n DBNAME] [-H DBHOST]

This script installs WordPress and sets up an Nginx server block.

    -h          display this help and exit
    -d DOMAIN   specify the domain name
    -u DBUSER   database user
    -p DBPASS   database password
    -n DBNAME   database name
    -H DBHOST   database host
EOF
}

# Function to check and install Nginx
check_and_install_nginx() {
    if ! command -v nginx >/dev/null 2>&1; then
        echo "Nginx is not installed. Installing Nginx..."
        # Depending on your distribution, choose the correct package manager (apt, yum, etc.)
        apt update
        apt install nginx -y
    else
        echo "Nginx is already installed."
    fi
}

# Parse command-line options
while getopts "hd:u:p:n:H:" opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        d)  domain=$OPTARG
            ;;
        u)  dbuser=$OPTARG
            ;;
        p)  dbpass=$OPTARG
            ;;
        n)  dbname=$OPTARG
            ;;
        H)  dbhost=$OPTARG
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done

# Check if script is run as root
[ "$(id -u)" != "0" ] && { echo "This script must be run as root."; exit 1; }

# Check and install Nginx
check_and_install_nginx

# Main script execution
create_nginx_config
install_wordpress
chown -R $WEB_USER $WEB_DIR/$domain
chmod -R 775 $WEB_DIR/$domain
ln -s $NGINX_AVAILABLE/$domain $NGINX_ENABLED/$domain
systemctl restart nginx

echo "WordPress installation and Nginx setup for $domain complete."
