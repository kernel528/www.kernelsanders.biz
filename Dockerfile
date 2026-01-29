FROM kernel528/httpd:2.4.66-3.23.3
LABEL authors="kernel528"

COPY VERSION.md /tmp/VERSION.md
COPY scripts/inject-version.sh /usr/local/bin/inject-version.sh
COPY httpd-foreground /usr/local/bin/
COPY htdocs/ /usr/local/apache2/htdocs/

RUN chmod +x /usr/local/bin/inject-version.sh
RUN /usr/local/bin/inject-version.sh /tmp/VERSION.md /usr/local/apache2/htdocs/index.html

EXPOSE 80
CMD ["httpd-foreground"]
