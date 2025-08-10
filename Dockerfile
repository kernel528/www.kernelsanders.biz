FROM kernel528/httpd:2.4.64-3.22.1
LABEL authors="kernel528"

COPY httpd-foreground /usr/local/bin/
COPY htdocs/* /usr/local/apache2/htdocs/

EXPOSE 80
CMD ["httpd-foreground"]