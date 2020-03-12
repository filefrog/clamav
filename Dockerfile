FROM alpine

ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="James Hunt <images@huntprod.com>" \
      summary="Run ClamAV in a container" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/filefrog/clamav.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0"

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
