FROM openjdk:8-jre

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN wget http://central.maven.org/maven2/org/jmxtrans/jmxtrans/270/jmxtrans-270.deb
RUN dpkg -i jmxtrans-270.deb

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh

ENTRYPOINT /docker-entrypoint.sh