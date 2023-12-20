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

# Check if no arguments were provided
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Function to check and install Nginx
check_and_install_nginx() {
    if ! command -v nginx >/dev/null 2>&1; then
        echo "Nginx is not installed. Installing Nginx..."
        apt update
        apt install nginx -y
    else
        echo "Nginx is already installed."
    fi
}

# Function to check and install Perl
check_and_install_perl() {
    if ! command -v perl >/dev/null 2>&1; then
        echo "Perl is not installed. Installing Perl..."
        apt install perl -y
    else
        echo "Perl is already installed."
    fi
}

# Function to check and install PHP 8.2 and PHP 8.2-FPM
check_and_install_php() {
    if ! command -v php8.2 >/dev/null 2>&1; then
        echo "PHP 8.2 is not installed. Installing PHP 8.2 and PHP 8.2-FPM..."
        apt install php8.2 php8.2-fpm -y
    else
        echo "PHP 8.2 and PHP 8.2-FPM are already installed."
    fi
}

# Function to create nginx config
create_nginx_config() {
    cat > $NGINX_AVAILABLE/$domain <<EOF
server {
    server_tokens off;
    server_name $domain www.$domain;
    root $WEB_DIR/$domain/wordpress;
    index index.php;

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include fastcgi.conf;
        fastcgi_intercept_errors on;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock; # Adjust the PHP version
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)\$ {
        expires max;
        log_not_found off;
    }
}
EOF
}

# Function to install and configure WordPress
install_wordpress() {
    if [ ! -d "$WEB_DIR/$domain" ]; then
        echo "Creating web directory for $domain..."
        mkdir -p $WEB_DIR/$domain
    fi
    cd $WEB_DIR/$domain
    echo "Downloading WordPress..."
    curl -O https://wordpress.org/latest.tar.gz
    tar -zxvf latest.tar.gz
    rm latest.tar.gz
    cd wordpress
    mv wp-config-sample.php wp-config.php

    perl -i -pe "s/database_name_here/$dbname/g" wp-config.php
    perl -i -pe "s/username_here/$dbuser/g" wp-config.php
    perl -i -pe "s/password_here/$dbpass/g" wp-config.php
    perl -i -pe "s/localhost/$dbhost/g" wp-config.php
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

# Check if all required parameters are provided
if [ -z "$domain" ] || [ -z "$dbuser" ] || [ -z "$dbpass" ] || [ -z "$dbname" ] || [ -z "$dbhost" ]; then
    echo -e "\033[31mError: All parameters are required.\033[0m"
    show_help
    exit 1
fi

# Check if script is run as root
[ "$(id -u)" != "0" ] && { echo -e "\033[0mThis script must be run as root.\033[0m"; exit 1; }

# Check and install dependencies
check_and_install_nginx
check_and_install_perl
check_and_install_php

# Execute functions
create_nginx_config
install_wordpress

# Set permissions and create symlink
chown -R $WEB_USER $WEB_DIR/$domain
chmod -R 775 $WEB_DIR/$domain
ln -s $NGINX_AVAILABLE/$domain $NGINX_ENABLED/$domain

# Restart Nginx to apply changes
systemctl restart nginx

echo -e "\033[32mWordPress installation and Nginx setup for $domain complete.\033[0m"
