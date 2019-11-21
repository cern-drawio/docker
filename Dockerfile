FROM tomcat:9-jre11-slim

LABEL maintainer="Esteban Puentes <esteban.puentes@cern.ch>"

ENV VERSION=12.2.8

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        openjdk-11-jdk-headless ant git patch wget xmlstarlet && \
    cd /tmp && \
    wget https://github.com/cern-drawio/drawio/archive/v${VERSION}-cern.zip && \
    unzip v${VERSION}-cern.zip && \
    cd /tmp/drawio-${VERSION}-cern/etc/build && \
    ant war && \
    cd /tmp/drawio-${VERSION}-cern/build && \
    unzip /tmp/drawio-${VERSION}-cern/build/draw.war -d $CATALINA_HOME/webapps/draw && \
    apt-get remove -y --purge openjdk-11-jdk-headless ant git patch wget && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/v${VERSION}-cern.zip \
        /tmp/drawio-${VERSION}-cern

# Update server.xml to set Draw.io webapp to root
RUN cd $CATALINA_HOME && \
    xmlstarlet ed \
    -P -S -L \
    -i '/Server/Service/Engine/Host/Valve' -t 'elem' -n 'Context' \
    -i '/Server/Service/Engine/Host/Context' -t 'attr' -n 'path' -v '/' \
    -i '/Server/Service/Engine/Host/Context[@path="/"]' -t 'attr' -n 'docBase' -v 'draw' \
    -s '/Server/Service/Engine/Host/Context[@path="/"]' -t 'elem' -n 'WatchedResource' -v 'WEB-INF/web.xml' \
    -i '/Server/Service/Engine/Host/Valve' -t 'elem' -n 'Context' \
    -i '/Server/Service/Engine/Host/Context[not(@path="/")]' -t 'attr' -n 'path' -v '/ROOT' \
    -s '/Server/Service/Engine/Host/Context[@path="/ROOT"]' -t 'attr' -n 'docBase' -v 'ROOT' \
    -s '/Server/Service/Engine/Host/Context[@path="/ROOT"]' -t 'elem' -n 'WatchedResource' -v 'WEB-INF/web.xml' \
    -s '/Server/Service/Engine/Host' -t 'elem' -n 'Valve' \
    -s '/Server/Service/Engine/Host/Valve[not(@directory="logs")]' -t 'attr' -n 'className' -v 'org.apache.catalina.valves.RemoteHostValve' \
    -s '/Server/Service/Engine/Host/Valve[not(@directory="logs")]' -t 'attr' -n 'allow' -v 'oostandarddev\-.*\.cern\.ch|oostandardprod\-.*\.cern\.ch|pcitcda30\.dyndns\.cern\.ch|macitcda30\.dyndns\.cern\.ch' \
    -s '/Server/Service/Connector[@port="8080"]' -t 'attr' -n 'enableLookups' -v 'true' \
    conf/server.xml

WORKDIR $CATALINA_HOME

EXPOSE 8080

ENTRYPOINT ["catalina.sh", "run"]
