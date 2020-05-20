#!/bin/bash
# echo "####################################"
# echo "## Installing ElasticSearch 7.7.0 ##"
# echo "####################################"
# done according to https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html#deb-repo

sudo apt-get install apt-transport-https
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo bash -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
sudo apt-get update
sudo apt-get install elasticsearch
# sudo vi /etc/elasticsearch/elasticsearch.yml

# configuring elasticsearch only for localhost.
# https://www.elastic.co/guide/en/elasticsearch/reference/7.7/breaking-changes-7.7.html#breaking_77_discovery_changes
# network.host: localhost
# cluster.name: myShopCluster1
# node.name: "myShopNode1"

# https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html

sudo /bin/systemctl enable elasticsearch.service
echo "## starting elasticsearch - that can take a while ##"
sudo systemctl start elasticsearch.service
# sudo systemctl stop elasticsearch.service
echo "## testing connection ##"
curl -X GET http://localhost:9200
