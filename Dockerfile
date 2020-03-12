FROM alpine

EXPOSE 3310
VOLUME ['/var/lib/clamav']

RUN apk update \
 && apk add clamav-daemon clamav-libunrar \
            curl ca-certificates \
 && rm -rf /var/cache/apk/*

RUN mkdir /var/run/clamav \
 && chown clamav:clamav /var/run/clamav \
 && chmod 750 /var/run/clamav \
 && mkdir -p /var/lib/clamav.master \
 && curl -Lo /var/lib/clamav.master/main.cvd     https://database.clamav.net/main.cvd \
 && curl -Lo /var/lib/clamav.master/daily.cvd    https://database.clamav.net/daily.cvd \
 && curl -Lo /var/lib/clamav.master/bytecode.cvd https://database.clamav.net/bytecode.cvd

COPY . /
ENTRYPOINT ["/clamav"]
