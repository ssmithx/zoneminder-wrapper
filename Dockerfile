FROM debian:10
 
RUN apt-get update ; apt-get install -y gnupg apt-transport-https  wget ca-certificates; echo "deb [trusted=yes] https://zmrepo.zoneminder.com/debian/release-1.34 buster/" >> etc/apt/sources.list; wget -O - https://zmrepo.zoneminder.com/debian/archive-keyring.gpg | apt-key add -; apt-get update; apt-get -y install zoneminder; apt-get remove --purge -y $BUILD_PACKAGES $(apt-mark showauto) && rm -rf /var/lib/apt/lists/*; adduser www-data video; systemctl enable zoneminder.service; a2enconf zoneminder; a2enmod rewrite
# Setup Volumes
# VOLUME /var/cache/zoneminder/events /var/cache/zoneminder/images /var/lib/mysql /var/log/zm

# Expose http port
EXPOSE 80

# Configure entrypoint
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

