#!/bin/bash
# install Redis Server
cd $HOME/Downloads
wget http://download.redis.io/redis-stable.tar.gz
tar xzf redis-stable.tar.gz
sudo apt-get install tcl
cd redis-stable
make
make test
sudo bash -c "echo 'cd $HOME/Downloads/redis-stable' > /usr/local/bin/StartRedis.sh"
sudo bash -c "echo 'nohup ./src/redis-server ./redis.conf &>redis.out &' >> /usr/local/bin/StartRedis.sh"
sudo bash -c "echo 'cd $HOME/Downloads/redis-stable'  > /usr/local/bin/StopRedis.sh"
var='pid=`ps -ef|grep redis|head -1|awk '
var+="'"
var+='{print $2}'
var+="'"
var+='`'
sudo chmod o+w /usr/local/bin/StopRedis.sh
echo $var >> /usr/local/bin/StopRedis.sh
sudo chmod o-w /usr/local/bin/StopRedis.sh
sudo bash -c "echo 'kill -15 \$pid' >> /usr/local/bin/StopRedis.sh"
sudo bash -c "echo 'cd $HOME/Downloads/redis-stable'  >> /usr/local/bin/StopRedis.sh"
sudo bash -c "echo 'rm redis.out dump.rdb' >> /usr/local/bin/StopRedis.sh"
sudo chmod a+x /usr/local/bin/*Redis.sh
cd $HOME/Downloads
rm redis-stable.tar.gz
cd redis-stable
sed -i 's/# bind 127.0.0.1 ::1/bind 127.0.0.1 ::1/g' redis.conf
