FROM ruby:latest

# Install needed dependencies
RUN apt-get update -qq && apt-get install -y libsqlite3-dev

# Some files & directories variables
ENV rom /opt/rom/
ENV core core/
ENV changeset changeset/
ENV repository repository/
ENV rom_version lib/rom/version.rb
ENV core_version lib/rom/version.rb
ENV changeset_version lib/rom/changeset/version.rb
ENV repository_version lib/rom/repository/version.rb

# Create non-root user
RUN useradd -m user && \

# Create rom directory
mkdir $rom && \

# Set user as owner of rom directory
chown user:user $rom

# Work as non-root in rom directory
USER user
WORKDIR $rom

# Cache bundle install
COPY --chown=user:user rom.gemspec Gemfile Gemfile.lock $rom
COPY --chown=user:user ${core}rom-core.gemspec ${core}Gemfile ${rom}${core}
COPY --chown=user:user ${changeset}rom-changeset.gemspec ${changeset}Gemfile ${rom}${changeset}
COPY --chown=user:user ${repository}rom-repository.gemspec ${repository}Gemfile ${rom}${repository}
COPY --chown=user:user ${rom_version} ${rom}${rom_version}
COPY --chown=user:user ${core}${core_version} ${rom}${core}${core_version}
COPY --chown=user:user ${changeset}${changeset_version} ${rom}${changeset}${changeset_version}
COPY --chown=user:user ${repository}${repository_version} ${rom}${repository}${repository_version}
RUN bundle install

# Add the code
COPY --chown=user:user . $rom