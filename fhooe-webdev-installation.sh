# Installation has been done on Ubuntu 20.04 LTS (Focal Fossa) Desktop
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

echo "## Installing zip, unzip, curl, net-tools ##"

sudo apt-get -y install zip unzip curl net-tools
echo "## Installing chrome -- only chromium can be installed with apt-get ##"

cd /home/ubuntu/Downloads
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

echo "###############################################"
echo "## Activating SSL and mod_rewrite for Apache ##"
echo "###############################################"

sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2ensite default-ssl

echo "################################"
echo "# Activating XDEBUG for Apache #"
echo "################################"

INI=/etc/php/7.4/mods-available/xdebug.ini

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
      
echo "############################################"
echo "## Installing MariaDB 10.4 and PHPMyAdmin ##"
echo "############################################"
	  
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.klaus-uwe.me/mariadb/repo/10.4/ubuntu bionic main'
sudo apt-get -y update
sudo apt-get -y -qq install mariadb-server mariadb-client
sudo mysql -uroot -pgeheim -e "CREATE USER 'onlineshop'@'localhost' IDENTIFIED BY 'geheim'"
sudo mysql -uroot -pgeheim -e "GRANT ALL PRIVILEGES ON *.* TO 'onlineshop'@'localhost'"
sudo apt-get -y -qq install phpmyadmin

echo "################################################"
echo "## Linking PHPMyAdmin to Apache Document Root ##"
echo "################################################"
sudo ln -s /usr/share/phpmyadmin/ /var/www/html/phpmyadmin

sudo service apache2 restart  && echo "Apache started with return code $?"
sudo service mysql restart  && echo "MariaDB started with return $?"

echo "## Installing PHPCodeSniffer ##"

cd $HOME/Downloads
sudo curl -s -Ol https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar
sudo curl -s -Ol https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar
sudo mv phpcs.phar /usr/local/bin/phpcs
sudo mv phpcbf.phar /usr/local/bin/phpcbf
cd /usr/local/bin
sudo chown root:root phpcs phpcbf
sudo chmod 755 phpcs phpcbf

echo "## Installing composer ##"

cd /home/ubuntu
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

sudo mv composer.phar /usr/local/bin/composer
sudo chown root:root /usr/local/bin/composer

echo "## PHPStorm Toolbox installieren. ##"
# Download from https://www.jetbrains.com/toolbox/app/ manually or do the following

cd $HOME/Downloads
wget -cO jetbrains-toolbox.tar.gz "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA"
tar -xzf jetbrains-toolbox.tar.gz
DIR=$(find . -maxdepth 1 -type d -name jetbrains-toolbox-\* -print | head -n1)
cd $DIR
sudo cp jetbrains-toolbox /usr/local/bin

echo "## installing onlineshop und phpintro ##"

cd /var/www/html
sudo mkdir code
sudo chown www-data:www-data code
sudo chmod 777 code
cd code
git clone https://github.com/Digital-Media/onlineshop.git onlineshop
cd onlineshop
composer install
cd ..
git clone https://github.com/Digital-Media/phpintro.git phpintro
cd phpintro
composer install
cd ..
sudo chmod -R 777 code
cd code/onlineshop/src
sudo mysql -uonlineshop -pgeheim < onlineshop.sql

echo "## permanently set Screen Resolution to 1920x1080 60 to optimize YouTube streaming ##"
# Get parameters for xrandr
# cvt 1920 1080 60
# Get name of connected Screen.
# xrandr

XRANDR=/etc/X11/Xsession.d/45custom_xrandr-settings
sudo bash -c "echo 'xrandr --newmode 1920x1080_60.00  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync' >> $XRANDR"
sudo bash -c "echo 'xrandr --addmode Virtual1 1920x1080_60.00' >> $XRANDR"
sudo bash -c "echo 'xrandr --output Virtual1 --mode 1920x1080_60.00' >> $XRANDR"
sudo chmod +x /etc/X11/Xsession.d/45custom_xrandr-settings

echo "## reboot your system and finish installation with the steps below ##"
echo "## Start jetbrains-toolbox from commandline or per click from Anwendungen and install PHPStorm ##"
echo "## Add Terminal, Texteditor, Jetbrains-Toolbox, PHPStorm and Chrome to favorites ##"
echo "## bookmark phpintro, onlineshop, phpmyadmin, elearning, github, jetbrains bookmarklets Chrome ##"
