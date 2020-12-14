FROM debian

MAINTAINER Szymon Sadło "szymon.sadlo@qpony.pl"

RUN apt update
RUN apt install -y git nginx iptables net-tools wget unzip

RUN apt install -y apt-transport-https lsb-release ca-certificates curl
RUN curl -sSL -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
RUN apt update

RUN apt install -y php7.4 php7.4-fpm php7.4-xml php7.4-intl

COPY composer-install.sh /tmp/composer-install.sh
RUN chmod +x /tmp/composer-install.sh
RUN chmod u+s /usr/sbin/xtables-nft-multi
RUN cd /tmp && sh -c /tmp/composer-install.sh
RUN rm -f /tmp/composer-install.sh
RUN mv /tmp/composer.phar /usr/local/bin/composer

RUN mkdir -p /var/www/code
RUN chown -R www-data /var/www/code
USER www-data
RUN cd ~/code && git clone https://github.com/beriba/test-php-task.git . && composer install
USER root

COPY nginx.conf /etc/nginx/conf.d/basic.conf
RUN rm -f /etc/nginx/sites-enabled/*
RUN rm -f /etc/nginx/sites-available/*

CMD service nginx start && service php7.4-fpm start && tail -f /var/log/nginx/error.log
ENTRYPOINT service nginx start && service php7.4-fpm start && bash
