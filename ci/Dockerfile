FROM cloudfoundry/cflinuxfs3

ENV WD_PATH="/conjurinc/cloudfoundry-conjur-buildpack" \
    CI_PATH="/conjurinc/cloudfoundry-conjur-buildpack/ci"

WORKDIR "$WD_PATH"

# Install the Cloud Foundry CLI
RUN apt-get update && \
    apt-get install -y apt-transport-https \
                       ca-certificates \
                       openssl \
                       ruby2.5-dev

RUN wget -q https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key && \
    apt-key add cli.cloudfoundry.org.key && \
    echo "deb https://packages.cloudfoundry.org/debian stable main" > /etc/apt/sources.list.d/cloudfoundry-cli.list && \
    apt-get update && \
    apt-get install -y cf-cli && \

    mkdir -p "$CI_PATH" && \

    gem install bundler && \
    # This will prevent warnings about installing gems as root
    bundle config --global silence_root_warning 1

COPY Gemfile \
     Gemfile.lock "$CI_PATH/"

RUN cd "$CI_PATH" && \
    bundle install
