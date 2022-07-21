#!/bin/bash
apt-get update -y
apt-get install -y htop mariadb-server

ROOT_PASSWORD="Mysql123"

mysqladmin --user=root password $ROOT_PASSWORD
echo "status of Root password changed, status code=e " $?
systemctl start mariadb
systemctl enable mariadb

mysql -uroot -p$ROOT_PASSWORD<<EOF
-- delete remote root capabilities
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
-- delete anonymous users
DELETE FROM mysql.user WHERE User='';
-- make changes immediately
FLUSH PRIVILEGES;
-- drop database 'test'
DROP DATABASE IF EXISTS test;
-- also make sure there are lingering permissions to it
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
-- make changes immediately
FLUSH PRIVILEGES;
EOF