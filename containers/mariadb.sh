docker run --net host -v /dockervolumes/mariadb1/var/lib/mysql:/var/lib/mysql --name mariadb1 -e MYSQL_ROOT_PASSWORD=contrail123 -e MAX_CONNECTIONS=1000 -d mariadb
