FROM alpine:3
LABEL name=bird-autoconfig \
      version="2.0"

ENV TZ=Europe/Moscow

ENV router_id=10.100.0.1 \
    neighbor_ip=10.100.0.2 \
    neighbor_as=64998 \
    local_as=64999 \
    source_address=10.100.0.1 \
    scan_time=60

ENV cron_min=30

RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --no-cache \
       tzdata \
       wget \
       supervisor \
       inetutils-syslogd \
       bird@testing \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && mkdir -p /blacklist/list \
    && mkdir -p /run/bird \
    && mkdir -p /etc/bird \
    && mkdir -p /var/log/supervisor \
    && echo "Success"

COPY syslog.conf /etc/syslog.conf
COPY supervisord.conf /etc/supervisor/
COPY chklist /blacklist/
COPY entrypoint.sh /

EXPOSE 179 179

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]