docker run -e MYSQL_ROOT_PASSWORD=123 -e MYSQL_DATABASE=wordpress --name wordpressdb -v "$PWD/database":/var/lib/mysql -d mariadb:latest
docker run -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=123 --name wordpress --link wordpressdb:mysql -p 80:80 -v "$PWD/html":/var/www/html -d wordpress
