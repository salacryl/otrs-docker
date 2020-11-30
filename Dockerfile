FROM ubuntu:20.04
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && apt install cron apache2 libapache2-mod-perl2 libdatetime-perl libcrypt-eksblowfish-perl libcrypt-ssleay-perl libgd-graph-perl libapache-dbi-perl libsoap-lite-perl libarc$
RUN a2enmod perl &&  useradd -d /opt/otrs -c 'OTRS user' otrs && usermod -aG www-data otrs
RUN wget http://ftp.otrs.org/pub/otrs/otrs-latest.tar.gz && tar xvf otrs-latest.tar.gz && mv otrs-*/ /opt/otrs
RUN wget https://raw.githubusercontent.com/salacryl/otrs-docker/main/Config.pm && cp Config.pm /opt/otrs/Kernel/Config.pm
RUN /opt/otrs/bin/otrs.SetPermissions.pl --web-group=www-data
RUN ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/otrs.conf
RUN perl -cw /opt/otrs/bin/cgi-bin/index.pl && perl -cw /opt/otrs/bin/cgi-bin/customer.pl && perl -cw /opt/otrs/bin/otrs.Console.pl
RUN su - otrs -c "/opt/otrs/bin/otrs.Daemon.pl start" && su - otrs -c "/opt/otrs/bin/Cron.sh start"
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && ln -sf /proc/self/fd/1 /var/log/apache2/error.log
RUN echo "0 22 * * * otrs /opt/otrs/scripts/backup.pl -d /backup/ > /dev/null 2>&1" /etc/crontab
EXPOSE 80
CMD apachectl -D FOREGROUND
