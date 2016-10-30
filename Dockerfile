FROM dinkel/openldap:2.4.40

MAINTAINER Darren Jackson, <darren.a.jackson>

# Replicate all default environment variables from the base image and customize the needed one's. 
# This is to be able to use a custom entrypoint and perform all needed settings

ENV INITIAL_ADMIN_USER admin.user
ENV INITIAL_ADMIN_PASSWORD="" GERRIT_PASSWORD="" JENKINS_PASSWORD=""
ENV SLAPD_PASSWORD=""
ENV SLAPD_DOMAIN ldap.example.com
ENV SLAPD_FULL_DOMAIN "dc=ldap,dc=example,dc=com"

# End environment variable definition

# Copy in configuration files
COPY resources/ldap_init.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/ldap_init.sh

COPY resources/load_ldif.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/load_ldif.sh

COPY resources/structure.ldif /tmp/

COPY resources/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod u+x /usr/local/bin/entrypoint.sh

# Install ldap utility commands
RUN cp -a /etc/ldap.dist/* /etc/ldap && \
apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y ldap-utils && \
apt-get clean && rm -rf /var/lib/apt/lists/*

# Create dir for backups
RUN mkdir /backup

# Override entry point
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["slapd", "-d", "32768", "-u", "openldap", "-g", "openldap"]
