FROM ubuntu:14.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y --force-yes install mariadb-server
RUN mkdir -p /var/run/mysqld
RUN /usr/bin/mysql_install_db --datadir="/var/lib/mysql" --user=mysql
RUN /usr/bin/mysqld_safe --datadir="/var/lib/mysql" --socket="/var/lib/mysql/mysql.sock" --user=mysql
RUN /usr/bin/mysqladmin -u root password contrail123
CMD ["/usr/bin/mysqld_safe"]
