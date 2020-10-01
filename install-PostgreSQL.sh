sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y -qq install postgresql


sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'
sudo apt-get -y -qq install pgadmin4-desktop

sudo su - postgres -c "psql -c \"alter user postgres with password 'geheim'\""
sudo su - postgres -c "psql -c \"CREATE DATABASE onlineshop\""
sudo su - postgres -c "psql -c \"CREATE USER onlineshop WITH ENCRYPTED PASSWORD 'geheim'\""
sudo su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE onlineshop to onlineshop\""

# systemctl status postgresql.service
# systemctl status postgresql@12-main.service
# systemctl is-enabled postgresql
