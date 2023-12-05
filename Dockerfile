FROM ruby:2.5

WORKDIR /usr/src/app
EXPOSE 5000
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/*
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install
ADD . .

ENV RAILS_ENV docker
ENV DB_HOST localhost
ENV DB_DB global_presentation
ENV DB_USER global_presentation
ENV DB_PASS global_presentation 

CMD ["bundle", "exec", "puma"]
