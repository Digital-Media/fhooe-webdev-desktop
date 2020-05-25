#!/bin/bash
# install Redis Server
cd $HOME/Downloads
wget http://download.redis.io/releases/redis-6.0.3.tar.gz
tar xzf redis-6.0.3.tar.gz
cd redis-6.0.3
make
