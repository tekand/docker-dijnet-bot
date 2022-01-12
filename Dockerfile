ARG BASE=alpine:latest
FROM ${BASE}

ENV APP_VERSION=2.1.7
ENV APP_NAME=dijnet-bot

ENV USER=dijnet
ENV GROUP=dijnet

ENV CONFIG_DIR=/config
ENV RUN_DIR=/var/run/dijnet-bot

ENV CONFIG_FILE=${CONFIG_DIR}/${APP_NAME}.conf
ENV PID_FILE=${RUN_DIR}/${APP_NAME}.pid

ENV HEALTHCHECKS_IO_URL=

ENV OUTPUT_DIR=/data

RUN apk --no-cache add \
  bash \
  ca-certificates \
  curl \
  nodejs \
  npm \
  shadow \
  tzdata

RUN curl -SL https://github.com/juzraai/dijnet-bot/archive/v${APP_VERSION}.tar.gz \
  | tar -xzvC /usr/lib \
  && npm i -g /usr/lib/dijnet-bot-${APP_VERSION}

RUN groupadd ${GROUP} && \
  useradd -s /bin/false ${USER} -g ${GROUP}

RUN mkdir ${OUTPUT_DIR}
RUN mkdir ${CONFIG_DIR} && chown 755 ${CONFIG_DIR}
RUN mkdir ${LOG_DIR} && chown 755 ${LOG_DIR}
RUN mkdir ${RUN_DIR} && chown 755 ${RUN_DIR}

COPY root/ /

ENTRYPOINT ["/entrypoint.sh"]

CMD [""]
