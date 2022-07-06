FROM alpine:latest
COPY springboot /springboot
RUN apk update
RUN apk add openjdk11
RUN apk add curl
RUN apk add --no-cache bash
RUN apk add --upgrade zip
RUN \
    cd /usr/local && \
    curl -L https://services.gradle.org/distributions/gradle-2.5-bin.zip -o gradle-2.5-bin.zip && \
    unzip gradle-2.5-bin.zip && \
    rm gradle-2.5-bin.zip
ENV GRADLE_HOME=/usr/local/gradle-2.5
ENV PATH=$PATH:$GRADLE_HOME/bin
WORKDIR springboot 
CMD [ "./gradlew", "bootRun" ]
