FROM ruby:2.3
MAINTAINER claycarpenter@gmail.com

# Ensure image is updated and install build dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  nodejs

# Create app directory and set as working directory
RUN mkdir -p /app
WORKDIR /app

# Copy Gemfile/lock and install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Copy the main application
COPY . ./

# Configure default command prefix
# Removes requirement to specify "bundle exec" at the beginning of each command
# ENTRYPOINT ["bundle", "exec"]

# Main command to run once the container has started
CMD bash
