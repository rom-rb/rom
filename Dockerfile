FROM ruby:3.0-alpine

RUN apk update && apk add bash git gnupg build-base sqlite-dev postgresql-dev

WORKDIR /usr/local/src/rom
