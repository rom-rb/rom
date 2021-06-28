ARG RUBY_VERSION

FROM ruby:$RUBY_VERSION-alpine

RUN apk update && apk add bash git gnupg build-base sqlite-dev postgresql-dev

WORKDIR /usr/local/src/rom
