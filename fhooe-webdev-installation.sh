# Installation has been done on Ubuntu 18.04 LTS (bionic) Desktop
# sudo apt-get install software-properties-common
# sudo bash funktioniert. Ganzes Script als root laufen lassen?
# sudo bash 
# Repos for
# PHP 7.4
sudo add-apt-repository -y ppa:ondrej/php
# Apache2
sudo add-apt-repository -y ppa:ondrej/apache2
# Redis Server
sudo add-apt-repository -y ppa:chris-lea/redis-server
sudo apt-get -y update

echo "#############################################"
echo "## Installing Apache2, PHP7.4 + Extensions ##"
echo "#############################################"

sudo apt-get -y install apache2 php7.4 libapache2-mod-php7.4
sudo apt-get -y install php7.4-zip php7.4-mysql php7.4-curl php7.4-dev php7.4-gd php7.4-intl php-pear php-imagick php7.4-imap php7.4-tidy php7.4-xmlrpc php7.4-xsl php7.4-mbstring php7.4-xml php-gettext php-xdebug
sudo apt-get -y install zip unzip

echo "###############################################"
echo "## Activating SSL and mod_rewrite for Apache ##"
echo "###############################################"

sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2ensite default-ssl

echo "################################"
echo "# Activating XDEBUG for Apache #"
echo "################################"

#cd /etc/php/7.4/mods-available/xdebug.ini
INI=/etc/php/7.4/mods-available/xdebug.ini

# echo >> funktioniert nicht?! wegen permission denied. sudo vi ctrl-shift-v schon???
# sudo sed -i auch nicht???
#sudo echo 'xdebug.remote_enable=1' >> xdebug.ini
#sudo echo 'xdebug.remote_connect_back=1' >> xdebug.ini
#sudo echo 'xdebug.remote_port=9000' >> xdebug.ini

sudo bash -c "echo 'xdebug.remote_enable=1' >> $INI"
sudo bash -c "echo 'xdebug.remote_connect_back=1' >> $INI"
sudo bash -c "echo 'xdebug.remote_port=9000' >> $INI"


echo "########################################"
echo "## Adding permanent redirect to HTTPs ##"
echo "########################################"
cd /etc/apache2/sites-available
sudo sed -i '29i #' 000-default.conf
sudo sed -i '30i # Redirct permanently to https ' 000-default.conf
sudo sed -i '31i # added by Martin Harrer for demonstration purposes in web lessons' 000-default.conf

# welche IP verwenden, falls wir von außen zugreifen? Im Image passt localhost
# bekommt jeder clone seine eigene IP-Adresse?
# Ist die statisch oder kommt die von DHCP?
sudo sed -i '32i Redirect permanent / https://localhost/' 000-default.conf

echo "#############################################################"
echo "## Switching to AllowOverride All for /var/www/html/code/* ##"
echo "#############################################################"
cd /etc/apache2/sites-available
sudo sed -i '131i <Directory /var/www/html/code/*>' default-ssl.conf
sudo sed -i '132i        Options Indexes FollowSymLinks MultiViews' default-ssl.conf
sudo sed -i '133i        AllowOverride All' default-ssl.conf
sudo sed -i '134i </Directory>' default-ssl.conf

echo "######################################################"
echo "## Setting debconf-settings for noninteractive mode ##"
echo "######################################################"
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< 'mariadb-server-10.4 mysql-server/root_password password geheim'
sudo debconf-set-selections <<< 'mariadb-server-10.4 mysql-server/root_password_again password geheim'
      
echo "#######################################"
echo "## Installing MariaDB and PHPMyAdmin ##"
echo "#######################################"
	  
# MariaDB 10.4
# apt-get install software-properties-common
# sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.klaus-uwe.me/mariadb/repo/10.4/ubuntu bionic main'
sudo apt-get -y update
sudo apt-get -y -qq install mariadb-server mariadb-client
sudo mysql -uroot -pgeheim -e "CREATE USER 'onlineshop'@'localhost' IDENTIFIED BY 'geheim'"
sudo mysql -uroot -pgeheim -e "GRANT ALL PRIVILEGES ON *.* TO 'onlineshop'@'localhost'"
sudo apt-get -y -qq install phpmyadmin

# user debian-sys-maint existiert nicht mehr unter MariaDB 10.4. sudo mysql ...
# mysql -uroot -pgeheim -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost'"

