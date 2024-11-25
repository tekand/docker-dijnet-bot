ARG BASE=alpine:latest
FROM ${BASE}

ENV APP_VERSION=2.1.9
ENV APP_NAME=dijnet-bot

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

RUN curl -SL -o /usr/local/bin/dijnet-bot.js https://github.com/juzraai/dijnet-bot/releases/download/v${APP_VERSION}/dijnet-bot.cjs

RUN mkdir ${OUTPUT_DIR}
RUN mkdir ${CONFIG_DIR} && chown 755 ${CONFIG_DIR}
RUN mkdir ${RUN_DIR} && chown 755 ${RUN_DIR}

COPY root/usr/local/bin /usr/local/bin
COPY root/entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD [""]
