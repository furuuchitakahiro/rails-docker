FROM ruby:2.5.1

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y nodejs

RUN mkdir -p /usr/src/app
ENV HOME=/usr/src/app
WORKDIR $HOME

ADD Gemfile $HOME
ADD Gemfile.lock $HOME

RUN bundle install

ADD . $HOME