echo "################################################"
echo "## Linking PHPMyAdmin to Apache Document Root ##"
echo "################################################"
ln -s /usr/share/phpmyadmin/ /var/www/html/phpmyadmin

## Installing PHPCodeSniffer ##

su user
cd /usr/local/bin
sudo apt-get install curl
sudo curl -s -Ol https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar
sudo curl -s -Ol https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar
sudo mv phpcs.phar /usr/local/bin/phpcs
sudo mv phpcbf.phar /usr/local/bin/phpcbf
sudo chown root:root phpcs phpcbf
sudo chmod 755 phpcs phpcbf
exit

## Installing composer ##

# Angemeldet als p20137

cd /home/p20137
EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php
echo $RESULT

su user
sudo mv composer.phar /usr/local/bin/composer
sudo chown root:root /usr/local/bin/composer


echo "#####################################################"
echo "## Installing Redis Server and PHP Redis Extension ##"
echo "#####################################################"

apt-get -y install redis-server php-redis
# an welche IP sollen wir redis binden? Hat jeder Clone seine eigene IP?
#sed -i '70i bind localhost 192.168.7.7' /etc/redis/redis.conf
#sed -i '509i requirepass geheim' /etc/redis/redis.conf


echo "###########################"
echo "## Installing Oracle JRE ##"
echo "###########################"

# Java openJDK 11.0.3 already installed. 7.x is compatible with this version

echo "##################################"
echo "## Installing ElasticSearch 7.3 ##"
echo "##################################"

export $JAVA_HOME=/usr/lib/jvm/default-java
sudo apt-get install apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo add-apt-repository "deb https://artifacts.elastic.co/packages/7.x/apt stable main"
sudo apt-get update
sudo apt-get install elasticsearch
sudo vi /etc/elasticsearch/elasticsearch.yml

# configuring elasticsearch only for localhost.
# https://www.elastic.co/guide/en/elasticsearch/reference/7.0/breaking-changes-7.0.html#breaking_70_discovery_changes
network.host: localhost
cluster.name: myShopCluster1
node.name: "myShopNode1"

https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html

sudo /bin/systemctl enable elasticsearch.service

sudo systemctl start elasticsearch.service
sudo systemctl stop elasticsearch.service

curl -X GET http://localhost:9200

cd /home/user
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# Terminal, Texteditor und Chrome zu den Favoriten hinzufügen.

# onlineshop und phpintro von GitHub clonen.

# siehe doku dort.

# PHPStorm Toolbox installieren. 
# Download from https://www.jetbrains.com/toolbox/app/

su user
cd /home/user/Downloads

tar -xvzf jetbrains-toolbox-1.15.5666.tar.gz
cd jetbrains-toolbox-1.15.5666/
sudo cp jetbrains-toolbox /usr/local/bin
# Starten über Apps oder in der bash
jetbrains-toolbox


service apache2 restart  && echo "Apache started with return code $?"
service mysql restart  && echo "MariaDB started with return $?"
service redis-server restart && echo "Redis started with return $?"

# Ab Snapshot

# Redis als Service einrichten
sudo vi /etc/redis/redis.conf

...
# If you run Redis from upstart or systemd, Redis can interact with your
# supervision tree. Options:
#   supervised no      - no supervision interaction
#   supervised upstart - signal upstart by putting Redis into SIGSTOP mode
#   supervised systemd - signal systemd by writing READY=1 to $NOTIFY_SOCKET
#   supervised auto    - detect upstart or systemd method based on
#                        UPSTART_JOB or NOTIFY_SOCKET environment variables
# Note: these supervision methods only signal "process is ready."
#       They do not enable continuous liveness pings back to your supervisor.
supervised systemd
...
# After a new start with "service redis-server restart" redis was running again
# No idea so far, why it crashed and didn't start again on 1.8.2019
# /etc/rc5.d stores all links to automatically start apache2, elasticsearch and redis.

# install phyton, not necessary, available in every ubuntu distribution

sudo systemctl start redis-server
sudo systemctl enable redis-server


# per-user web directories

# https://httpd.apache.org/docs/2.4/howto/public_html.html

sudo a2enmod userdir
sudo service apache2 restart
# sudo systemctl restart apache2.service



# Steps to install MongoDB 4.2 and Node as User user
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org
systemctl enable mongod


# Clone slimshop from GitHub
curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
sudo apt-get install -y -qq nodejs
