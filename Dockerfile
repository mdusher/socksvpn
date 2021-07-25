FROM alpine:3.12
    
# S6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

# openvpn and dante
RUN set -x \
 && apk add --no-cache \
        linux-pam iptables openvpn bash \
 && apk add --no-cache -t .build-deps \
        build-base \
        curl \
        linux-pam-dev \
 && cd /tmp \
    # https://www.inet.no/dante/download.html
 && curl -L https://www.inet.no/dante/files/dante-1.4.2.tar.gz | tar xz \
 && cd dante-* \
    # See https://lists.alpinelinux.org/alpine-devel/3932.html
 && ac_cv_func_sched_setscheduler=no ./configure \
 && make install \
 && cd / \
 && adduser -S -D -u 8062 -H sockd \
 && rm -rf /tmp/* \
 && apk del --purge .build-deps

ADD files/ /
EXPOSE 1080

ENTRYPOINT ["/init"]
