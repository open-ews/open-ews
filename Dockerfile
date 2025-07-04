# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .tool-versions
ARG RUBY_VERSION=3.4
FROM public.ecr.aws/docker/library/ruby:$RUBY_VERSION-alpine AS base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT="development test"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apk update --no-cache && \
  apk upgrade --no-cache && \
  apk add --update --no-cache build-base git gcompat postgresql-dev yaml-dev nodejs-current npm

RUN corepack enable
RUN corepack prepare yarn@stable --activate

# Install application gems
COPY Gemfile Gemfile.lock ./

RUN bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
  find "${BUNDLE_PATH}" -name "*.o" -delete && find "${BUNDLE_PATH}" -name "*.c" -delete && \
  mkdir -p tmp/pids && \
  mkdir -p storage && \
  bundle exec bootsnap precompile --gemfile

COPY package.json yarn.lock ./
RUN yarn install

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apk update --no-cache && \
  apk upgrade --no-cache && \
  apk add --update --no-cache build-base gcompat postgresql-dev vips-dev ffmpeg

# Copy built artifacts: gems, application
COPY --from=build --link /usr/local/bundle/ /usr/local/bundle/
COPY --from=build --link /rails/ /rails/

# Run and own only the runtime files as a non-root user for security
RUN addgroup -S -g 1000 rails && \
  adduser -u 1000 -D -G rails rails && \
  chown -R rails:rails db storage log tmp

USER 1000:1000
ENV RUBY_YJIT_ENABLE=true

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
