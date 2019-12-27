FROM google/cloud-sdk
RUN apt-get -y install curl
ADD google-cloud-sql-snapshot.sh /opt/google-cloud-sql-snapshot.sh
ADD entrypoint.sh /opt/entrypoint.sh
RUN chmod u+x /opt/google-cloud-sql-snapshot.sh /opt/entrypoint.sh
ENTRYPOINT /opt/entrypoint.sh
