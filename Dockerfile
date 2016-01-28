FROM alpine:3.3

# Taken from http://blog.kontena.io/building-minimal-docker-image-for-rails/
MAINTAINER Jefim Borissov <jefim.borissov@gmail.com>

RUN apk update && apk --update add ruby ruby-irb ruby-json ruby-rake \  
    ruby-bigdecimal ruby-io-console libstdc++ tzdata postgresql-client nodejs

ADD app/Gemfile /app/  
ADD app/Gemfile.lock /app/

RUN apk --update add --virtual build-dependencies build-base ruby-dev openssl-dev \  
    postgresql-dev libc-dev linux-headers && \
    gem install bundler --no-rdoc --no-ri && \
    cd /app ; bundle install --without development test && \
    apk del build-dependencies

ADD app/ /app  
RUN chown -R nobody:nogroup /app  
USER nobody

ENV RAILS_ENV production  
WORKDIR /app

CMD ["bundle", "exec", "unicorn", "-p", "8080", "-c", "./config/unicorn.rb"]  