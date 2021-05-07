sudo apt install kibana
sudo bash -c "echo 'sudo systemctl start kibana' >> /usr/local/bin/StartKibana.sh"
sudo bash -c "echo 'sudo systemctl stop kibana' >> /usr/local/bin/StopKibana.sh"
sudo chmod a+x /usr/local/bin/*Kibana.sh
