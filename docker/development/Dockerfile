# base image for ruby
ARG RUBY_VERSION=3.3.0
FROM ruby:3.3.0-alpine3.19 as base

# set environment variable for bundler version
ENV BUNDLER_VERSION=2.5.6

# base necessary packages and dependencies
RUN apk add --update --no-cache \
      bash \
      binutils-gold \
      build-base \
      curl \
      file \
      g++ \
      gcc \
      less \
      libpq-dev \
      postgresql-dev \
      postgresql-client \
      libstdc++ \
      libffi-dev \
      libc-dev \
      linux-headers \
      libxml2-dev \
      libxslt-dev \
      libgcrypt-dev \
      make \
      netcat-openbsd \
      nodejs \
      openssl \
      pkgconfig \
      python3 \
      py-pip \
      tzdata \
      yarn

# Install bundler
RUN gem install bundler:2.5.6

FROM base as app_build

# Create app directory
WORKDIR /rails

# Copy Gemfiles
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle config set --local path '/usr/local/bundle'
RUN bundle install --jobs "$(nproc)" --retry 5
RUN bundle exec bootsnap precompile app/ lib/

# Copy application code
COPY . ./

# Precompile assets (for Rails)
RUN SECRET_KEY_BASE_DUMMY=1 
RUN bundle exec rails assets:precompile

# FROM app_build as sidekiq_build
# RUN gem install sidekiq:7.2.2
# RUN rm -rf tmp/pids/server.pid
