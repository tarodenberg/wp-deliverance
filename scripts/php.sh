# PHP 5.3 Ubuntu Server 12.04 Install Script
# A part of the wp-deliverance super fast WordPress project
# Copyright (c) 2012 Tom Rodenberg <tarodenberg gmail com>
# Licensed under the GPL (http://www.gnu.org/licenses/gpl.html) license.

# Define php config files
	PHP_CONF="/etc/php5/fpm/php.ini"
	PHP_FPM_CONF="/etc/php5/fpm/pool.d/www.conf"
	PHP_APC_CONF="/etc/php5/conf.d/apc.ini"

	mkdir -p /srv/www/
	mkdir -p /var/www/
	
# Install FPM, Suhosin, Curl, MySQL, APC, Memcache, Gd
	apt-get -y install php5-fpm php5-suhosin php5-curl php5-mysql php-apc php5-memcache php5-gd 
	
#### PHP Settings ####
	
# enable php short tags <? ?>
	sed -i "s/short_open_tag = Off/short_open_tag = On/" "$PHP_CONF"

# set time zone
	sed -i "s/;date.timezone =/date.timezone = \"America\/Denver\"/" "$PHP_CONF"

# set mysqli default socket
	sed -i "s/mysqli.default_socket =/mysqli.default_socket = \/var\/run\/mysqld\/mysqld.sock/" "$PHP_CONF"
	
# increase php memory limit
	#sed -i "s/memory_limit = 128M/memory_limit = 128M/" "$PHP_CONF"
	
# set error reporting
	#sed -i "s/ignore_repeated_errors = Off/ignore_repeated_errors = On/" "$PHP_CONF"
	
#### FPM Settings ####
	
# Modify FPM to use sockets instead of ports to reduce TCP/IP overhead
	sed -i 's/;listen = \/var\/run\/php5-fpm.sock/listen = \/var\/run\/php5-fpm.sock/' "$PHP_FPM_CONF"
	sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php5-fpm.sock/' "$PHP_FPM_CONF"

# strict exec permissions
	sed -i "s/;listen.owner = www-data/listen.owner = www-data/" "$PHP_FPM_CONF"
	sed -i "s/;listen.group = www-data/listen.group = www-data/" "$PHP_FPM_CONF"
	sed -i 's/;listen.mode = 0666/listen.mode = 0600/' "$PHP_FPM_CONF"

	
#### APC Settings ####

# http://www.php.net/manual/en/apc.configuration.php
	sed -i "/apc.enabled=1/d" "$PHP_APC_CONF"
	echo "apc.enabled=1" >> "$PHP_APC_CONF"
	
	sed -i "/apc.shm_size=50/d" "$PHP_APC_CONF"
	echo "apc.shm_size=50M" >> "$PHP_APC_CONF"
	
	sed -i "/apc.rfc1867=1/d" "$PHP_APC_CONF"
	# RFC1867 File Upload Progress hook handler
	echo "apc.rfc1867=1" >> "$PHP_APC_CONF"
	
# these settings are fairly conservative and can probably be increased without things melting
	#sed -i 's/pm.max_children = 50/pm.max_children = 50/' "$PHP_FPM_CONF"
	sed -i 's/;pm.start_servers = 20/pm.start_servers = 20/' "$PHP_FPM_CONF"
	#sed -i 's/pm.min_spare_servers = 5/pm.min_spare_servers = 5/' "$PHP_FPM_CONF"
	#sed -i 's/pm.max_spare_servers = 35/pm.max_spare_servers = 35/' "$PHP_FPM_CONF"
	sed -i 's/;pm.max_requests = 500/pm.max_requests = 500/' "$PHP_FPM_CONF"
	sed -i 's/;pm.status_path = \/status/pm.status_path = \/status\/fpm.php/' "$PHP_FPM_CONF"

# engage
	service php5-fpm start
	
	echo "Done installing PHP"
