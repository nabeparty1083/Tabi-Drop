FROM ruby:3.3.6

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

RUN RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

EXPOSE 3000

CMD ["sh", "-c", "bin/rails db:prepare && bin/rails server -b 0.0.0.0"]
