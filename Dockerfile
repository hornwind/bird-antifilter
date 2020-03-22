FROM alpine:3
LABEL name=bird-antifilter \
      version="2.0"

ENV TZ=Europe/Moscow

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

ENV ROUTER_ID=10.100.0.1 \
    NEIGHBOR_IP=10.100.0.2 \
    NEIGHBOR_AS=64998 \
    LOCAL_AS=64999 \
    SOURCE_ADDRESS=10.100.0.1 \
    SCAN_TIME=60 \
    CRON_MIN=30

EXPOSE 179 179

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]