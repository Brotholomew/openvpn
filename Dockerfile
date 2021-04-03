FROM alpine

RUN apk update; apk upgrade; apk add nginx; apk add openvpn; apk add easy-rsa; apk add bash; apk add inotify-tools
RUN mkdir -p /var/scripts/init; mkdir -p /run/nginx; mkdir -p /home/api; mkdir -p /home/front; mkdir -p /home/db;

COPY scripts/init.sh /var/scripts
COPY scripts/logger.sh /var/scripts
COPY scripts/terminator.sh /var/scripts
COPY scripts/init /var/scripts/init
COPY config/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY config/front/* /home/front/
COPY config/api/* /home/api/

CMD ["/bin/bash", "/var/scripts/init.sh"]
