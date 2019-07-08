FROM tomcat:9-jre11-slim

LABEL maintainer="Esteban Puentes <esteban.puentes@cern.ch>"

ENV VERSION=10.8.8

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        openjdk-11-jdk-headless ant git patch wget xmlstarlet && \
    cd /tmp && \
    wget https://github.com/cern-drawio/drawio/archive/cern-v${VERSION}.zip && \
    unzip cern-v${VERSION}.zip && \
    cd /tmp/drawio-cern-v${VERSION}/etc/build && \
    ant war && \
    cd /tmp/drawio-cern-v${VERSION}/build && \
    unzip /tmp/drawio-cern-v${VERSION}/build/draw.war -d $CATALINA_HOME/webapps/draw && \
    apt-get remove -y --purge openjdk-11-jdk-headless ant git patch wget && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/cern-v${VERSION}.zip \
        /tmp/drawio-cern-v${VERSION}

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
    conf/server.xml

# Remove external URLs (just precaution)
COPY custom_urls.js webapps/draw/custom_urls.js
RUN sed -i "/App.main();/i mxscript('custom_urls.js');" webapps/draw/index.html

WORKDIR $CATALINA_HOME

EXPOSE 8080

ENTRYPOINT ["catalina.sh", "run"]