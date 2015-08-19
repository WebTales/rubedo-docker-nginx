FROM centos:latest

# Add the ngix dependent repository
ADD nginx.repo /etc/yum.repos.d/nginx.repo

# Installing nginx, php and dependencies
RUN yum -y install epel-release nginx wget git
RUN yum install -y make openssl-devel epel-release php-fpm php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap curl curl-devel gcc php-devel php-intl tar; yum -y clean all

# Installing supervisor
RUN yum install -y python-setuptools \
	easy_install pip \
	pip install supervisor


# Upgrade default limits for PHP
RUN sed -i 's#memory_limit = 128M#memory_limit = 512M#g' /etc/php.ini && \
    sed -i 's#max_execution_time = 30#max_execution_time = 240#g' /etc/php.ini && \
    sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 20M#g' /etc/php.ini && \
    sed -i 's#;date.timezone =#date.timezone = "Europe/Paris"\n#g' /etc/php.ini

# Install PHP Mongo extension
RUN pecl channel-update pecl.php.net
RUN pecl install mongo
ADD mongo.ini /etc/php.d/mongo.ini
RUN echo 'extension=mongo.so' >> /etc/php.ini

# Adding the configuration file for Nginx and Supervisor
ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/default.conf
ADD supervisord.conf /etc/

# Set the port to 80 
EXPOSE 80
ENV URL **None**
ENV VERSION **None**
ENV GITHUB_APIKEY **None**
ENV EXTENSIONS_REQUIRES **None**
ENV EXTENSIONS_REPOSITORIES **None**

# Start script
COPY generate-composer-extension.py /generate-composer-extension.py
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /*.sh

# Executing supervisord
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-n"]
