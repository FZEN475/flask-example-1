FROM alpine:latest as ansible

RUN apk add --update --no-cache python3 py3-pip py3-flask

COPY ./src /src
ADD ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]