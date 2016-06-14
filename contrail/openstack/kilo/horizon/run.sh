sed -i 's/VirtualHost \*:80/VirtualHost *:88/g' /etc/apache2/sites-enabled/000-default.conf
sed -i 's/Listen 80/Listen 88/g' /etc/apache2/ports.conf
source /etc/apache2/envvars
tail -F /var/log/apache2/* &
exec apache2 -D FOREGROUND
