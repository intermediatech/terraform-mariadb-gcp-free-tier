#!/bin/bash
apt-get update -y
apt-get install -y htop mariadb-server

ROOT_PASSWORD="6i+1bRUste5=*rikedl+"
USER_PASSWORD="huPh#dI6UxayejIgiX1p"

mysqladmin --user=root password $ROOT_PASSWORD
echo "status of Root password changed, status code=e " $?
systemctl start mariadb
systemctl enable mariadb

mysql -uroot -p$ROOT_PASSWORD<<EOF
-- delete remote root capabilities
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Enable Remote root login
-- GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$ROOT_PASSWORD' WITH GRANT OPTION;

-- Create User
CREATE USER 'dbuser'@'%' IDENTIFIED BY '$USER_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'dbuser'@'%' IDENTIFIED BY '$USER_PASSWORD';

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

tee -a /etc/mysql/my.cnf <<EOF
[mysqld]
bind-address = 0.0.0.0
EOF

systemctl restart mariadb