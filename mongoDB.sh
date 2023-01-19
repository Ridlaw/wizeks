#! /bin/bash
##########################################################################################
#MongoDB installation
##########################################################################################
# update your base system with the latest available packages
sudo apt-get update -y

wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

sudo apt-get update -y

# sudo apt-get install -y mongodb-org=5.0.13 mongodb-org-database=5.0.13 mongodb-org-server=5.0.13 mongodb-org-shell=5.0.13 mongodb-org-mongos=5.0.13 mongodb-org-tools=5.0.13

sudo apt-get install -y mongodb-org

sudo systemctl start mongod

sudo apt-get install awscli -y

