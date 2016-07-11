FROM alpine:edge
MAINTAINER Porawit Poboonma <ball6847@gmail.com>

ADD ./ /app

RUN apk add --update --no-cache python-dev py-pip
RUN cd /app/core/webstack && pip install -r requirements.txt
