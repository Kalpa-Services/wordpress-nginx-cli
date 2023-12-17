WordPress and Nginx Setup Script
================================

This script automates the process of installing WordPress and setting up an Nginx server block on an Ubuntu server. It checks for the presence of Nginx and installs it if necessary. The script then configures a new Nginx server block for your domain and installs WordPress.

Prerequisites
-------------

-   An Ubuntu server (18.04 or later recommended).
-   Root privileges on the server.
-   Basic knowledge of terminal and command-line operations.

Installation
------------

1.  Log in to Your Server: Ensure you are logged into your Ubuntu server via SSH.

2.  Download the Script: You can download the script using `wget` or `curl`. For example:

    `wget https://github.com/Kalpa-Services/wordpress-nginx-cli.git`

3.  Make the Script Executable: Change the script's permissions to make it executable:


    `chmod +x wp-nginx-setup.sh`

4.  Run the Script: Execute the script with root privileges. You will need to provide details like your domain, database user, password, etc.:

    bashCopy code

    `sudo ./wp-nginx-setup.sh -d yourdomain.com -u dbuser -p dbpass -n dbname -H dbhost`

Usage
-----

The script accepts the following arguments:

-   `-d DOMAIN`: The domain name for the WordPress site.
-   `-u DBUSER`: The database username.
-   `-p DBPASS`: The database password.
-   `-n DBNAME`: The database name.
-   `-H DBHOST`: The database host (usually `localhost`).

Example usage:

`sudo ./wp-nginx-setup.sh -d example.com -u wordpressuser -p password -n wordpressdb -H localhost`

Features
--------

-   Checks for the presence of Nginx and installs it if not found.
-   Sets up an Nginx server block for the specified domain.
-   Installs the latest version of WordPress.
-   Configures WordPress with the provided database details.

Important Notes
---------------

-   Ensure that you have all the required database details before running the script.
-   The script must be run as `root` or with `sudo` to perform necessary system modifications.
-   It's recommended to use this script on a fresh Ubuntu installation to prevent any conflicts with existing configurations.

Troubleshooting
---------------

If you encounter any issues:

-   Check the syntax of the command and ensure all required arguments are provided.
-   Verify that your user has root privileges.
-   Ensure your server's package manager is functioning properly.

For more help, you can check the script's output for error messages.