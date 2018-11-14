FROM alpine

# Every night at 05:00
ENV BACKUP_CRON "0 5 * * *"
ENV BACKUP_NAME "backup"
ENV BACKUP_COUNT 10
ENV SAMBA_USER ""
ENV SAMBA_PASS ""
ENV SAMBA_TARGET "//0.0.0.0"
ENV TZ=UTC

ADD ./start.sh /tmp/start.sh
ADD ./backup.sh /tmp/backup.sh

RUN mkdir /source
RUN mkdir /target

RUN apk update
RUN apk upgrade
RUN apk add zip

RUN apk add --update tzdata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Clean APK cache
RUN rm -rf /var/cache/apk/*

ENTRYPOINT ["/tmp/start.sh"]
