FROM ubuntu:20.04
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && apt install apache2 apache2 libapache2-mod-perl2 libdatetime-perl libcrypt-eksblowfish-perl libcrypt-ssleay-perl libgd-graph-perl libapache-dbi-perl libsoap-lite-perl libarchive-zip-perl libgd-text-perl libnet-dns-perl libpdf-api2-perl libauthen-ntlm-perl libdbd-odbc-perl libjson-xs-perl libyaml-libyaml-perl libxml-libxml-perl libencode-hanextra-perl libxml-libxslt-perl libpdf-api2-simple-perl libmail-imapclient-perl libtemplate-perl libtext-csv-xs-perl libdbd-pg-perl libapache2-mod-perl2 libtemplate-perl libnet-dns-perl libnet-ldap-perl libio-socket-ssl-perl libmoo-perl wget -y
RUN a2enmod perl &&  useradd -d /opt/otrs -c 'OTRS user' otrs && usermod -aG www-data otrs
RUN wget http://ftp.otrs.org/pub/otrs/otrs-latest.tar.gz && tar xvf otrs-latest.tar.gz && mv otrs-*/ /opt/otrs
RUN wget https://raw.githubusercontent.com/salacryl/otrs-docker/main/Config.pm && cp Config.pm /opt/otrs/Kernel/Config.pm
RUN /opt/otrs/bin/otrs.SetPermissions.pl --web-group=www-data
RUN ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/otrs.conf
RUN perl -cw /opt/otrs/bin/cgi-bin/index.pl && perl -cw /opt/otrs/bin/cgi-bin/customer.pl && perl -cw /opt/otrs/bin/otrs.Console.pl
RUN su - otrs -c "/opt/otrs/bin/otrs.Daemon.pl start" && su - otrs -c "/opt/otrs/bin/Cron.sh start"

EXPOSE 80
CMD apachectl -D FOREGROUND
